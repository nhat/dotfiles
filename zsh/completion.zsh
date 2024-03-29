# matches case insensitive, if no upper chars
zstyle ':completion:*' completer _complete
zstyle ':completion:*' matcher-list \
  'l:|=* r:|=* m:{a-z\-}={A-Z\_}' \
  'r:[^[:alpha:]]||[[:alpha:]]=** r:|=* m:{a-z\-}={A-Z\_}' \
  'r:|?=** m:{a-z\-}={A-Z\_}'

eval $(gdircolors)
zstyle ':completion:*' list-colors "${(@s.:.)LS_COLORS}"     # use ls-colors for path completions
zstyle ':completion:*' insert-tab pending                    # pasting with tabs doesn't perform completion
zstyle ':completion:*' menu select
zstyle ':completion:*:functions' ignored-patterns '_*'
zstyle ':completion:*:(rm|kill|diff|trash):*' ignore-line yes
zstyle ':completion:*:*:(e|n(vi(m|))):*' ignored-patterns '.DS_Store|.localized'
zstyle ':completion::complete:*' use-cache 1

# organize completions by categories
zstyle ':completion:*' list-dirs-first true
zstyle ':completion:*' group-name ''

# fasd
fasd_cache="$HOME/.fasd-init-zsh"
if [ "$(command -v fasd)" -nt "$fasd_cache" -o ! -s "$fasd_cache" ]; then
    fasd --init zsh-hook zsh-ccomp zsh-ccomp-install zsh-wcomp zsh-wcomp-install >! "$fasd_cache"
fi
source "$fasd_cache"
unset fasd_cache

function fasd_cd() {
  if [ $# -le 1 ]; then
    fasd "$@"
  else
    local _fasd_ret="$(fasd -e 'printf %s' "$@")"
    [ -z "$_fasd_ret" ] && return
    [ -d "$_fasd_ret" ] && cd "$_fasd_ret" || printf %s\\n "$_fasd_ret"
  fi
}

# load smart urls if available
autoload -Uz is-at-least
for d in $fpath; do
  if [[ -e "$d/url-quote-magic" ]]; then
    autoload -Uz url-quote-magic
    zle -N self-insert url-quote-magic

    break
  fi
done

# parens ()
insert_parens() {
  LBUFFER+="()"
  zle backward-char
}
zle -N insert-parens insert_parens
bindkey "(" insert-parens

close_parens() {
  if [[ $RBUFFER[1] = ")" ]]; then
    zle forward-char
  else
    zle self-insert
  fi
}
zle -N close-parens close_parens
bindkey ")" close-parens

# braces {}
insert_braces() {
  LBUFFER+="{}"
  zle backward-char
}
zle -N insert-braces insert_braces
bindkey "{" insert-braces

close_braces() {
  if [[ $RBUFFER[1] = "}" ]]; then
    zle forward-char
  else
    zle self-insert
  fi
}
zle -N close-braces close_braces
bindkey "}" close-braces

# brackets []
insert_brackets() {
  LBUFFER+="[]"
  zle backward-char
}
zle -N insert-brackets insert_brackets
bindkey "[" insert-brackets

close_brackets() {
  if [[ $RBUFFER[1] = ']' ]]; then
    zle forward-char
  else
    LBUFFER+="]"
  fi
}
zle -N close-brackets close_brackets
bindkey "]" close-brackets

# quotes ''
insert_quotes() {
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
insert_double_quotes() {
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
