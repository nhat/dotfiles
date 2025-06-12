#!/usr/bin/env zsh
#
# macOS
#
# Set default configurations

# Set macOS defaults
$DOTFILES_ROOT/macos/set-defaults.sh

# Extend default key bindings
if ! [[ -d $HOME/Library/KeyBindings ]]; then
  mkdir $HOME/Library/KeyBindings
fi
if ! [[ -f $HOME/Library/KeyBindings/DefaultKeyBinding.dict ]]; then
  ln -s $DOTFILES_ROOT/macos/DefaultKeyBinding.dict $HOME/Library/KeyBindings/DefaultKeyBinding.dict
fi

# Install keyboard without German Umlauts
if ! [[ -f /Library/Keyboard\ Layouts/US-with-German-Umlauts.bundle ]]; then
    sudo cp -r $DOTFILES_ROOT/macos/US-with-German-Umlauts.bundle /Library/Keyboard\ Layouts/
fi

# Don't show last login message in terminal
if ! [[ -f $HOME/.hushlogin ]]; then
  touch $HOME/.hushlogin
fi

# Use touch id for sudo
if ! grep -q "pam_tid.so" /etc/pam.d/sudo; then
  sudo sed -i "1a auth       sufficient     pam_tid.so" /etc/pam.d/sudo
  echo Added TouchId to sudo
fi

# Make SF Mono available outside of Terminal.app
cp -R /System/Applications/Utilities/Terminal.app/Contents/Resources/Fonts/ /Library/Fonts/

# Allow apps downloaded from anywhere
sudo spctl --master-disable
