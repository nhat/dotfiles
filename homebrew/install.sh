#!/bin/sh
#
# homebrew

# check for Homebrew
if test ! $(which brew); then
  echo "Installing Homebrew for you"
  ruby -e "$(curl -fsSL https://raw.github.com/mxcl/homebrew/go)" > /tmp/homebrew-install.log
fi

# install Homebrew packages
brew install coreutils
brew install zsh
brew install fasd
brew install jq
brew install curl
brew install grc
brew install trash
brew install git
brew install git-delta
brew install fzf
brew install neovim
brew install getantibody/tap/antibody
brew install switchaudio-osx
brew install gnu-sed
brew install fd

# install cask packages
brew cask install alfred
brew cask install java11
brew cask install vlc
brew cask install vimr
brew cask install qlstephen
brew cask install apptrap
brew cask install rectangle
brew cask install iterm2

brew update && brew upgrade

exit 0
