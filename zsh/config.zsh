if [[ -n $SSH_CONNECTION ]]; then
  export PS1='%n@%m: %1~ # '
else
  export PS1='%n: %1~ # '
fi

export LSCOLORS="ExGxFxDxCxDxDxhbhdacEc"
export CLICOLOR=true

# faster escape timeout
KEYTIMEOUT=1

# use more word separators
WORDCHARS=''

# zsh completions
fpath=(/usr/local/share/zsh/site-functions $HOME/.zsh/completions $fpath)

# use emacs key bindings
bindkey -e

# save current command and restore it after next command
bindkey '^Q' push-line-or-edit

# edit current command in editor
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^[[13;5u' edit-command-line

# insert new line below
bindkey '^[^M' self-insert-unmeta

# insert parameter last command
bindkey '^[[13;2u' insert-last-word

# binds hex 0x18 0x7f with deleting everything to the left of the cursor
bindkey '^X\x7f' backward-kill-line

# escape kills buffer
bindkey '\033' kill-buffer

# adds redo
bindkey '^X^_' redo

# use emacs word movements
bindkey '^[f' emacs-forward-word
bindkey '^[b' emacs-backward-word

# yank and kill line from cursor
pb-kill-line () {
  zle kill-line
  echo -n $CUTBUFFER | pbcopy
}
zle -N pb-kill-line
bindkey '^K'   pb-kill-line

# yank and kill whole line
pb-kill-whole-line () {
  zle kill-whole-line
  echo -n $CUTBUFFER | pbcopy
}
zle -N pb-kill-whole-line
bindkey '^U'   pb-kill-whole-line

# use the vi navigation keys besides cursor keys in menu completion
zmodload zsh/complist
bindkey -M menuselect 'h' vi-backward-char        # left
bindkey -M menuselect 'k' vi-up-line-or-history   # up
bindkey -M menuselect 'l' vi-forward-char         # right
bindkey -M menuselect 'j' vi-down-line-or-history # bottom
bindkey -M menuselect '\033' undo
bindkey -M menuselect 'o' accept-and-infer-next-history

# put into application mode and validate ${terminfo}
if (( ${+terminfo[smkx]} )) && (( ${+terminfo[rmkx]} )); then
  function zle-line-init() {
    echoti smkx
  }
  zle -N zle-line-init

  function zle-line-finish() {
    echoti rmkx
  }
  zle -N zle-line-finish
fi

# home go to beginning of line
if [[ "${terminfo[khome]}" != "" ]]; then
  bindkey "${terminfo[khome]}" beginning-of-line
fi

# end go to end of line
if [[ "${terminfo[kend]}" != "" ]]; then
  bindkey "${terminfo[kend]}"  end-of-line
fi

# space do history expansion
bindkey ' ' magic-space

# ctrl-right move forward one word
bindkey '^[[1;5C' forward-word

# ctrl-left move backward one word
bindkey '^[[1;5D' backward-word

# shift-tab move through the completion menu backwards
if [[ "${terminfo[kcbt]}" != "" ]]; then
  bindkey "${terminfo[kcbt]}" reverse-menu-complete
fi

# backspace delete backward
bindkey '^?' backward-delete-char

# delete delete forward
if [[ "${terminfo[kdch1]}" != "" ]]; then
  bindkey "${terminfo[kdch1]}" delete-char
else
  bindkey "^[[3~" delete-char
  bindkey "^[3;5~" delete-char
  bindkey "\e[3~" delete-char
fi

# use fzf to find file or folder
fzf-find-file-or-folder() {
  local out=$(eval fd --hidden . $HOME | fzf)

  if [[ $BUFFER == "" ]]; then
    # open file or folder
    if [ -f "$out" ]; then
        BUFFER="e ${(q)out}"
    elif [ -d "$out" ]; then
        BUFFER="cd ${(q)out}"
    else
        return 0
    fi

    zle accept-line
  elif [[ $out != "" ]]; then
    # append to current buffer
    BUFFER+="${(q)out}"

    zle redisplay
    zle end-of-line
  else
    # do nothing
    zle redisplay
  fi
}
zle -N fzf-find-file-or-folder
bindkey '^P' fzf-find-file-or-folder

export FZF_DEFAULT_COMMAND='fd --hidden'
export FZF_DEFAULT_OPTS="
    --height 30% --reverse --exit-0
    --color=spinner:250,pointer:0,fg+:-1,bg+:-1,prompt:#625F50,hl+:#E75544,hl:#E75544,info:#FAFAFA
"

# zsh syntax highlight
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern)
typeset -gA ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=green'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=green'

# zsh-history-substring-search
zle -N history-substring-search-up
bindkey '^[OA' history-substring-search-up
zle -N history-substring-search-down
bindkey '^[OB' history-substring-search-down

HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND="bg=11"
HISTORY_SUBSTRING_SEARCH_FUZZY="true"

# history search multi word
zstyle ":history-search-multi-word" highlight-color "bg=11"
zstyle ":plugin:history-search-multi-word" active "bg=237,fg=255"
zstyle ":plugin:history-search-multi-word" check-paths "no"
bindkey "^R" history-search-multi-word

typeset -gA HSMW_HIGHLIGHT_STYLES
HSMW_HIGHLIGHT_STYLES[single-hyphen-option]="none"
HSMW_HIGHLIGHT_STYLES[double-hyphen-option]="none"
HSMW_HIGHLIGHT_STYLES[builtin]="fg=green"
HSMW_HIGHLIGHT_STYLES[single-quoted-argument]="fg=green"
HSMW_HIGHLIGHT_STYLES[double-quoted-argument]="fg=green"
HSMW_HIGHLIGHT_STYLES[variable]="none"

# zsh-autosuggestions
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE=fg=white
ZSH_AUTOSUGGEST_STRATEGY=match_prev_cmd
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20

# don't store invalid commands in history
zshaddhistory() {  whence ${${(z)1}[1]} >/dev/null || return 2 }
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

# disable flow control only in zsh prompt
ttyctl -f
setopt NO_FLOW_CONTROL

setopt NO_SHARE_HISTORY         # disable history sharing between sessions
setopt NO_HIST_VERIFY           # runs last command after enter
setopt EXTENDED_HISTORY         # add timestamps to history
setopt APPEND_HISTORY           # adds history
setopt HIST_IGNORE_ALL_DUPS     # disable dupes in history
setopt HIST_REDUCE_BLANKS

setopt NO_BG_NICE               # disable nice background tasks
setopt EXTENDED_GLOB
setopt GLOB_STAR_SHORT
setopt AUTO_CD
setopt NO_HUP
setopt NO_LIST_BEEP
setopt LOCAL_OPTIONS            # allow functions to have local options
setopt LOCAL_TRAPS              # allow functions to have local traps
setopt PROMPT_SUBST
setopt CORRECT
setopt COMPLETE_IN_WORD
setopt IGNORE_EOF
