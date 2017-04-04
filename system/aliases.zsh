# grc overides for ls
# `brew install coreutils`
if $(gls &>/dev/null); then
  alias ls="gls -F --color"
  alias l="gls -lAh --color"
  alias ll="gls -lh --color"
  alias la="gls -A --color"
fi

alias mkdir='mkdir -pv'                     # preferred 'mkdir' implementation
alias finder='open .'                       # open current directory in finder
alias ag='ag --color-match="48;5;11" --pager=smartless'
alias less='smartless'
alias c='fasd_cd -d'

# Use nvim if installed
if type nvim > /dev/null 2>&1; then
  alias vi='nvim'
fi

