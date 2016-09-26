if [[ -n $SSH_CONNECTION ]]; then
  export PS1='%m:%3~$(git_info_for_prompt)%# '
else
  export PS1='%3~$(git_info_for_prompt)%# '
fi

# Enable highlighters
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern)

# bind k and j for VI mode
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down

# ZSH completions
fpath=(/usr/local/share/zsh/site-functions /usr/local/share/zsh-completions $fpath)

# jump list
export _Z_CMD='c'
. `brew --prefix`/etc/profile.d/z.sh
# . ~/.dotfiles/bin/z.sh

export LSCOLORS="exfxcxdxbxegedabagacad"
export CLICOLOR=true

autoload -U $DOTFILES_ROOT/functions/*(:t)

HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

setopt NO_HIST_VERIFY # runs last command after enter
unsetopt SHARE_HISTORY # don't share history between sessions
setopt EXTENDED_HISTORY # add timestamps to history
setopt APPEND_HISTORY # adds history
setopt INC_APPEND_HISTORY  # adds history incrementally
setopt HIST_IGNORE_ALL_DUPS  # don't record dupes in history
setopt HIST_REDUCE_BLANKS

setopt NO_BG_NICE # don't nice background tasks
setopt NO_HUP
setopt NO_LIST_BEEP
setopt LOCAL_OPTIONS # allow functions to have local options
setopt LOCAL_TRAPS # allow functions to have local traps
setopt PROMPT_SUBST
setopt CORRECT
setopt COMPLETE_IN_WORD
setopt IGNORE_EOF
setopt MENU_COMPLETE # completion is always inserted completely
