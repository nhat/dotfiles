autoload colors && colors

if (( $+commands[git] )); then
  git="$commands[git]"
else
  git="/usr/bin/git"
fi

git_dirty() {
  if [[ $($git status -s) == "" ]]; then
    echo " on %{$fg_bold[green]%}$(git_branch)%{$reset_color%}"
  else
    echo " on %{$fg_bold[red]%}$(git_branch)%{$reset_color%}"
  fi
}

git_branch() {
  branch=$($git rev-parse --abbrev-ref HEAD 2>/dev/null)

  if [[ $branch == "HEAD" ]] && [[ $(git branch | grep rebasing) ]]; then
      echo $(git branch | grep rebasing | cut -d " " -f 5 | tr -d ")")
  else
      echo $branch
  fi
}

need_push_or_wip() {
  if $($git log -n 1 2>/dev/null | grep -q -c "\-\-wip\-\-"); then
    echo " with %{$fg_bold[yellow]%}WIP%{$reset_color%} "
  elif [[ $($git cherry -v @{upstream} 2>/dev/null) != "" ]]; then
    echo " with %{$fg_bold[magenta]%}unpushed%{$reset_color%} "
  elif [[ -n $($git branch 2>/dev/null | grep "rebasing") ]]; then
    echo " with %{$fg_bold[yellow]%}rebase in progress%{$reset_color%} "
  else
    echo ""
  fi
}

git_status() {
  if $(! $git branch &> /dev/null); then
    echo ""
  else
    echo "$(git_dirty)$(need_push_or_wip)"
  fi
}

directory_name() {
  if [[ $(PWD) == $HOME ]]; then
    echo "%{$fg_bold[blue]%}%1~%{$reset_color%}"
  else
    echo "%{$fg_bold[blue]%}%1/%{$reset_color%}"
  fi
}

local ret_status="%(?:%{$fg_bold[green]%}➜ :%{$fg_bold[red]%}➜ %s)"

set_prompt() {
  export PROMPT=$'\n${ret_status} $(directory_name)$(git_status)\n'
}

