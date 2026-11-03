# rex completions (cached). The cache takes the binary's mtime, so any update or
# rollback that changes the binary's mtime regenerates it, even an older build.
_rex_cache="$HOME/.rex-completion-zsh"
if (( $+commands[rex] )); then
  if [[ ! -s "$_rex_cache" || $commands[rex] -nt "$_rex_cache" || $commands[rex] -ot "$_rex_cache" ]]; then
    rex completion zsh >! "$_rex_cache" && touch -r "$commands[rex]" "$_rex_cache"
  fi
  source "$_rex_cache"
fi
unset _rex_cache
