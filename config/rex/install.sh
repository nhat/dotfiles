#!/usr/bin/env zsh

mkdir -p "$HOME/.config/rex"
ln -sf "$DOTFILES_ROOT/config/rex/init.lua" "$HOME/.config/rex/init.lua"
ln -sf "$DOTFILES_ROOT/config/rex/fleet_toggle.lua" "$HOME/.config/rex/fleet_toggle.lua"
