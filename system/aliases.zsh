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
alias kctx='kubectx'
alias ks='kubeon'

alias update_zsh_plugins='antibody bundle < $DOTFILES_ROOT/zsh/plugins >! ~/.zsh/.zsh_plugins && antibody update'
alias add_touchid='if ! grep -q "pam_tid.so" /etc/pam.d/sudo; then sudo sed -i "1a auth       sufficient     pam_tid.so" /etc/pam.d/sudo; echo Added TouchId to sudo; fi'

# Switch k8s namespace quickly
function kns() {
  namespace=$1
  if [[ $1 == "" ]]; then
    echo "error: no namespace provided" && return
  elif [[ $namespace == "-" ]]; then
    if [[  $KNS_PREV == "" ]]; then kubens -c && return; fi
    namespace=$KNS_PREV
  fi
  tess kubectl get namespace $namespace && export KNS_PREV=$(kubens -c) && tess kubectl config set-context --current --namespace=$namespace
}

function k() {
  if [[ $1 == "use" ]]; then
    kubectl $@
  else
    tess kubectl $@
  fi
}

function take() {
  mkdir -p $1
  cd $1
}

# Use nvim if installed
if type nvim > /dev/null 2>&1; then
  alias vi='nvim'
fi

