# Auto-switch gh host based on current directory.
# Uses GH_HOST env var which gh respects for all commands.
_gh_host_chpwd() {
  if [[ "$PWD" == "$HOME/Developer/eBay/src"* ]]; then
    export GH_HOST=github.corp.ebay.com
  else
    unset GH_HOST
  fi
}

autoload -Uz add-zsh-hook
add-zsh-hook chpwd _gh_host_chpwd

# Run once on shell init so the current directory is already handled.
_gh_host_chpwd
