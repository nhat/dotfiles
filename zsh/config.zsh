if [[ -n $SSH_CONNECTION ]]; then
  export PS1='%n@%m: %1~ # '
else
  export PS1='%n: %1~ # '
fi

export LSCOLORS="ExGxFxDxCxDxDxhbhdacEc"
export CLICOLOR=true
export HOMEBREW_NO_ENV_HINTS=true

# faster escape timeout
KEYTIMEOUT=1

# use more word separators
WORDCHARS=''

# zsh completions
fpath=($HOME/.zsh/completions $fpath)

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
bindkey '^K' pb-kill-line

# yank and kill whole line
pb-kill-whole-line () {
  zle kill-whole-line
  echo -n $CUTBUFFER | pbcopy
}
zle -N pb-kill-whole-line
bindkey '^U' pb-kill-whole-line

# use the vi navigation keys besides cursor keys in menu completion
zmodload zsh/complist
bindkey -M menuselect 'h' vi-backward-char        # left
bindkey -M menuselect 'k' vi-up-line-or-history   # up
bindkey -M menuselect 'l' vi-forward-char         # right
bindkey -M menuselect 'j' vi-down-line-or-history # bottom
bindkey -M menuselect '\033' undo
bindkey -M menuselect 'o' accept-and-infer-next-history
bindkey -M menuselect '^M' .accept-line

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
fd --hidden --strip-cwd-prefix | fzf --header="(Press again to search in home folder)" > /tmp/fzf_selection \
    --bind 'ctrl-p:execute(fd --hidden . $HOME | fzf --height 100% --prompt="🔍 ${HOME##*/} " > /tmp/fzf_selection)+abort'
  local out=$(cat /tmp/fzf_selection)

  # output with full escaped path
  local result="$(printf "%q\n" "$(pwd)")/${(q)out}"
  if [[ $out == /* ]]; then
    result=${(q)out}
  fi

  if [[ $BUFFER == "" ]]; then
    # open file or folder
    if [[ -f $out ]]; then
      BUFFER="e $result"
    elif [[ -d $out ]]; then
      BUFFER="cd $result"
    else
      return 0
    fi

    zle accept-line
  elif [[ $out != "" ]]; then
    # append to current buffer
    LBUFFER+="$result"

    zle redisplay
  else
    # do nothing
    zle redisplay
  fi
}
zle -N fzf-find-file-or-folder
bindkey '^P' fzf-find-file-or-folder

# transform current word to upper or lower case
transform-current-word-case() {
	local currentword="${LBUFFER/*[ |\/|\.|\-]/}${RBUFFER/[ |\/|.|\-]*/}"

	if [[ $currentword == ${currentword:l} ]]; then
		BUFFER=${BUFFER/$currentword/${currentword:u}}
	else
		BUFFER=${BUFFER/$currentword/${currentword:l}}
	fi

	zle redisplay
}
zle -N transform-current-word-case
bindkey '^[u' transform-current-word-case

# don't store invalid commands in history
zshaddhistory() {  whence ${${(z)1}[1]} >/dev/null || return 2 }
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt NO_HIST_VERIFY           # runs last command after enter
setopt EXTENDED_HISTORY         # add timestamps to history
setopt INC_APPEND_HISTORY       # save commands as soon as they are entered
setopt HIST_IGNORE_ALL_DUPS     # disable dupes in history
setopt SHARE_HISTORY            # share history between sessions
setopt HIST_REDUCE_BLANKS
setopt HIST_IGNORE_SPACE        # ignore a command starting with a space
setopt INTERACTIVE_COMMENTS     # add hash to write comment

# disable flow control only in zsh prompt
ttyctl -f
setopt NO_FLOW_CONTROL
setopt NO_BG_NICE               # disable nice background tasks
setopt EXTENDED_GLOB
setopt GLOB_STAR_SHORT          # **/* can be abbreviated to **
setopt GLOBDOTS                 # match files and folders starting with dot
setopt AUTO_CD
setopt NO_HUP
setopt NO_BEEP
setopt LOCAL_OPTIONS            # allow functions to have local options
setopt LOCAL_TRAPS              # allow functions to have local traps
setopt MENU_COMPLETE            # select first completion
setopt PROMPT_SUBST
setopt CORRECT
setopt COMPLETE_IN_WORD
setopt IGNORE_EOF
