if [[ -n $SSH_CONNECTION ]]; then
  export PS1='%n@%m: %1~ # '
else
  export PS1='%n: %1~ # '
fi

# Enable highlighters
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern)

# zsh-history-substring-search
source /usr/local/share/zsh-history-substring-search/zsh-history-substring-search.zsh
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND="none"
bindkey '^[OA' history-substring-search-up
bindkey '^[OB' history-substring-search-down

# ZSH completions
fpath=(/usr/local/share/zsh/site-functions /usr/local/share/zsh-completions $fpath)

# save current command and restore it after next command
bindkey '\033q' push-line-or-edit

# edit current command in editor
bindkey '\033v' edit-command-line

# binds hex 0x18 0x7f with deleting everything to the left of the cursor
bindkey '^X\x7f' backward-kill-line

# adds redo
bindkey '^X^_' redo

# change directories and open files when selected
fzf-open-file-or-dir() {
  local cmd="command find -L . \
    \\( -path '*/\\.*' -o -fstype 'dev' -o -fstype 'proc' \\) -prune \
    -o -type f -print \
    -o -type d -print \
    -o -maxdepth 5 \
    -o -type l -print 2> /dev/null | sed 1d | cut -b3-"
  local out=$(eval $cmd | fzf)

  if [ -f "$out" ]; then
    $EDITOR "$out" < /dev/tty
  elif [ -d "$out" ]; then
    cd "$out"
    zle reset-prompt
  fi
}
export FZF_DEFAULT_OPTS="
    --height 20% --reverse --exit-0
    --color=spinner:250,pointer:0,fg+:-1,bg+:-1,prompt:#625f50,hl+:#e75544,hl:#e75544,info:#fafafa
"
zle     -N   fzf-open-file-or-dir
bindkey '^P' fzf-open-file-or-dir

# zsh syntax highlight
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=green'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=green'

# history search multi word
zstyle ":history-search-multi-word" page-size "8"
zstyle ":history-search-multi-word" highlight-color "none"
zstyle ":plugin:history-search-multi-word" active "bg=237,fg=255"
zstyle ":plugin:history-search-multi-word" check-paths "no"

typeset -gA HSMW_HIGHLIGHT_STYLES
HSMW_HIGHLIGHT_STYLES[single-hyphen-option]="none"
HSMW_HIGHLIGHT_STYLES[double-hyphen-option]="none"
HSMW_HIGHLIGHT_STYLES[builtin]="fg=green"
HSMW_HIGHLIGHT_STYLES[single-quoted-argument]="fg=green"
HSMW_HIGHLIGHT_STYLES[double-quoted-argument]="fg=green"
HSMW_HIGHLIGHT_STYLES[variable]="none"

# jump list
export _Z_CMD='c'
. `brew --prefix`/etc/profile.d/z.sh

export LSCOLORS="exfxcxdxbxegedabagacad"
export CLICOLOR=true

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
