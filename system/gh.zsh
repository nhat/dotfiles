# Auto-switch gh host based on current directory.
# Uses GH_HOST env var which gh respects for all commands.
# Set WORK_GH_HOST and WORK_GH_DIR in ~/.localrc to configure.
_gh_host_chpwd() {
  if [[ -n "$WORK_GH_HOST" && -n "$WORK_GH_DIR" && "$PWD" == "$WORK_GH_DIR"* ]]; then
    export GH_HOST=$WORK_GH_HOST
  else
    unset GH_HOST
  fi
}

autoload -Uz add-zsh-hook
add-zsh-hook chpwd _gh_host_chpwd

# Run once on shell init so the current directory is already handled.
_gh_host_chpwd
