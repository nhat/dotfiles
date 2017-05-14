if [[ -n $SSH_CONNECTION ]]; then
  export PS1='%n@%m: %1~ # '
else
  export PS1='%n: %1~ # '
fi

export LSCOLORS="ExGxFxDxCxDxDxhbhdacEc"
export CLICOLOR=true

# homebrew
BREW=/usr/local/opt

# zsh syntax highlight
source $BREW/zsh-syntax-highlighting/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern)
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=green'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=green'

# zsh-history-substring-search
source $BREW/zsh-history-substring-search/zsh-history-substring-search.zsh
# source /usr/local/share/zsh-history-substring-search/zsh-history-substring-search.zsh
bindkey '^[OA' history-substring-search-up
bindkey '^[OB' history-substring-search-down
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND="bg=11"

# zsh completions
fpath=(/usr/local/share/zsh/site-functions /usr/local/share/zsh-completions $fpath)

# save current command and restore it after next command
bindkey '^Q' push-line-or-edit

# edit current command in editor
bindkey '^[[13;5u' edit-command-line

# insert new line below
bindkey '^[^M' vi-open-line-below

# insert parameter last command
bindkey '^[[13;2u' insert-last-word

# binds hex 0x18 0x7f with deleting everything to the left of the cursor
bindkey '^X\x7f' backward-kill-line

# escape kills buffer
bindkey '\033' kill-buffer

# adds redo
bindkey '^X^_' redo

# use the vi navigation keys besides cursor keys in menu completion
bindkey -M menuselect 'h' vi-backward-char        # left
bindkey -M menuselect 'k' vi-up-line-or-history   # up
bindkey -M menuselect 'l' vi-forward-char         # right
bindkey -M menuselect 'j' vi-down-line-or-history # bottom
bindkey -M menuselect '\033' undo
bindkey -M menuselect 'o' accept-and-infer-next-history

# faster escape timeout
KEYTIMEOUT=1

# change directories or open files when selected
fzf-open-file-or-dir() {
  if [[ $BUFFER != "" ]]; then
    zle push-line-or-edit
  fi

  local cmd="command find -L . \
    \\( -path '*/\\.*' -o -fstype 'dev' -o -fstype 'proc' \\) -prune \
    -o -type f -print \
    -o -type d -print \
    -o -maxdepth 7 \
    -o -type l -print 2> /dev/null | sed 1d | cut -b3-"
  local out=$(eval $cmd | fzf)

  if [ -f "$out" ]; then
    BUFFER="e ${(q)out}"
  elif [ -d "$out" ]; then
    BUFFER="cd ${(q)out}"
  else
      return 0
  fi

  zle accept-line
}
export FZF_DEFAULT_OPTS="
    --height 20% --reverse --exit-0
    --color=spinner:250,pointer:0,fg+:-1,bg+:-1,prompt:#625F50,hl+:#E75544,hl:#E75544,info:#FAFAFA
"
zle     -N   fzf-open-file-or-dir
bindkey '^P' fzf-open-file-or-dir

# history search multi word
zstyle ":history-search-multi-word" highlight-color "bg=11"
zstyle ":plugin:history-search-multi-word" active "bg=237,fg=255"
zstyle ":plugin:history-search-multi-word" check-paths "no"

typeset -gA HSMW_HIGHLIGHT_STYLES
HSMW_HIGHLIGHT_STYLES[single-hyphen-option]="none"
HSMW_HIGHLIGHT_STYLES[double-hyphen-option]="none"
HSMW_HIGHLIGHT_STYLES[builtin]="fg=green"
HSMW_HIGHLIGHT_STYLES[single-quoted-argument]="fg=green"
HSMW_HIGHLIGHT_STYLES[double-quoted-argument]="fg=green"
HSMW_HIGHLIGHT_STYLES[variable]="none"

# don't store invalid commands in history
zshaddhistory() {  whence ${${(z)1}[1]} >/dev/null || return 2 }
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

unsetopt SHARE_HISTORY # don't share history between sessions
setopt NO_HIST_VERIFY # runs last command after enter
setopt EXTENDED_HISTORY # add timestamps to history
setopt APPEND_HISTORY # adds history
setopt HIST_IGNORE_ALL_DUPS  # don't record dupes in history
setopt HIST_REDUCE_BLANKS

setopt GLOBDOTS # matches files beginning with a . without specifying the dot
setopt NOCLOBBER # don't overwrite existing files
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
