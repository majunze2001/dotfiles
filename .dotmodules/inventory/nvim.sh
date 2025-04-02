#!/usr/bin/env bash

set -ev

VERSION=${VERSION:-v0.10.4}

unamestr="$(uname)"
if [[ "$unamestr" == "Darwin" ]]; then
  OS=macos-arm64
elif [[ "$unamestr" == "Linux" ]]; then
  OS=linux-x86_64
fi

# Get nvim release
cd /tmp
curl -LO https://github.com/neovim/neovim/releases/download/$VERSION/nvim-$OS.tar.gz
if [[ "$unamestr" == "Darwin" ]]; then
  xattr -c nvim-$OS.tar.gz || true
fi
tar xzf nvim-$OS.tar.gz
mkdir -p ~/.local

# Remove
rm -f ~/.local/bin/nvim    || true
rm -rf ~/.local/lib/nvim   || true
rm -rf ~/.local/share/nvim || true

# Install nvim
rsync -a nvim-$OS/* ~/.local/

# Cleanup
rm -rf nvim-$OS
