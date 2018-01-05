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
alias less='smartless'
alias s='ag --color-match="48;5;11" --pager=smartless'
alias c='fasd_cd -d'
alias f='fd --follow --hidden'
alias xml='(if [[ -t 1 ]] ; then xmllint --format - | source-highlight -f esc -s xml --style-file xml.style; else xmllint --format -; fi)'

# Use nvim if installed
if type nvim > /dev/null 2>&1; then
  alias vi='nvim'
fi

