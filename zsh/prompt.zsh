autoload colors && colors

if (( $+commands[git] )); then
  git="$commands[git]"
else
  git="/usr/bin/git"
fi

# Cached prompt fragments. _git_prompt_info is updated asynchronously via
# zle -F so the prompt appears instantly and git info fills in behind it.
typeset -g _git_prompt_info=""
typeset -g _git_prompt_fd=0
typeset -g _kube_prompt_info=""
typeset -g _zmx_prompt_info=""

# Runs in a subshell (process substitution). Prints one line to stdout.
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

  local dirty="${status_output#*$'\n'}"
  if [[ -z $dirty ]]; then
    print -r -- " on %{$fg_bold[green]%}${branch}%{$reset_color%}${suffix}"
  else
    print -r -- " on %{$fg_bold[red]%}${branch}%{$reset_color%}${suffix}"
  fi
}

# Called by zle -F when the background computation's pipe becomes readable.
_git_prompt_callback() {
  local fd=$1
  zle -F "$fd"                       # deregister — one-shot
  IFS= read -r _git_prompt_info <&"$fd"
  exec {fd}>&-
  _git_prompt_fd=0
  zle reset-prompt                   # redraw prompt with updated git info
}

# Called in precmd: starts async git computation, registers the fd handler.
# The prompt appears immediately using the previous _git_prompt_info value;
# _git_prompt_callback fires once the background subshell finishes.
_update_git_prompt() {
  # Cancel any in-flight computation from the previous Enter
  if (( _git_prompt_fd )); then
    zle -F "$_git_prompt_fd" 2>/dev/null
    exec {_git_prompt_fd}>&-
    _git_prompt_fd=0
  fi

  # Fork the computation into a subshell; capture its stdout via a pipe
  exec {_git_prompt_fd}< <(_compute_git_info)

  # Register the fd with ZLE — handler fires when ZLE is active and data ready.
  # Falls back to synchronous read if called in a context where zle -F fails.
  if ! zle -F "$_git_prompt_fd" _git_prompt_callback 2>/dev/null; then
    IFS= read -r _git_prompt_info <&"$_git_prompt_fd"
    exec {_git_prompt_fd}>&-
    _git_prompt_fd=0
  fi
}

_update_kube_prompt() {
  (( $+functions[kube_ps1] )) || return
  local kube_status
  kube_status=$(kube_ps1 | sed -E 's/^\(.*\}N\/A%.*:.*\}N\/A%.*\)$//')
  _kube_prompt_info="${kube_status:+ $kube_status}"
}

_update_zmx_prompt() {
  if [[ -n $ZMX_SESSION ]]; then
    _zmx_prompt_info="%{$fg_bold[cyan]%}[$ZMX_SESSION]%{$reset_color%} "
  else
    _zmx_prompt_info=""
  fi
}

# Run before each prompt, alongside window.zsh's precmd()
precmd_functions+=(_update_git_prompt _update_kube_prompt _update_zmx_prompt)

set_prompt() {
  export PROMPT="
%(?:%{$fg_bold[green]%}❯:%{$fg_bold[red]%}❯%s) \${_zmx_prompt_info}%{$fg_bold[blue]%}%1~%{$reset_color%}\${_git_prompt_info}\${_kube_prompt_info}
"
}
