mkdir -p $HOME/.config/hammerspoon
ln -sf $DOTFILES_ROOT/config/hammerspoon/init.lua $HOME/.config/hammerspoon/init.lua

# make hammerspoon use the config file in ~/.config/hammerspoon
defaults write org.hammerspoon.Hammerspoon MJConfigFile "~/.config/hammerspoon/init.lua"

