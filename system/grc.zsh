# grc colorizes nifty unix tools all over the place
if (( $+commands[grc] )) && (( $+commands[brew] )) then
  if [[ $(arch) == 'arm64' ]]; then
    source /opt/homebrew/etc/grc.zsh
  else
    source /usr/local/etc/grc.zsh
  fi
fi
