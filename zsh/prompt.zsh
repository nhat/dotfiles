autoload colors && colors

if (( $+commands[git] )); then
  git="$commands[git]"
else
  git="/usr/bin/git"
fi

# Cached prompt fragments — populated once per command in precmd hooks,
# then read cheaply via ${variable} in PROMPT with zero subprocess cost.
_git_prompt_info=""
_kube_prompt_info=""
_zmx_prompt_info=""

_update_git_prompt() {
  # Fast bail when not in a git repo
  $git rev-parse --git-dir &>/dev/null || { _git_prompt_info=""; return }

  # One call covers branch name, dirty status, and ahead/behind —
  # replaces the old git status + git rev-parse + git cherry trio.
  local status_output
  status_output=$($git status -sb 2>/dev/null) || { _git_prompt_info=""; return }

  # First line: "## branch" or "## branch...upstream [ahead N, behind M]"
  local first_line="${status_output%%$'\n'*}"
  local branch="${first_line#\#\# }"

  # Detect unpushed commits from "[ahead N]" — no extra git call needed
  local suffix=""
  if [[ $branch == *"[ahead"* ]]; then
    suffix=" with %{$fg_bold[magenta]%}unpushed%{$reset_color%}"
  fi

  # Strip "...upstream [ahead N]" — keep only the branch name
  branch="${branch%%...*}"

  # Rebase in progress: git reports "HEAD (no branch)"
  if [[ $branch == "HEAD (no branch)"* ]]; then
    local rebase_branch
    rebase_branch=$($git branch 2>/dev/null | grep ' rebasing')
    if [[ -n $rebase_branch ]]; then
      branch=$(printf '%s\n' "$rebase_branch" | cut -d ' ' -f 5 | tr -d ')')
      suffix=" with %{$fg_bold[yellow]%}rebase in progress%{$reset_color%}"
    fi
  fi

  # WIP check — --pretty=%s avoids reading the full commit blob
  if $git log -n 1 --pretty=%s 2>/dev/null | grep -q -- '--wip--'; then
    suffix=" with %{$fg_bold[yellow]%}WIP%{$reset_color%}"
  fi

  # Dirty when there is any output after the first status line
  local dirty="${status_output#*$'\n'}"
  if [[ -z $dirty ]]; then
    _git_prompt_info=" on %{$fg_bold[green]%}${branch}%{$reset_color%}${suffix}"
  else
    _git_prompt_info=" on %{$fg_bold[red]%}${branch}%{$reset_color%}${suffix}"
  fi
}

_update_kube_prompt() {
  (( $+functions[kube_ps1] )) || return
  local kube_status
  # sed -E: strip the segment when both context and namespace are N/A
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
  # Color escapes are expanded once here (static); ${_git_prompt_info} etc.
  # are re-read at each render via PROMPT_SUBST at zero subprocess cost.
  # %1~  = last path component (zsh built-in)
  # %(?:X:Y) = conditional on last exit status (zsh built-in)
  # ${VAR:+text} = expand only when VAR is set (parameter expansion)
  export PROMPT="
%(?:%{$fg_bold[green]%}❯:%{$fg_bold[red]%}❯%s) \${_zmx_prompt_info}%{$fg_bold[blue]%}%1~%{$reset_color%}\${_git_prompt_info}\${_kube_prompt_info}
"
}
