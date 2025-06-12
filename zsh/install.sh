#!/bin/zsh
#
# zsh
#
# Install zsh plugins

if ! [ -d "$HOME/.zsh" ]; then
  mkdir $HOME/.zsh
fi
echo "💻 Installing zsh plugins"
source $(brew --prefix)/opt/antidote/share/antidote/antidote.zsh
antidote bundle < $DOTFILES_ROOT/zsh/plugins > ~/.zsh/.zsh_plugins && antidote update
echo -e "Done\n"

# Turn off kubernetes info in prompt
kubeoff -g

