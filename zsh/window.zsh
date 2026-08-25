# sets the window title nicely no matter where you are
title() {
  # escape '%' chars in $1, make nonprintables visible
  local a=${(V)1//\%/\%\%}
  a=${a//$'\n'/ }

  # truncate to ~90 visible chars via plain slicing, not ${(%)} prompt-expansion.
  # Command text is untrusted: running it through zsh's %-directive parser can throw
  # "unmatched '" / parse errors when the command happens to contain a sequence that
  # looks like an unterminated %(...) conditional or %<...< truncation marker (seen
  # 2026-07-31 reviewing a PR whose diff/body text tripped this). Plain slicing has
  # no such grammar to misparse.
  (( ${#a} > 90 )) && a="${a[1,87]}..."

  # The 2026-07-31 fix above only closed half the gap: plain slicing can still cut a
  # command line mid-quote, leaving $a with an unbalanced quote count. The final
  # print -P calls below used to re-expand $a through the same %-directive parser
  # that fix was meant to avoid, so a truncated-mid-quote command (any line over 90
  # chars with a quoted argument straddling the cut, e.g. a long absolute path in
  # single quotes) still threw "unmatched '" / parse error (seen 2026-08-25 with a
  # spawned Claude tab's launch command). Fix: expand only the fixed, known-safe %~
  # prompt sequence here, once, under our control, then print $a as plain literal
  # text with no -P at all, so untrusted content is never prompt-parsed again.
  local dir=${(%):-%~}

  case $TERM in
  screen*)
    print -n "\033]0;$dir ⏤ $a\a" # plain xterm title
    ;;
  xterm*|rxvt)
    print -n "\033]1;$dir ⏤ $a\a" # plain xterm tab title
    ;;
  esac
}

_window_precmd()  { title "zsh" "%m:%35<...<%~" }
_window_preexec() { title "$1"  "%m:%35<...<%~" }

precmd_functions+=(_window_precmd)
preexec_functions+=(_window_preexec)
