# grc overides for ls
# `brew install coreutils`
if $(gls &>/dev/null); then
  alias ls="gls -F --color --group-directories-first"
  alias l="gls -lAh --color --group-directories-first"
  alias ll="gls -lh --color --group-directories-first"
  alias la="gls -A --color --group-directories-first"
fi

alias reload!='exec zsh'
alias -g ...='../..'
alias -g ....='../../..'
alias -g .....='../../../..'
alias -g ......='../../../../..'
alias -- -='cd -'
alias mkdir='mkdir -pv'
alias finder='open .'
alias less='smartless'
alias ag='ag --color-match="48;5;11" --pager=smartless'
alias s='ag'
alias c='fasd_cd -d'
alias f='fd --follow --hidden'
alias xml='(if [[ -t 1 ]] ; then xmllint --format - | source-highlight -f esc -s xml --style-file xml.style --data-dir=/usr/local/share/source-highlight ; else xmllint --format -; fi)'
alias curl='curl -sS -D /dev/stderr'
alias update_zsh_plugins='antibody bundle < $DOTFILES_ROOT/zsh/plugins >! ~/.zsh/.zsh_plugins && antibody update'

function take() {
  mkdir -p $1
  cd $1
}

# Use nvim if installed
if type nvim > /dev/null 2>&1; then
  alias vi='nvim'
fi

