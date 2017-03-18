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
brew install z
brew install zsh-history-substring-search
brew install zsh-syntax-highlighting
brew install jq
brew install curl
brew install grc
brew install trash
brew install tmux
brew install reattach-to-user-namespace
brew install git
brew install httpie
brew install homebrew/dupes/less

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
brew cask install java
brew cask install vlc
brew cask install sublime-text3
brew cask install spectacle
brew install neovim/neovim/neovim
brew cask install iterm2

exit 0
