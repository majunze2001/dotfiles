#!/usr/bin/env zsh

# Check if zsh is installed
if ! command -v zsh >/dev/null 2>&1; then
  echo "Error: zsh is not installed. Aborting."
  exit 1
fi

# Clone the bare repo
if [ -n "$SSH" ]; then
  git clone --bare git@github.com:majunze2001/dotfiles $HOME/.dotfiles
else
  git clone --bare https://github.com/majunze2001/dotfiles.git $HOME/.dotfiles
fi

# We use $HOME as working tree so we can use the dotfiles directly
git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME checkout unified

# Install packages, tools, etc
zsh $HOME/.dotmodules/install/all.sh
