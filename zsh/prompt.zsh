autoload colors && colors

if (( $+commands[git] )); then
  git="$commands[git]"
else
  git="/usr/bin/git"
fi

# Cached prompt fragments — updated asynchronously (git, kube) or in precmd (zmx).
typeset -g _git_prompt_info=""
typeset -g _git_prompt_fd=0
typeset -g _git_prompt_pid=0
typeset -g _kube_prompt_info=""
typeset -g _kube_prompt_fd=0
typeset -g _kube_prompt_pid=0
typeset -g _zmx_prompt_info=""

# --- Git (async) ---

_compute_git_info() {
  $git rev-parse --git-dir &>/dev/null || return

  local status_output
  status_output=$($git status -sb 2>/dev/null) || return

  local first_line="${status_output%%$'\n'*}"
  local branch="${first_line#\#\# }"

  local suffix=""
  if [[ $branch == *"[ahead"* ]]; then
    suffix=" with %{$fg_bold[magenta]%}unpushed%{$reset_color%}"
  fi

  branch="${branch%%...*}"

  if [[ $branch == "HEAD (no branch)"* ]]; then
    local rebase_branch
    rebase_branch=$($git branch 2>/dev/null | grep ' rebasing')
    if [[ -n $rebase_branch ]]; then
      branch=$(printf '%s\n' "$rebase_branch" | cut -d ' ' -f 5 | tr -d ')')
      suffix=" with %{$fg_bold[yellow]%}rebase in progress%{$reset_color%}"
    fi
  fi

  if $git log -n 1 --pretty=%s 2>/dev/null | grep -q -- '--wip--'; then
    suffix=" with %{$fg_bold[yellow]%}WIP%{$reset_color%}"
  fi

  local dirty=""
  [[ $status_output == *$'\n'* ]] && dirty="${status_output#*$'\n'}"
  if [[ -z $dirty ]]; then
    print -r -- " on %{$fg_bold[green]%}${branch}%{$reset_color%}${suffix}"
  else
    print -r -- " on %{$fg_bold[red]%}${branch}%{$reset_color%}${suffix}"
  fi
}

_git_prompt_callback() {
  local fd=$1
  zle -F "$fd"
  IFS= read -r _git_prompt_info <&"$fd"
  exec {fd}>&-
  _git_prompt_fd=0
  _git_prompt_pid=0
  zle reset-prompt
}

_update_git_prompt() {
  if (( _git_prompt_fd )); then
    zle -F "$_git_prompt_fd" 2>/dev/null
    exec {_git_prompt_fd}>&-
    _git_prompt_fd=0
  fi
  (( _git_prompt_pid )) && kill "$_git_prompt_pid" 2>/dev/null
  _git_prompt_pid=0

  exec {_git_prompt_fd}< <(_compute_git_info)
  _git_prompt_pid=$!

  if ! zle -F "$_git_prompt_fd" _git_prompt_callback 2>/dev/null; then
    IFS= read -r _git_prompt_info <&"$_git_prompt_fd"
    exec {_git_prompt_fd}>&-
    _git_prompt_fd=0
    _git_prompt_pid=0
  fi
}

# --- Kube (async) ---

_compute_kube_info() {
  (( $+functions[kube_ps1] )) || return
  local kube_status
  kube_status=$(kube_ps1 | sed -E 's/^\(.*\}N\/A%.*:.*\}N\/A%.*\)$//')
  print -r -- "${kube_status:+ $kube_status}"
}

_kube_prompt_callback() {
  local fd=$1
  zle -F "$fd"
  IFS= read -r _kube_prompt_info <&"$fd"
  exec {fd}>&-
  _kube_prompt_fd=0
  _kube_prompt_pid=0
  zle reset-prompt
}

_update_kube_prompt() {
  if (( _kube_prompt_fd )); then
    zle -F "$_kube_prompt_fd" 2>/dev/null
    exec {_kube_prompt_fd}>&-
    _kube_prompt_fd=0
  fi
  (( _kube_prompt_pid )) && kill "$_kube_prompt_pid" 2>/dev/null
  _kube_prompt_pid=0

  exec {_kube_prompt_fd}< <(_compute_kube_info)
  _kube_prompt_pid=$!

  if ! zle -F "$_kube_prompt_fd" _kube_prompt_callback 2>/dev/null; then
    IFS= read -r _kube_prompt_info <&"$_kube_prompt_fd"
    exec {_kube_prompt_fd}>&-
    _kube_prompt_fd=0
    _kube_prompt_pid=0
  fi
}

# --- ZMX session (sync, just reads an env var) ---

_update_zmx_prompt() {
  if [[ -n $ZMX_SESSION ]]; then
    _zmx_prompt_info="%{$fg_bold[cyan]%}[$ZMX_SESSION]%{$reset_color%} "
  else
    _zmx_prompt_info=""
  fi
}

precmd_functions+=(_update_git_prompt _update_kube_prompt _update_zmx_prompt)

set_prompt() {
  export PROMPT="
%(?:%{$fg_bold[green]%}❯:%{$fg_bold[red]%}❯%s) \${_zmx_prompt_info}%{$fg_bold[blue]%}%1~%{$reset_color%}\${_git_prompt_info}\${_kube_prompt_info}
"
}

# Build the prompt template once at startup — precmd only updates the variables.
set_prompt
