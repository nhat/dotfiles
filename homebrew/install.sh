#!/bin/sh
#
# Homebrew
#
# This installs some of the common dependencies needed (or at least desired)
# using Homebrew.

# Check for Homebrew
if test ! $(which brew)
then
  echo "  Installing Homebrew for you."
  ruby -e "$(curl -fsSL https://raw.github.com/mxcl/homebrew/go)" > /tmp/homebrew-install.log
fi

# Install homebrew packages
brew install grc
brew install coreutils
brew install spark
brew install trash
brew install tmux
brew install reattach-to-user-namespace
brew install git
brew install zsh
brew install z
brew install zsh-syntax-highlighting
brew install source-highlight
brew install httpie

# Install cask packages
brew tap caskroom/cask
brew tap caskroom/versions

brew cask install provisionql
brew cask install qlcolorcode
brew cask install qlimagesize
brew cask install qlstephen
brew cask install quicklook-csv
brew cask install quicklook-json
brew cask install qlmarkdown
brew cask install seil
brew cask install karabiner
brew cask install alfred
brew cask install dropbox
brew cask install java
brew cask install vlc
brew cask install sublime-text3

exit 0
