if [[ -n $SSH_CONNECTION ]]; then
  export PS1='%n@%m: %1~ # '
else
  export PS1='%n: %1~ # '
fi

# Enable highlighters
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern)

# ZSH completions
fpath=(/usr/local/share/zsh/site-functions /usr/local/share/zsh-completions $fpath)

# save current command and restore it after next command
bindkey '\033q' push-line-or-edit

# edit current command in editor
bindkey '\033v' edit-command-line

# binds hex 0x18 0x7f with deleting everything to the left of the cursor
bindkey "^X\\x7f" backward-kill-line

# adds redo
bindkey "^X^_" redo

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

unsetopt SHARE_HISTORY # don't share history between sessions
setopt NO_HIST_VERIFY # runs last command after enter
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
