"""Ctrl+P integration tests, using real fzf in disposable pseudo-terminals.

Run with: python3 -I tests/test_fzf_picker.py
"""

import concurrent.futures
import fcntl
import os
from pathlib import Path
import pty
import select
import shutil
import signal
import struct
import tempfile
import termios
import time
import unittest


CONFIG = Path(__file__).resolve().parents[1] / "zsh" / "config.zsh"
RUNNER = """source "$PICKER_WIDGET"
BUFFER=$PICKER_BUFFER
LBUFFER=$PICKER_BUFFER
RBUFFER=''
zle() {
  print -rn -- "$1"$'\\0'"$BUFFER"$'\\0'"$LBUFFER"$'\\0' >> "$PICKER_EVENTS"
}
fzf-find-file-or-folder
print -r -- PICKER_DONE
"""
SLOW_FD = """#!/bin/sh
printf '%s\\n' "$$" >> "$PICKER_PIDS"
case " $* " in *" --print0 "*) format='%s\\0';; *) format='%s\\n';; esac
case " $* " in *" --strip-cwd-prefix "*) item='pick.txt';; *) item="$HOME/pick.txt";; esac
printf "$format" "$item"
exec /bin/sleep 2
"""


class Picker:
    def __init__(self, root, widget, *, buffer="", slow=False, name="picker"):
        self.root = root
        self.events = root / f"{name}.events"
        self.pids = root / f"{name}.pids"
        self.output = bytearray()
        self.reaped = False
        self.pid, self.master = pty.fork()
        if self.pid == 0:
            os.chdir(root / "local")
            os.environ.update(
                HOME=str(root / "home"),
                TERM="xterm-256color",
                SHELL="/bin/zsh",
                FZF_DEFAULT_OPTS="--height=100% --reverse --exit-0 --no-separator",
                FZF_DEFAULT_OPTS_FILE="",
                PICKER_WIDGET=str(widget),
                PICKER_BUFFER=buffer,
                PICKER_EVENTS=str(self.events),
                PICKER_PIDS=str(self.pids),
                PATH=(str(root / "bin") + ":" if slow else "") + os.environ["PATH"],
            )
            fcntl.ioctl(0, termios.TIOCSWINSZ, struct.pack("HHHH", 30, 160, 0, 0))
            os.execv("/bin/zsh", ["/bin/zsh", "-dfc", RUNNER])

    def wait_for(self, text, timeout=5):
        needle = text.encode()
        end = time.monotonic() + timeout
        while needle not in self.output:
            remaining = end - time.monotonic()
            if remaining <= 0:
                raise AssertionError(f"Timed out waiting for {text!r}: {bytes(self.output[-1000:])!r}")
            if select.select([self.master], [], [], remaining)[0]:
                try:
                    chunk = os.read(self.master, 65536)
                except OSError:
                    chunk = b""
                if not chunk:
                    raise AssertionError(f"Unexpected EOF: {bytes(self.output[-1000:])!r}")
                self.output.extend(chunk)

    def send(self, keys):
        os.write(self.master, keys)

    def switch_home(self):
        self.output.clear()
        self.send(b"\x10")
        self.wait_for(str(self.root / "home" / "pick.txt"))

    def finish(self, keys=b"\r"):
        start = time.monotonic()
        self.send(keys)
        self.wait_for("PICKER_DONE")
        elapsed = time.monotonic() - start
        _, status = os.waitpid(self.pid, 0)
        self.reaped = True
        if os.waitstatus_to_exitcode(status) != 0:
            raise AssertionError(f"Picker exited with {status}: {bytes(self.output[-1000:])!r}")
        return elapsed, self.events.read_bytes().split(b"\0")[:-1] if self.events.exists() else []

    def close(self):
        os.close(self.master)
        if not self.reaped:
            os.kill(self.pid, signal.SIGKILL)
            os.waitpid(self.pid, 0)
        if self.pids.exists():
            for pid in self.pids.read_text().splitlines():
                try:
                    os.kill(int(pid), signal.SIGTERM)
                except ProcessLookupError:
                    pass


