#!/bin/sh
#
# Vim
#
# This installs some of the common dependencies needed (or at least desired)
# using Vim.

# Install Vim packages manager
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
vim +PluginInstall +qall
