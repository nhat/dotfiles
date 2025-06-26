# sets the window title nicely no matter where you are
title() {
  # escape '%' chars in $1, make nonprintables visible
  local a=${(V)1//\%/\%\%}

  # truncate command, and join lines.
  a=$(print -Pn "%90>...>$a" | tr -d "\n")

  case $TERM in
  screen*)
    print -Pn "\033]0;%~ ⏤ $a\a" # plain xterm title
    ;;
  xterm*|rxvt)
    print -Pn "\033]1;%1~ ⏤ $a\a" # plain xterm tab title
    ;;
  esac
}

precmd() {
  title "zsh" "%m:%35<...<%~"
  set_prompt
}

preexec() {
  title "$1" "%m:%35<...<%~"
}

