if [[ -n $SSH_CONNECTION ]]; then
  export PS1='%n@%m: %1~ # '
else
  export PS1='%n: %1~ # '
fi

# zsh syntax highlight
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern)
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=green'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=green'

# zsh-history-substring-search
source /usr/local/share/zsh-history-substring-search/zsh-history-substring-search.zsh
bindkey '^[OA' history-substring-search-up
bindkey '^[OB' history-substring-search-down
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND="fg=red"

# zsh completions
fpath=(/usr/local/share/zsh/site-functions /usr/local/share/zsh-completions $fpath)

# save current command and restore it after next command
bindkey '\033q' push-line-or-edit

# edit current command in editor
bindkey '\033v' edit-command-line

# binds hex 0x18 0x7f with deleting everything to the left of the cursor
bindkey '^X\x7f' backward-kill-line

# escape kills buffer
bindkey '\033' kill-buffer

# adds redo
bindkey '^X^_' redo

# faster escape timeout
KEYTIMEOUT=10

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
    e "$out" < /dev/tty
    local res="e"
  elif [ -d "$out" ]; then
    builtin cd "$out"
    local res="cd"
  else
      return 0
  fi

  zle push-line-or-edit
  print -s "$res $out"
  echo -ne "\033[38;5;2m$res\033[0m \033[4m$out\033[0m"
  zle accept-line
}
export FZF_DEFAULT_OPTS="
    --height 20% --reverse --exit-0
    --color=spinner:250,pointer:0,fg+:-1,bg+:-1,prompt:#625f50,hl+:#e75544,hl:#e75544,info:#fafafa
"
zle     -N   fzf-open-file-or-dir
bindkey '^P' fzf-open-file-or-dir

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

export LSCOLORS="ExGxFxDxCxDxDxhbhdacEc"
export CLICOLOR=true

# don't save wrong commands
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
