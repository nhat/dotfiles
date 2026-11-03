# rex completions (cached, regenerate when the rex binary changes)
_rex_cache="$HOME/.rex-completion-zsh"
if (( $+commands[rex] )); then
  if [[ ! -s "$_rex_cache" || $commands[rex] -nt "$_rex_cache" ]]; then
    rex completion zsh >! "$_rex_cache"
  fi
  source "$_rex_cache"
fi
unset _rex_cache
