#!/usr/bin/env zsh

# Define base path
BASE_PATH="$HOME/.config/hammerspoon"

# Install Hammerspoon configuration
echo "Installing Hammerspoon configuration..."
mkdir -p "$BASE_PATH"
ln -sf "$DOTFILES_ROOT/config/hammerspoon/init.lua" "$BASE_PATH/init.lua"

# Make Hammerspoon use the config file in ~/.config/hammerspoon
echo "Setting Hammerspoon config file path to $BASE_PATH/"
defaults write org.hammerspoon.Hammerspoon MJConfigFile "$BASE_PATH/init.lua"

# Clone the Spoons repository
echo "\nCloning Spoons repository..."
mkdir -p "$BASE_PATH/Spoons"
cd "$BASE_PATH/Spoons"

BASE_URL="https://github.com/nhat/"
spoons=(
  "Marginator.spoon"
  "MoveWindow.spoon"
  "MoveSpace.spoon"
)

for spoon in "${spoons[@]}"; do
  TARGET_DIR="${spoon}"
  if [ -d "$TARGET_DIR" ]; then
    echo "Skipping $spoon: Directory already exists."
    continue
  fi

  REPO_URL="${BASE_URL}${spoon}.git"

  echo "Cloning $spoon..."
  if git clone "$REPO_URL" "$TARGET_DIR"; then
    echo "$spoon cloned successfully."
  else
    echo "Failed to clone $spoon." >&2
    exit 1
  fi
done
