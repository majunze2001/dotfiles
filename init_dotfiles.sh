#!/bin/zsh

alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME' # later done in .zshrc
dotfiles config --local status.showUntrackedFiles no # settings kept in .dotfiles/config
