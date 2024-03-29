alias g='git'
alias ga='git add'
alias gaa='git add --all'
alias gb='git branch'
alias gcb='git checkout -b'
alias gco='git checkout'

alias gc='git commit -v'
alias gc!='git commit -v --amend'
alias gca='git commit -v -a'
alias gca!='git commit -v -a --amend'
alias gcn!='git commit -v --no-edit --amend'
alias gcan!='git commit -v -a --no-edit --amend'
alias gcm='git commit -m'
alias gcam='git commit -a -m'

alias gd='git diff HEAD'
alias gp='git push origin HEAD'
alias grh='git reset --hard'
alias gt='cd "$(git rev-parse --show-toplevel)"'
alias grm="git status | grep deleted | awk '{\$1=\$2=\"\"; print \$0}' | \
           perl -pe 's/^[ \t]*//' | sed 's/ /\\\\ /g' | xargs git rm"
alias gs='git status -sb'

alias gsta='git stash save'
alias gstaa='git stash apply'
alias gstc='git stash clear'
alias gstd='git stash drop'
alias gstl='git stash list'
alias gstp='git stash pop'

function gl() {
  if test $(tput cols) -ge 140; then
    git log --graph --pretty=format:"%C(yellow)%h%Creset %<(80,trunc)%s %<(15,trunc)%C(auto)%D%Creset %<(20,trunc)%Cblue%an %Cgreen%ar%Creset" --abbrev-commit --date-order
  else
    git log --graph --pretty=format:"%C(yellow)%h%Creset %<(40,trunc)%s %<(15,trunc)%Cblue%an %<(12,trunc)%Cgreen%ar%Creset" --abbrev-commit --date-order
  fi
}
