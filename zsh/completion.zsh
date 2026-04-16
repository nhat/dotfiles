# matches case insensitive, if no upper chars
zstyle ':completion:*' completer _complete
zstyle ':completion:*' matcher-list \
  'l:|=* r:|=* m:{a-z\-}={A-Z\_}' \
  'r:[^[:alpha:]]||[[:alpha:]]=** r:|=* m:{a-z\-}={A-Z\_}' \
  'r:|?=** m:{a-z\-}={A-Z\_}'

# Cache gdircolors output — avoids forking a subprocess every startup
_gdircolors_cache="$HOME/.gdircolors.zsh"
if [[ ! -f "$_gdircolors_cache" ]]; then
  gdircolors > "$_gdircolors_cache"
fi
source "$_gdircolors_cache"
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

# zoxide — fast directory jumping (replaces fasd)
_zoxide_cache="$HOME/.zoxide-init-zsh"
if [[ ! -s "$_zoxide_cache" || "$(command -v zoxide)" -nt "$_zoxide_cache" ]]; then
  zoxide init zsh >! "$_zoxide_cache"
fi
source "$_zoxide_cache"
unset _zoxide_cache

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