@unittest.skipUnless(shutil.which("fzf") and shutil.which("fd"), "fzf and fd are required")
class PickerTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="fzf-picker-")
        self.addCleanup(self.temp.cleanup)
        # Spaces and shell metacharacters exercise quoting of HOME and selected paths.
        self.root = Path(self.temp.name) / "space ' $ [root]"
        for name in ("local", "home", "bin"):
            (self.root / name).mkdir(parents=True)
        (self.root / "local" / "pick.txt").touch()
        (self.root / "home" / "pick.txt").touch()
        fake = self.root / "bin" / "fd"
        fake.write_text(SLOW_FD)
        fake.chmod(0o755)
        text = Path(os.environ.get("PICKER_TEST_CONFIG", CONFIG)).read_text()
        widget = text[text.index("_fd_excludes="):text.index("zle -N fzf-find-file-or-folder")]
        self.widget = self.root / "widget"
        self.widget.write_text(widget.replace("/tmp/fzf_selection", str(Path(self.temp.name) / "selection")))

    def picker(self, **kwargs):
        picker = Picker(self.root, self.widget, **kwargs)
        self.addCleanup(picker.close)
        picker.wait_for("pick")
        return picker

    def assert_command(self, events, command, path):
        self.assertEqual(events[0], b"accept-line")
        # Ask zsh to parse its own quoting, without executing the selected command.
        import subprocess
        result = subprocess.run(
            ["/bin/zsh", "-dfc", 'words=(${(z)1}); print -rn -- "${(Q)words[1]}"$\'\\0\'"${(Q)words[2]}"',
             "test", events[1].decode()],
            capture_output=True, check=True,
        )
        self.assertEqual(result.stdout, command.encode() + b"\0" + str(path).encode())

    def test_local_file(self):
        _, events = self.picker().finish()
        self.assert_command(events, "e", (self.root / "local" / "pick.txt").resolve())

    def test_home_file(self):
        picker = self.picker()
        picker.switch_home()
        _, events = picker.finish()
        self.assert_command(events, "e", self.root / "home" / "pick.txt")

    def test_home_switch_with_no_matches(self):
        picker = self.picker()
        picker.output.clear()
        picker.send(b"no-such-path")
        picker.wait_for("0/1")
        picker.switch_home()
        _, events = picker.finish()
        self.assert_command(events, "e", self.root / "home" / "pick.txt")

    def test_directory(self):
        (self.root / "local" / "pick.txt").unlink()
        directory = self.root / "local" / "pick dir"
        directory.mkdir()
        picker = self.picker()
        _, events = picker.finish()
        self.assert_command(events, "cd", str(directory.resolve()) + "/")

    def test_append_preserves_buffer(self):
        _, events = self.picker(buffer="cat ").finish()
        self.assertEqual(events[0], b"redisplay")
        self.assertEqual(events[1], b"cat ")
        self.assert_command([b"accept-line", events[2]], "cat", (self.root / "local" / "pick.txt").resolve())

    def test_cancel_local(self):
        _, events = self.picker(buffer="cat ").finish(b"\x1b")
        self.assertEqual(events, [b"redisplay", b"cat ", b"cat "])

    def test_cancel_home(self):
        picker = self.picker(buffer="cat ")
        picker.switch_home()
        _, events = picker.finish(b"\x1b")
        self.assertEqual(events, [b"redisplay", b"cat ", b"cat "])

    def assert_producers_stopped(self, picker, pids=None):
        for pid in pids or picker.pids.read_text().splitlines():
            with self.assertRaises(ProcessLookupError, msg=f"Producer {pid} survived the picker"):
                os.kill(int(pid), 0)

    def test_slow_local_producer(self):
        picker = self.picker(slow=True)
        elapsed, events = picker.finish()
        self.assert_command(events, "e", (self.root / "local" / "pick.txt").resolve())
        self.assertLess(elapsed, 1, f"Acceptance waited for producer: {elapsed:.3f}s")
        self.assert_producers_stopped(picker)
        print(f"local accept: {elapsed:.3f}s", flush=True)

    def test_slow_home_producer(self):
        picker = self.picker(slow=True)
        local_pids = picker.pids.read_text().splitlines()
        picker.switch_home()
        self.assert_producers_stopped(picker, local_pids)
        elapsed, events = picker.finish()
        self.assert_command(events, "e", self.root / "home" / "pick.txt")
        self.assertLess(elapsed, 1, f"Acceptance waited for producer: {elapsed:.3f}s")
        self.assert_producers_stopped(picker)
        print(f"home accept: {elapsed:.3f}s", flush=True)

    def test_slow_producer_cancellation(self):
        for home in (False, True):
            with self.subTest(home=home):
                picker = self.picker(slow=True, buffer="cat ", name=f"cancel-{home}")
                if home:
                    picker.switch_home()
                elapsed, events = picker.finish(b"\x1b")
                self.assertEqual(events, [b"redisplay", b"cat ", b"cat "])
                self.assertLess(elapsed, 1)
                self.assert_producers_stopped(picker)

    def test_newline_filename(self):
        (self.root / "local" / "pick.txt").unlink()
        path = self.root / "local" / "pick\nname.txt"
        path.touch()
        _, events = self.picker().finish()
        self.assert_command(events, "e", path.resolve())

    def test_exclusions_and_hidden_files(self):
        (self.root / "local" / "pick.txt").unlink()
        for directory in (".git", "node_modules", ".cache"):
            path = self.root / "local" / directory
            path.mkdir()
            (path / "pick-noise.txt").touch()
        hidden = self.root / "local" / ".pick.txt"
        hidden.touch()
        _, events = self.picker().finish()
        self.assert_command(events, "e", hidden.resolve())

    def test_concurrent_pickers(self):
        first = self.picker(slow=True, name="first")
        second = self.picker(slow=True, name="second")
        second.switch_home()
        with concurrent.futures.ThreadPoolExecutor() as pool:
            first_result = pool.submit(first.finish)
            second_result = pool.submit(second.finish)
            _, first_events = first_result.result()
            _, second_events = second_result.result()
        self.assert_command(first_events, "e", (self.root / "local" / "pick.txt").resolve())
        self.assert_command(second_events, "e", self.root / "home" / "pick.txt")


if __name__ == "__main__":
    unittest.main()
