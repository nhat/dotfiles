#!/usr/bin/env bash
# Sets Neovide as the default editor for common text and source file types.
# Skips silently if duti or Neovide is not installed.

if ! command -v duti &>/dev/null; then
  echo "duti not found, skipping file handler setup"
  exit 0
fi

if ! /usr/bin/mdls -name kMDItemCFBundleIdentifier /Applications/Neovide.app &>/dev/null; then
  echo "Neovide not found, skipping file handler setup"
  exit 0
fi

for ext in txt md markdown json yaml yml toml xml sh zsh bash py rb js ts tsx css lua vim conf cfg log; do
  duti -s com.neovide.neovide "$ext" editor
done

echo "Neovide set as default editor for text and source file types."
