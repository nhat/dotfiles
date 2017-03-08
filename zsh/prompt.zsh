autoload colors && colors

if (( $+commands[git] ))
then
  git="$commands[git]"
else
  git="/usr/bin/git"
fi

git_branch() {
  echo $($git symbolic-ref HEAD 2>/dev/null | awk -F/ {'print $NF'})
}

git_dirty() {
  if $(! $git status -s &> /dev/null)
  then
    echo ""
  else
    if [[ $($git status --porcelain) == "" ]]
    then
      echo " on %{$fg_bold[green]%}$(git_prompt_info)%{$reset_color%}"
    else
      echo " on %{$fg_bold[red]%}$(git_prompt_info)%{$reset_color%}"
    fi
  fi
}

git_prompt_info() {
 ref=$($git symbolic-ref HEAD 2>/dev/null) || return
 echo "${ref#refs/heads/}"
}

unpushed() {
  $git cherry -v @{upstream} 2>/dev/null
}

need_push_or_wip() {
  if $(git log -n 1 2>/dev/null | grep -q -c "\-\-wip\-\-")
  then
    echo " with %{$fg_bold[yellow]%}WIP%{$reset_color%} "
  elif [[ $(unpushed) != "" ]]
  then
    echo " with %{$fg_bold[magenta]%}unpushed%{$reset_color%} "
  else
    echo ""
  fi
}

directory_name() {
  if [[ $(PWD) == $HOME ]]
  then
    echo "%{$fg_bold[blue]%}%1~%{$reset_color%}"
  else  
    echo "%{$fg_bold[blue]%}%1/%{$reset_color%}"
  fi
}

local ret_status="%(?:%{$fg_bold[green]%}➜ :%{$fg_bold[red]%}➜ %s)"
export PROMPT=$'\n${ret_status} $(directory_name)$(git_dirty)$(need_push_or_wip)\n'
set_prompt () {
  export RPROMPT="%{$fg_bold[blue]%}%{$reset_color%}"
}

precmd() {
  title "zsh" "%m" "%55<...<%~"
  set_prompt
}

function preexec() {
    title "$1" "%m:%35<...<%~"
}

