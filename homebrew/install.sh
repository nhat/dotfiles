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
brew install grc coreutils spark trash tmux reattach-to-user-namespace git zsh z zsh-syntax-highlighting source-highlight
# Install cask packages
brew tap caskroom/cask
brew cask install provisionql qlcolorcode qlimagesize qlstephen quicklook-csv quicklook-json qlmarkdown
exit 0
