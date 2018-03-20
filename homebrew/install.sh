#!/bin/sh
#
# homebrew
#
# this installs some of the common dependencies needed (or at least desired)
# using homebrew.

# check for homebrew
if test ! $(which brew); then
  echo "  Installing Homebrew for you."
  ruby -e "$(curl -fsSL https://raw.github.com/mxcl/homebrew/go)" > /tmp/homebrew-install.log
fi

# install homebrew packages
brew install coreutils
brew install zsh
brew install fasd
brew install jq
brew install curl
brew install grc
brew install trash
brew install git
brew install fzf
brew install neovim
brew install getantibody/tap/antibody
brew install switchaudio-osx
brew install fd

# install cask packages
brew tap caskroom/cask
brew tap caskroom/versions

brew cask install provisionql
brew cask install qlcolorcode
brew cask install qlimagesize
brew cask install qlstephen
brew cask install quicklook-csv
brew cask install quicklook-json
brew cask install qlmarkdown
brew cask install alfred
brew cask install dropbox
brew cask install java8
brew cask install vlc
brew cask install vimr
brew cask install apptrap
brew cask install spectacle
brew cask install iterm2

exit 0
