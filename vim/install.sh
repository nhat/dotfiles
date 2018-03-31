#!/bin/sh
#
# Vim
#
# This installs some of the common dependencies needed (or at least desired)
# using Vim.

# Install Vim packages manager
curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
nvim +PlugClean +PlugInstall +qall
