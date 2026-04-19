#!/usr/bin/env python3
import sys
import os
import subprocess
from datetime import datetime

LOG = "/tmp/iterm_switch_debug.log"

def log(msg):
    with open(LOG, "a") as f:
        f.write(f"{datetime.now().strftime('%H:%M:%S')} {msg}\n")


def is_vim_running():
    session_id = os.environ.get("ITERM_SESSION_ID", "")
    log(f"ITERM_SESSION_ID={repr(session_id)}")
    if session_id and os.path.exists(f"/tmp/.vim_iterm_{session_id}"):
        log("vim detected via sentinel file")
        return True
    try:
        tty = os.ttyname(sys.stdin.fileno())
        tty_short = os.path.basename(tty)
        log(f"TTY={tty_short}")
        result = subprocess.run(
            ["ps", "-t", tty_short, "-o", "comm="],
            capture_output=True, text=True, timeout=1,
        )
        procs = {p.strip() for p in result.stdout.splitlines()}
        log(f"procs={procs}")
        if procs & {"vim", "nvim", "vi"}:
            log("vim detected via TTY")
            return True
    except Exception as e:
        log(f"TTY check error: {e}")
    return False


direction = sys.argv[1] if len(sys.argv) > 1 else "h"
log(f"--- switch.py called with direction={direction} ---")
log(f"env TERM_PROGRAM={os.environ.get('TERM_PROGRAM','')}")

in_vim = is_vim_running()
log(f"in_vim={in_vim}")

if in_vim:
    log("injecting vim command")
    sys.stdout.write(f"\x1b:call SwitchWindow('{direction}')\n")
    sys.stdout.flush()
else:
    log("calling hammerspoon")
    subprocess.Popen(["/opt/homebrew/bin/hs", "-c", f'navigateITermPane("{direction}")'])

log("done")
