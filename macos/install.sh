#!/usr/bin/env zsh

# Set macOS defaults
if ! "$DOTFILES_ROOT/macos/set-defaults.sh"; then
  echo "Failed to set macOS defaults" >&2
  exit 1
fi

# Extend default key bindings
echo "Extending default key bindings..."
if ! [[ -d "$HOME/Library/KeyBindings" ]]; then
  mkdir "$HOME/Library/KeyBindings"
else
  echo "  KeyBindings directory already exists, skipping creation"
fi
ln -sf "$DOTFILES_ROOT/macos/DefaultKeyBinding.dict" "$HOME/Library/KeyBindings/DefaultKeyBinding.dict"
echo "  Default key bindings extended successfully"

# Install keyboard without German Umlauts
echo "Installing keyboard layout without German Umlauts..."
if ! [[ -f "/Library/Keyboard Layouts/US-with-German-Umlauts.bundle" ]]; then
  sudo cp -n -r "$DOTFILES_ROOT/macos/US-with-German-Umlauts.bundle" "/Library/Keyboard Layouts/"
  echo "  Keyboard layout installed successfully"
else
  echo "  US-with-German-Umlauts.bundle already exists, skipping copy"
fi

# Don't show last login message in terminal
echo "Configuring terminal to not show last login message..."
if ! [[ -f "$HOME/.hushlogin" ]]; then
  touch "$HOME/.hushlogin"
  echo "  .hushlogin created successfully"
else
  echo "  .hushlogin already exists, skipping creation"
fi

# Use Touch ID for sudo
echo "Configuring Touch ID for sudo..."
if ! grep -q "pam_tid.so" /etc/pam.d/sudo; then
  sudo cp /etc/pam.d/sudo /etc/pam.d/sudo.bak
  sudo sed -i "1a auth       sufficient     pam_tid.so" /etc/pam.d/sudo
  echo "  Added Touch ID to sudo"
else
  echo "  Touch ID already configured for sudo, skipping"
fi

# Make SF Mono available outside of Terminal.app
echo "Installing SF Mono font..."
cp -R /System/Applications/Utilities/Terminal.app/Contents/Resources/Fonts/ /Library/Fonts/

# Allow apps downloaded from anywhere
echo "Allowing apps downloaded from anywhere..."
sudo spctl --master-disable

