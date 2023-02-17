#!/bin/zsh
#
# zsh
#
# Install zsh plugins

if ! [ -d "$HOME/.zsh" ]; then
  mkdir $HOME/.zsh
fi
echo "💻 Installing zsh plugins"
antibody bundle < $DOTFILES_ROOT/zsh/plugins > ~/.zsh/.zsh_plugins && antibody update
echo -e "Done\n"

# Turn off kubernetes info in prompt
kubeoff -g

