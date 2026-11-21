export PATH="$DOTFILES_ROOT/bin:/usr/local/bin:/usr/local/sbin:.:/opt/homebrew/bin:/opt/homebrew/opt/gnu-sed/libexec/gnubin:$HOME/Developer/bin:${KREW_ROOT:-$HOME/.krew}/bin:$HOME/go/bin:$PATH"

# Rex CLI. Rex adds this directory itself inside its own terminals; add it for
# shells started elsewhere (iTerm, tmux) so `rex` resolves everywhere.
_rex_bin="$HOME/Library/Application Support/com.superlogical.rex/RexServer/Versions/Current/Rex Server.app/Contents/MacOS"
[[ -d $_rex_bin && ":$PATH:" != *":$_rex_bin:"* ]] && path+=("$_rex_bin")
unset _rex_bin
