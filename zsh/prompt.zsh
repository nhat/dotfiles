autoload colors && colors
zmodload zsh/datetime
zmodload zsh/stat

if (( $+commands[git] )); then
  git="$commands[git]"
else
  git="/usr/bin/git"
fi

# Cached prompt fragments — updated asynchronously (git, kube) or in precmd (zmx).
typeset -g _git_prompt_info=""
typeset -g _git_prompt_fd=0
typeset -g _git_prompt_pid=0
typeset -g _git_prompt_last_pwd=""
typeset -g _git_prompt_last_time=0.0
typeset -g _git_prompt_dir=""       # .git path for _git_prompt_last_pwd
typeset -g _git_prompt_repo_root="" # working-tree root returned by _git_find_dir for fast cd detection
typeset -g _git_prompt_idx_mt=0     # .git/index mtime at last spawn
typeset -g _git_prompt_head_mt=0    # .git/HEAD mtime at last spawn
typeset -g _git_prompt_remote_ref_mt=0 # remote tracking loose ref mtime at last spawn
typeset -g _git_prompt_packed_mt=0     # .git/packed-refs mtime at last spawn
typeset -g _kube_prompt_info=""
typeset -g _kube_prompt_fd=0
typeset -g _kube_prompt_pid=0
typeset -g _kube_prompt_last_time=0.0
typeset -g _zmx_prompt_info=""
typeset -g _zle_editing=0  # set 1 by zle-line-init, 0 by zle-line-finish (config.zsh)

# --- Git (async) ---

