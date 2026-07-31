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

  case $TERM in
  screen*)
    print -Pn "\033]0;%~ ⏤ $a\a" # plain xterm title
    ;;
  xterm*|rxvt)
    print -Pn "\033]1;%1~ ⏤ $a\a" # plain xterm tab title
    ;;
  esac
}

_window_precmd()  { title "zsh" "%m:%35<...<%~" }
_window_preexec() { title "$1"  "%m:%35<...<%~" }

precmd_functions+=(_window_precmd)
preexec_functions+=(_window_preexec)
