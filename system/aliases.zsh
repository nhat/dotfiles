# grc overides for ls
# `brew install coreutils`
if $(gls &>/dev/null); then
  alias ls="gls -F --color"
  alias l="gls -lAh --color"
  alias ll="gls -lh --color"
  alias la="gls -A --color"
fi

alias mkdir='mkdir -pv'                     # Preferred 'mkdir' implementation
alias finder='open .'                       # Open current directory in finder
alias ag='ag --pager smartless'
alias less='smartless'

# Use nvim if installed
if type nvim > /dev/null 2>&1; then
  alias vi='nvim'
fi

