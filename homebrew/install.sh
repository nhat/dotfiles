#!/bin/zsh
#
# homebrew

echo "🍺 Setting up Homebrew"
# check for Homebrew
if test ! $(which brew); then
  echo "Installing Homebrew for you"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# install packages
echo "Installing packages..."
packages=(
  coreutils
  gnu-sed
  zsh
  fasd
  jq
  curl
  grc
  trash
  git
  git-delta
  fzf
  neovim
  getantibody/tap/antibody
  source-highlight
  switchaudio-osx
  the_silver_searcher
  java11
  fd
  php
  mas
  maven
)
for package in $packages; do
  brew install $package
done

# install casks
echo "Installing casks..."
casks=(
  alfred
  karabiner-elements
  vlc
  vimr
  qlstephen
  apptrap
  rectangle
  iterm2
  fantastical
  1password
  notunes
  bartender
  shottr
  intellij-idea
)
for cask in $casks; do
  brew install --cask $cask
done

# install apps from App Store
echo "Installing apps from App Store..."
apps=(
  1480933944 # Vimari
  1365531024 # 1Blocker
  1445328303 # prettyJSON
  1118136179 # AutoMute
  688211836  # EasyRes
  1543920362 # Displaperture
  1568262835 # Super Agent
)
for app in $apps; do
  mas install $app
done

echo "Done"
exit 0
