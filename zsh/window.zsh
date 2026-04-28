# sets the window title nicely no matter where you are
title() {
  # escape '%' chars in $1, make nonprintables visible
  local a=${(V)1//\%/\%\%}

  # truncate command without forking — $(print -Pn ...) caused spurious blank lines
  # on rapid Enter because the blocking fork let async zle -F callbacks fire mid-precmd
  local _fmt="%90>...>$a"
  a=${(%)_fmt}
  a=${a//$'\n'/}

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
