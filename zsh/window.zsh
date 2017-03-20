# Sets the window title nicely no matter where you are
title() {
  # escape '%' chars in $1, make nonprintables visible
  a=${(V)1//\%/\%\%}

  # Truncate command, and join lines.
  a=$(print -Pn "%40>...>$a" | tr -d "\n")

  _icon=${${drak_tabicon[${${(s: :)a}[1]}]}:-${drak_tabicon[zsh]}}

  case $TERM in
  screen*)
    print -Pn "\033]0;%1d ⏤  $a\a" # plain xterm title
    ;;
  xterm*|rxvt)
    print -Pn "\033]2;%1d ⏤  $a\a" # plain xterm title
    print -Pn "\033]1;${_icon} %1d ⏤  $a\a" # plain xterm title
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


typeset -gA drak_tabicon
drak_tabicon+=('brew'    $'\U1F37A'); # BEER MUG
drak_tabicon+=('jekyll'  $'\U1F489'); # SYRINGE
drak_tabicon+=('make'    $'\U1F6E0'); # HAMMER AND WRENCH
drak_tabicon+=('mvn'     $'\U1F6E0'); # HAMMER AND WRENCH
drak_tabicon+=('gradle'  $'\U1F6E0'); # HAMMER AND WRENCH
drak_tabicon+=('gradlew' $'\U1F6E0'); # HAMMER AND WRENCH
drak_tabicon+=('rails'   $'\U1F6E4'); # RAILWAY TRACK
drak_tabicon+=('grunt'   $'\U1F43D'); # PIG NOSE
drak_tabicon+=('gulp'    $'\U1F379'); # TROPICAL DRINK
drak_tabicon+=('bower'   $'\U1F3F9'); # BOW AND ARROW
drak_tabicon+=('git'     $'\U1F3F7'); # LABEL
drak_tabicon+=('hg'      $'\U1F3F7'); # LABEL
drak_tabicon+=('svn'     $'\U1F3F7'); # LABEL
drak_tabicon+=('cvs'     $'\U1F3F7'); # LABEL
drak_tabicon+=('psql'    $'\U1F418'); # ELEPHANT
drak_tabicon+=('mysql'   $'\U1F42C'); # DOLPHIN
drak_tabicon+=('budle'   $'\U1F4E6'); # PACKAGE
drak_tabicon+=('budler'  $'\U1F4E6'); # PACKAGE
drak_tabicon+=('tar'     $'\U1F4E6'); # PACKAGE
drak_tabicon+=('zip'     $'\U1F4E6'); # PACKAGE
drak_tabicon+=('unzip'   $'\U1F4E6'); # PACKAGE
drak_tabicon+=('gzip'    $'\U1F4E6'); # PACKAGE
drak_tabicon+=('gunzip'  $'\U1F4E6'); # PACKAGE
drak_tabicon+=('bzip'    $'\U1F4E6'); # PACKAGE
drak_tabicon+=('bunzip'  $'\U1F4E6'); # PACKAGE
drak_tabicon+=('java'    $'\U2615' ); # HOT BEVERAGE
drak_tabicon+=('node'    $'\U2615' ); # HOT BEVERAGE
drak_tabicon+=('coffee'  $'\U2615' ); # HOT BEVERAGE
drak_tabicon+=('tail'    $'\U1F453'); # EYEGLASSES
drak_tabicon+=('less'    $'\U1F453'); # EYEGLASSES
drak_tabicon+=('more'    $'\U1F453'); # EYEGLASSES
drak_tabicon+=('grep'    $'\U1F50E'); # RIGHT-POINTING MAGNIFYING GLASS
drak_tabicon+=('ack'     $'\U1F50E'); # RIGHT-POINTING MAGNIFYING GLASS
drak_tabicon+=('ag'      $'\U1F50E'); # RIGHT-POINTING MAGNIFYING GLASS
drak_tabicon+=('man'     $'\U1F4DA'); # BOOKS
drak_tabicon+=('ssh'     $'\U1F5A5'); # DESKTOP COMPUTER
drak_tabicon+=('rm'      $'\U1F5D1'); # WASTEBASKET
drak_tabicon+=('zsh'     $'\U1F4BB'); # NOTEBOOK COMPUTER

