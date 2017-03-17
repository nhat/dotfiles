# Sets the window title nicely no matter where you are
function title() {
  # escape '%' chars in $1, make nonprintables visible
  a=${(V)1//\%/\%\%}

  # Truncate command, and join lines.
  a=$(print -Pn "%40>...>$a" | tr -d "\n")

  case $TERM in
  screen*)
    print -Pn "\033]0;%1d ⏤  $a\a" # plain xterm title
    ;;
  xterm*|rxvt)
    print -Pn "\033]0;%1d ⏤  $a\a" # plain xterm title
    ;;
  esac
}

precmd() {
  title "zsh" "%m" "%55<...<%~"
  set_prompt
}

function preexec() {
  title "$1" "%m:%35<...<%~"
}
