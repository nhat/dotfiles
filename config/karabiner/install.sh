mkdir -p "$HOME/.config/karabiner"
rm -f "$HOME/.config/karabiner/karabiner.json"
ln -s "$DOTFILES_ROOT/config/karabiner/karabiner.json" "$HOME/.config/karabiner/karabiner.json"
