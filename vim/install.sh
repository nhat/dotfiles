#!/bin/zsh
#
# NeoVim
#
# This installs some of the common dependencies needed (or at least desired)
# using NeoVim.

# Install packages manager
echo "Setting up NeoVim"
echo "  Downloading plug.vim"
curl -sfLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Install plugins
echo "  Installing plugins"
nvim +PlugClean +PlugInstall +qall

# link vim and nvim config
if ! [ -f ~/.config/nvim/init.vim ]; then
  echo "  Linking Vim config with NeoVim"
  ln -s ~/.vimrc ~/.config/nvim/init.vim
fi

echo "Done"
