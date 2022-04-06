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
  gnu-sed
  the_silver_searcher
  java11
  fd
  php
  mas
)
for package in $packages; do
  brew install $package
done

# install casks
echo "Installing casks..."
brew tap homebrew/cask-fonts
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
  font-source-code-pro
  1password
  notunes
)
for cask in $casks; do
  brew install --cask $cask
done

# install apps from App Store
echo "Installing apps from App Store..."
mas install 1480933944 # Vimari
mas install 1365531024 # 1Blocker
mas install 1445328303 # prettyJSON
mas install 1543920362 # Displaperture

echo "Done"
exit 0
