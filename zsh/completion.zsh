# matches case insensitive, if no upper chars
zstyle ':completion:*' completer _complete
zstyle ':completion:*' matcher-list \
  'm:{a-z\-}={A-Z\_}' \
  'r:[^[:alpha:]]||[[:alpha:]]=** r:|=* m:{a-z\-}={A-Z\_}' \
  'r:|?=** m:{a-z\-}={A-Z\_}'

# use ls-colors for path completions
eval $(gdircolors)
zstyle ':completion:*' list-colors "${(@s.:.)LS_COLORS}"

# pasting with tabs doesn't perform completion
zstyle ':completion:*' insert-tab pending

# enable ../ completion
zstyle ':completion:*' special-dirs true


# parens ()
function insert_parens() {
  LBUFFER+="()"
  zle backward-char
}
zle -N insert-parens insert_parens
bindkey "(" insert-parens

function close_parens() {
  if [[ $RBUFFER[1] = ")" ]]; then
    zle forward-char
  else
    zle self-insert
  fi
}
zle -N close-parens close_parens
bindkey ")" close-parens

# braces {}
function insert_braces() {
  LBUFFER+="{}"
  zle backward-char
}
zle -N insert-braces insert_braces
bindkey "{" insert-braces

function close_braces() {
  if [[ $RBUFFER[1] = "}" ]]; then
    zle forward-char
  else
    zle self-insert
  fi
}
zle -N close-braces close_braces
bindkey "}" close-braces

# brackets []
function insert_brackets() {
  LBUFFER+="[]"
  zle backward-char
}
zle -N insert-brackets insert_brackets
bindkey "[" insert-brackets

function close_brackets() {
  if [[ $RBUFFER[1] = ']' ]]; then
    zle forward-char
  else
    LBUFFER+="]"
  fi
}
zle -N close-brackets close_brackets
bindkey "]" close-brackets

# quotes ''
function insert_quotes() {
  if [[ $RBUFFER[1] = "'" ]]; then
    zle forward-char
  elif [[ "$LBUFFER" = "${LBUFFER%[[:blank:]]}" ]] || [[ $RBUFFER[1] != '' ]]; then
    zle self-insert
  else
    LBUFFER+="''"
    zle backward-char
  fi
}
zle -N insert-quotes insert_quotes
bindkey "'" insert-quotes

# double quotes ""
function insert_double_quotes() {
  if [[ $RBUFFER[1] = '"' ]]; then
    zle forward-char
  elif [[ "$LBUFFER" = "${LBUFFER%[[:blank:]]}" ]] || [[ $RBUFFER[1] != '' ]]; then
    zle self-insert
  else
    LBUFFER+='""'
    zle backward-char
  fi
}
zle -N insert-double-quotes insert_double_quotes
bindkey '"' insert-double-quotes
