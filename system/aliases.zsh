# grc overides for ls
# Made possible through contributions from generous benefactors like
# `brew install coreutils`
if $(gls &>/dev/null); then
  alias ls="gls -F --color"
  alias l="gls -lAh --color"
  alias ll="gls -lh --color"
  alias la="gls -A --color"
fi

alias cp='cp -iv'                           # Preferred 'cp' implementation
alias mv='mv -iv'                           # Preferred 'mv' implementation
alias mkdir='mkdir -pv'                     # Preferred 'mkdir' implementation
alias finder='open .'                       # Open current directory in finder
alias grep='grep --color=auto'              # Always highlight grep search term

# Use nvim if installed
if type nvim > /dev/null 2>&1; then
  alias vi='nvim'
fi

