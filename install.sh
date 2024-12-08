#!/usr/bin/env zsh

if [ -n "$SSH" ]; then
  git clone --bare git@github.com:majunze2001/dotfiles $HOME/.dotfiles
else
  git clone --bare https://github.com/majunze2001/dotfiles.git $HOME/.dotfiles
fi

git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME checkout unified
zsh $HOME/.dotmodules/install/all.sh