# Walk up from $PWD to find the .git directory — no subprocess needed.
# Prints two lines: the git-dir path, then the working-tree root ($d).
# For normal repos $d/.git is a directory; for worktrees/submodules it is a file
# whose "gitdir:" line points to the real git dir. In both cases $d is the
# working-tree root, which is what _git_prompt_repo_root needs.
_git_find_dir() {
  local d=$PWD
  while [[ $d != / ]]; do
    if [[ -d $d/.git ]]; then
      print -- $d/.git
      print -- $d
      return
    elif [[ -f $d/.git ]]; then
      local line
      IFS= read -r line < $d/.git
      print -- ${line#gitdir: }   # worktree/submodule: "gitdir: /real/.git/..."
      print -- $d
      return
    fi
    d=${d:h}
  done
}

_compute_git_info() {
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
    local git_dir=$_git_prompt_dir rebase_head=""
    if [[ -f "$git_dir/rebase-merge/head-name" ]]; then
      rebase_head=$(<"$git_dir/rebase-merge/head-name")
    elif [[ -f "$git_dir/rebase-apply/head-name" ]]; then
      rebase_head=$(<"$git_dir/rebase-apply/head-name")
    fi
    if [[ -n $rebase_head ]]; then
      branch="${rebase_head##refs/heads/}"
      suffix=" with %{$fg_bold[yellow]%}rebase in progress%{$reset_color%}"
    fi
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
  zle -F "$fd" 2>/dev/null
  # _print_prompt_newline may have already cleaned this fd up; bail if so.
  (( _git_prompt_fd == fd )) || return
  IFS= read -r _git_prompt_info <&"$fd"
  exec {fd}<&-
  _git_prompt_fd=0
  _git_prompt_pid=0
  (( _zle_editing )) && [[ -z $BUFFER ]] && zle reset-prompt
}

_update_git_prompt() {
  # Re-resolve .git dir when directory changes.
  if [[ $PWD != $_git_prompt_last_pwd ]]; then
    _git_prompt_last_pwd=$PWD
    if [[ -n $_git_prompt_repo_root &&
          ($PWD == $_git_prompt_repo_root || $PWD == $_git_prompt_repo_root/*) ]]; then
      # Still inside the same repo — git dir is valid, just reset mtimes.
      _git_prompt_idx_mt=0
      _git_prompt_head_mt=0
      _git_prompt_remote_ref_mt=0
      _git_prompt_packed_mt=0
    else
      local find_output
      find_output=("${(@f)$(_git_find_dir)}")
      _git_prompt_dir=$find_output[1]
      _git_prompt_repo_root=$find_output[2]
      _git_prompt_idx_mt=0
      _git_prompt_head_mt=0
      _git_prompt_remote_ref_mt=0
      _git_prompt_packed_mt=0
    fi
  fi

  if [[ -z $_git_prompt_dir ]]; then
    [[ -n $_git_prompt_info ]] && _git_prompt_info=""
    return
  fi

  # Skip spawn if index, HEAD, and remote tracking refs are unchanged since the last spawn.
  # Require idx_mt != 0 so a zstat failure never falsely suppresses spawning.
  local idx_mt=0 head_mt=0
  zstat -A idx_mt  +mtime "$_git_prompt_dir/index" 2>/dev/null
  zstat -A head_mt +mtime "$_git_prompt_dir/HEAD"  2>/dev/null

  # Detect push: read HEAD inline to find the loose remote-tracking ref, also check packed-refs.
  local head_ref branch_name="" remote_ref_mt=0 packed_mt=0
  IFS= read -r head_ref <"$_git_prompt_dir/HEAD" 2>/dev/null
  [[ $head_ref == ref:\ refs/heads/* ]] && branch_name=${head_ref#ref: refs/heads/}
  [[ -n $branch_name ]] && \
    zstat -A remote_ref_mt +mtime "$_git_prompt_dir/refs/remotes/origin/$branch_name" 2>/dev/null
  zstat -A packed_mt +mtime "$_git_prompt_dir/packed-refs" 2>/dev/null

  # Force a recheck every 3 s regardless of mtime changes — working-tree edits
  # (unstaged modifications, new untracked files) don't touch the index or refs,
  # so mtime guards alone cannot detect the clean↔dirty transition.
  local force_recheck=0
  (( EPOCHREALTIME - _git_prompt_last_time >= 3.0 )) && force_recheck=1

  if (( !force_recheck && idx_mt && idx_mt == _git_prompt_idx_mt && head_mt == _git_prompt_head_mt && remote_ref_mt == _git_prompt_remote_ref_mt && packed_mt == _git_prompt_packed_mt )); then
    return
  fi

  # State changed — debounce rapid consecutive changes (e.g. git add + commit).
  # Don't commit the new mtimes yet: leave them stale so the next call retries.
  if (( EPOCHREALTIME - _git_prompt_last_time < 0.3 )); then
    return
  fi

  _git_prompt_idx_mt=$idx_mt
  _git_prompt_head_mt=$head_mt
  _git_prompt_remote_ref_mt=$remote_ref_mt
  _git_prompt_packed_mt=$packed_mt
  _git_prompt_last_time=$EPOCHREALTIME

  if (( _git_prompt_fd )); then
    zle -F "$_git_prompt_fd" 2>/dev/null
    exec {_git_prompt_fd}<&-
    _git_prompt_fd=0
  fi
  (( _git_prompt_pid )) && kill "$_git_prompt_pid" 2>/dev/null
  _git_prompt_pid=0

  exec {_git_prompt_fd}< <(_compute_git_info)
  _git_prompt_pid=$!

  if ! zle -F "$_git_prompt_fd" _git_prompt_callback 2>/dev/null; then
    # ZLE not yet active (first precmd at startup) — don't block.
    # Kill the subprocess, close the fd, and reset all state so the next
    # precmd (when ZLE is running) retries via the normal async path.
    (( _git_prompt_fd )) && exec {_git_prompt_fd}<&-
    _git_prompt_fd=0
    (( _git_prompt_pid )) && kill "$_git_prompt_pid" 2>/dev/null
    _git_prompt_pid=0
    _git_prompt_idx_mt=0
    _git_prompt_head_mt=0
    _git_prompt_remote_ref_mt=0
    _git_prompt_packed_mt=0
    _git_prompt_last_time=0
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
  zle -F "$fd" 2>/dev/null
  # _print_prompt_newline may have already cleaned this fd up; bail if so.
  (( _kube_prompt_fd == fd )) || return
  IFS= read -r _kube_prompt_info <&"$fd"
  exec {fd}<&-
  _kube_prompt_fd=0
  _kube_prompt_pid=0
  (( _zle_editing )) && [[ -z $BUFFER ]] && zle reset-prompt
}

_update_kube_prompt() {
  # Skip if last spawn was < 5s ago — kube context is global, not per-directory.
  if (( EPOCHREALTIME - _kube_prompt_last_time < 5.0 )); then
    return
  fi
  _kube_prompt_last_time=$EPOCHREALTIME

  if (( _kube_prompt_fd )); then
    zle -F "$_kube_prompt_fd" 2>/dev/null
    exec {_kube_prompt_fd}<&-
    _kube_prompt_fd=0
  fi
  (( _kube_prompt_pid )) && kill "$_kube_prompt_pid" 2>/dev/null
  _kube_prompt_pid=0

  exec {_kube_prompt_fd}< <(_compute_kube_info)
  _kube_prompt_pid=$!

  if ! zle -F "$_kube_prompt_fd" _kube_prompt_callback 2>/dev/null; then
    # ZLE not yet active — don't block. Kill subprocess, reset timer so next
    # precmd retries immediately via the normal async path.
    (( _kube_prompt_fd )) && exec {_kube_prompt_fd}<&-
    _kube_prompt_fd=0
    (( _kube_prompt_pid )) && kill "$_kube_prompt_pid" 2>/dev/null
    _kube_prompt_pid=0
    _kube_prompt_last_time=0
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

# Emit blank line before each prompt. The _zle_editing guard on async callbacks
# is the primary protection against spurious redraws; the fd cancellation here
# is defense-in-depth that also frees resources early.
_print_prompt_newline() {
  if (( _git_prompt_fd )); then
    zle -F "$_git_prompt_fd" 2>/dev/null
    exec {_git_prompt_fd}<&-
    _git_prompt_fd=0
    # Callback never fired — reset committed mtimes so next precmd re-spawns.
    _git_prompt_idx_mt=0
    _git_prompt_head_mt=0
    _git_prompt_remote_ref_mt=0
    _git_prompt_packed_mt=0
    _git_prompt_last_time=0
  fi
  (( _git_prompt_pid )) && kill "$_git_prompt_pid" 2>/dev/null
  _git_prompt_pid=0
  if (( _kube_prompt_fd )); then
    zle -F "$_kube_prompt_fd" 2>/dev/null
    exec {_kube_prompt_fd}<&-
    _kube_prompt_fd=0
    _kube_prompt_last_time=0
  fi
  (( _kube_prompt_pid )) && kill "$_kube_prompt_pid" 2>/dev/null
  _kube_prompt_pid=0
  print
}

precmd_functions+=(_print_prompt_newline _update_git_prompt _update_kube_prompt _update_zmx_prompt)

set_prompt() {
  PROMPT="%(?:%{$fg_bold[green]%}❯:%{$fg_bold[red]%}❯%s) \${_zmx_prompt_info}%{$fg_bold[blue]%}%1~%{$reset_color%}\${_git_prompt_info}\${_kube_prompt_info}
"
}

# Build the prompt template once at startup — precmd only updates the variables.
set_prompt
