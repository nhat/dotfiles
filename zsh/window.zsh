# sets the window title nicely no matter where you are
title() {
  # escape '%' chars in $1, make nonprintables visible
  local a=${(V)1//\%/\%\%}

  # truncate command, and join lines.
  a=$(print -Pn "%40>...>$a" | tr -d "\n")

  local _icon=${${tabicon[${${(s: :)a}[1]}]}:-${tabicon[zsh]}}

  case $TERM in
  screen*)
    print -Pn "\033]0;%1d ⏤ $a\a" # plain xterm title
    ;;
  xterm*|rxvt)
    print -Pn "\033]2;%1d ⏤ $a\a" # plain xterm title
    print -Pn "\033]1;${_icon} %1d ⏤ $a\a" # plain xterm title
    ;;
  esac
}

precmd() {
  title "zsh" "%m" "%55<...<%~"
  set_prompt
}

preexec() {
  title "$1" "%m:%35<...<%~"
}


typeset -gA tabicon
tabicon+=('brew'    $'\U1F37A'); # BEER MUG
tabicon+=('jekyll'  $'\U1F489'); # SYRINGE
tabicon+=('make'    $'\U1F6E0'); # HAMMER AND WRENCH
tabicon+=('mvn'     $'\U1F6E0'); # HAMMER AND WRENCH
tabicon+=('gradle'  $'\U1F6E0'); # HAMMER AND WRENCH
tabicon+=('gradlew' $'\U1F6E0'); # HAMMER AND WRENCH
tabicon+=('rails'   $'\U1F6E4'); # RAILWAY TRACK
tabicon+=('grunt'   $'\U1F43D'); # PIG NOSE
tabicon+=('gulp'    $'\U1F379'); # TROPICAL DRINK
tabicon+=('bower'   $'\U1F3F9'); # BOW AND ARROW
tabicon+=('git'     $'\U1F3F7'); # LABEL
tabicon+=('hg'      $'\U1F3F7'); # LABEL
tabicon+=('svn'     $'\U1F3F7'); # LABEL
tabicon+=('cvs'     $'\U1F3F7'); # LABEL
tabicon+=('psql'    $'\U1F418'); # ELEPHANT
tabicon+=('mysql'   $'\U1F42C'); # DOLPHIN
tabicon+=('budle'   $'\U1F4E6'); # PACKAGE
tabicon+=('budler'  $'\U1F4E6'); # PACKAGE
tabicon+=('tar'     $'\U1F4E6'); # PACKAGE
tabicon+=('zip'     $'\U1F4E6'); # PACKAGE
tabicon+=('unzip'   $'\U1F4E6'); # PACKAGE
tabicon+=('gzip'    $'\U1F4E6'); # PACKAGE
tabicon+=('gunzip'  $'\U1F4E6'); # PACKAGE
tabicon+=('bzip'    $'\U1F4E6'); # PACKAGE
tabicon+=('bunzip'  $'\U1F4E6'); # PACKAGE
tabicon+=('java'    $'\U2615' ); # HOT BEVERAGE
tabicon+=('node'    $'\U2615' ); # HOT BEVERAGE
tabicon+=('coffee'  $'\U2615' ); # HOT BEVERAGE
tabicon+=('tail'    $'\U1F453'); # EYEGLASSES
tabicon+=('less'    $'\U1F453'); # EYEGLASSES
tabicon+=('more'    $'\U1F453'); # EYEGLASSES
tabicon+=('grep'    $'\U1F50E'); # RIGHT-POINTING MAGNIFYING GLASS
tabicon+=('ack'     $'\U1F50E'); # RIGHT-POINTING MAGNIFYING GLASS
tabicon+=('ag'      $'\U1F50E'); # RIGHT-POINTING MAGNIFYING GLASS
tabicon+=('man'     $'\U1F4DA'); # BOOKS
tabicon+=('ssh'     $'\U1F5A5'); # DESKTOP COMPUTER
tabicon+=('rm'      $'\U1F5D1'); # WASTEBASKET
tabicon+=('zsh'     $'\U1F4BB'); # NOTEBOOK COMPUTER

