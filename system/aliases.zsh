# grc overides for ls
# `brew install coreutils`
if $(gls &>/dev/null); then
  alias ls='gls -F --color --group-directories-first'
  alias l='gls -lAh --color --group-directories-first'
  alias ll='gls -lh --color --group-directories-first'
  alias la='gls -A --color --group-directories-first'
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
alias as-tree='tree --fromfile .'

alias update_zsh_plugins='antibody bundle < $DOTFILES_ROOT/zsh/plugins >! ~/.zsh/.zsh_plugins && antibody update'
alias add_touchid='if ! grep -q "pam_tid.so" /etc/pam.d/sudo; then sudo sed -i "1a auth       sufficient     pam_tid.so" /etc/pam.d/sudo; echo Added TouchId to sudo; fi'

# k8s
alias ks='kubeon'
alias kctx='kubectx'

# Use kubectl with cluster
function k() {
  if [[ $1 =~ ^[0-9]+$ ]]; then
    cluster=$1
    shift
    remaining_args=("$@")

    kubecolor --cluster=$cluster $@
  else
    kubecolor $@
  fi
}

# Use kubectl with multiple clusters
function kf() {
  kubecolor foreach -q $@ -n $(kubens -c)
}

# Switch k8s namespace quickly
function kns() {
  namespace=$1
  if [[ $1 == "" ]]; then
    kubens -c && return
  elif [[ $namespace == "-" ]]; then
    if [[  $KNS_PREV == "" ]]; then kubens -c && return; fi
    namespace=$KNS_PREV
  fi
  export KNS_PREV=$(kubens -c) && kubectl config set-context --current --namespace=$namespace
}

function take() {
  mkdir -p $1
  cd $1
}

# Use nvim if installed
if type nvim > /dev/null 2>&1; then
  alias vi='nvim'
fi

