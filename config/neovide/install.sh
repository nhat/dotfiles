#!/usr/bin/env zsh

mkdir -p "$HOME/.config/neovide"
ln -sf "$DOTFILES_ROOT/config/neovide/config.toml" "$HOME/.config/neovide/config.toml"
ln -sf "$DOTFILES_ROOT/config/neovide/icon.icns" "$HOME/.config/neovide/icon.icns"
