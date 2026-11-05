from pathlib import Path
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]
ZSHRC = ROOT / "zsh" / "zshrc.symlink"
UI_EVENTS = {
    "defaults",
    "compinit",
    "completion-file",
    "plugins",
    "plugins-config",
    "hostname",
    "iterm-integration",
}
RESULT_COMMAND = """print -r -- \"RESULT:${TEST_LOCALRC_LOADED-unset}:${TEST_PATH_MODULE-unset}:${TEST_ENV_MODULE-unset}:${ZSH_SKIP_PROMPT_SETUP-unset}:${FZF_DEFAULT_OPTS:+present}:$(command -v claude)\"
fixture-function
"""


class StartupFixture:
    def __init__(self, root):
        self.root = root
        self.home = root / "home"
        self.zdotdir = root / "zdotdir"
        self.events = root / "events"
        self.home.mkdir()
        self.zdotdir.mkdir()
        self.bin = self.home / "command-bin"
        self.bin.mkdir()
        self.module_bin = self.home / "module-bin"
        self.module_bin.mkdir()
        self.dotfiles = self.home / ".dotfiles"
        modules = self.dotfiles / "zsh" / "modules"
        modules.mkdir(parents=True)
        functions = self.dotfiles / "functions"
        functions.mkdir()
        (functions / "fixture-function").write_text(
            'print -r -- autoload-function >> "$TEST_STARTUP_EVENTS"\n'
        )
        self.home.joinpath(".zsh").mkdir()
        completion_functions = self.home / "completion-functions"
        completion_functions.mkdir()

        self.zdotdir.joinpath(".zshrc").symlink_to(ZSHRC)
        self.home.joinpath(".localrc").write_text(
            'export TEST_LOCALRC_LOADED=loaded\n'
            'path=("$HOME/command-bin" $path)\n'
        )
        (modules / "path.zsh").write_text(
            'path=("$HOME/module-bin" $path)\n'
            'export TEST_PATH_MODULE=loaded\n'
            'print -r -- path-module >> "$TEST_STARTUP_EVENTS"\n'
        )
        (modules / "env.zsh").write_text(
            'export TEST_ENV_MODULE=loaded\n'
            'alias fixture_alias=true\n'
            'print -r -- env-module >> "$TEST_STARTUP_EVENTS"\n'
            'if [[ -v ZSH_SKIP_PROMPT_SETUP ]]; then\n'
            '  print -r -- marker-visible >> "$TEST_STARTUP_EVENTS"\n'
            'else\n'
            '  print -r -- marker-consumed >> "$TEST_STARTUP_EVENTS"\n'
            'fi\n'
        )
        (modules / "fpath.zsh").write_text(
            'fpath=("$DOTFILES_ROOT/functions" "$HOME/completion-functions" $fpath)\n'
            'print -r -- fpath-module >> "$TEST_STARTUP_EVENTS"\n'
        )
        (modules / "completion.zsh").write_text(
            'print -r -- completion-file >> "$TEST_STARTUP_EVENTS"\n'
        )
        (completion_functions / "compinit").write_text(
            'compinit() {\n'
            '  print -r -- compinit >> "$TEST_STARTUP_EVENTS"\n'
            '  : > "$HOME/.zcompdump"\n'
            '}\n'
        )
        (self.home / ".zsh" / ".zsh_plugins").write_text(
            'print -r -- plugins >> "$TEST_STARTUP_EVENTS"\n'
        )
        (self.dotfiles / "zsh" / "plugins_config").write_text(
            'print -r -- plugins-config >> "$TEST_STARTUP_EVENTS"\n'
        )
        (self.home / ".iterm2_shell_integration.zsh").write_text(
            'print -r -- iterm-integration >> "$TEST_STARTUP_EVENTS"\n'
        )
        self._command(
            "defaults",
            'printf \'defaults\\n\' >> "$TEST_STARTUP_EVENTS"\n'
            'printf \'Dark\\n\'\n',
        )
        self._command(
            "hostname",
            'printf \'hostname\\n\' >> "$TEST_STARTUP_EVENTS"\n'
            'printf \'fixture-host\\n\'\n',
        )
        self._command("claude", "exit 0\n")

    def _command(self, name, content):
        path = self.bin / name
        path.write_text("#!/bin/sh\n" + content)
        path.chmod(0o755)

    def environment(self, marker=None):
        result = {
            "HOME": str(self.home),
            "ZDOTDIR": str(self.zdotdir),
            "PATH": f"{self.bin}:/usr/bin:/bin:/usr/sbin:/sbin",
            "TERM": "xterm-256color",
            "TEST_STARTUP_EVENTS": str(self.events),
        }
        if marker is not None:
            result["ZSH_SKIP_PROMPT_SETUP"] = marker
        return result

    def event_list(self):
        return self.events.read_text().splitlines() if self.events.exists() else []


class LauncherShellStartupTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="launcher-shell-startup-")
        self.addCleanup(self.temp.cleanup)
        self.fixture = StartupFixture(Path(self.temp.name))

    def run_shell(self, args, *, marker=None, command=None, input_text=None):
        argv = ["/bin/zsh", *args]
        if command is not None:
            argv.append(command)
        return subprocess.run(
            argv,
            input=input_text,
            text=True,
            capture_output=True,
            check=False,
            timeout=15,
            env=self.fixture.environment(marker),
        )

    def assert_full_ui_setup(self):
        events = set(self.fixture.event_list())
        self.assertTrue(UI_EVENTS <= events, f"Missing startup events: {UI_EVENTS - events}")

    def assert_regular_setup(self, result):
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("path-module", self.fixture.event_list())
        self.assertIn("env-module", self.fixture.event_list())
        self.assertIn("fpath-module", self.fixture.event_list())
        self.assertIn("marker-consumed", self.fixture.event_list())
        self.assertNotIn("marker-visible", self.fixture.event_list())
        self.assertIn("RESULT:loaded:loaded:loaded:unset:", result.stdout)
        self.assertIn(f":{self.fixture.bin / 'claude'}", result.stdout)
        self.assertIn("autoload-function", self.fixture.event_list())

    def test_unmarked_command_shell_loads_full_setup(self):
        result = self.run_shell(["-lic"], command=RESULT_COMMAND)
        self.assert_regular_setup(result)
        self.assert_full_ui_setup()
        self.assertIn("present", result.stdout)

    def test_marked_command_shell_skips_only_ui_setup(self):
        result = self.run_shell(["-lic"], marker="1", command=RESULT_COMMAND)
        self.assert_regular_setup(result)
        events = set(self.fixture.event_list())
        self.assertTrue(UI_EVENTS.isdisjoint(events), f"UI setup still ran: {UI_EVENTS & events}")
        self.assertNotIn("present", result.stdout)

    def test_marked_interactive_shell_without_command_loads_full_setup(self):
        result = self.run_shell(["-il"], marker="1", input_text="exit\n")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assert_full_ui_setup()
        self.assertIn("marker-consumed", self.fixture.event_list())

    def test_other_marker_values_do_not_opt_in(self):
        result = self.run_shell(["-lic"], marker="true", command=RESULT_COMMAND)
        self.assert_regular_setup(result)
        self.assert_full_ui_setup()
        self.assertIn("present", result.stdout)

    def test_unset_marker_reaches_fallback_shell_with_full_setup(self):
        fallback = (
            'print -r -- "PARENT:${ZSH_SKIP_PROMPT_SETUP-unset}"; '
            '/bin/zsh -ilc '
            '\'print -r -- "FALLBACK:${ZSH_SKIP_PROMPT_SETUP-unset}:$(command -v claude)"\''
        )
        result = self.run_shell(["-lic"], marker="1", command=fallback)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("PARENT:unset", result.stdout)
        self.assertIn(f"FALLBACK:unset:{self.fixture.bin / 'claude'}", result.stdout)
        self.assertEqual(self.fixture.event_list().count("defaults"), 1)
        self.assertEqual(self.fixture.event_list().count("completion-file"), 1)
        self.assertEqual(self.fixture.event_list().count("plugins"), 1)


if __name__ == "__main__":
    unittest.main()
