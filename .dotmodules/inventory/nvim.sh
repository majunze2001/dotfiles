#!/usr/bin/env bash

set -ev

VERSION=${VERSION:-v0.12.6}

unamestr="$(uname)"
archstr="$(uname -m)"
if [[ "$unamestr" == "Darwin" ]]; then
  OS=macos-arm64
elif [[ "$unamestr" == "Linux" ]]; then
  if [[ "$archstr" == "aarch64" || "$archstr" == "arm64" ]]; then
    OS=linux-arm64
  else
    OS=linux-x86_64
  fi
fi

# Get nvim release
cd /tmp
curl -LO https://github.com/neovim/neovim/releases/download/$VERSION/nvim-$OS.tar.gz
if [[ "$unamestr" == "Darwin" ]]; then
  xattr -c nvim-$OS.tar.gz || true
fi
tar xzf nvim-$OS.tar.gz
mkdir -p ~/.local

# Remove the previous install. Only share/nvim/runtime comes from the tarball; the rest of
# share/nvim is stdpath('data') (lazy plugins, treesitter parsers, undodir) and must survive.
rm -f ~/.local/bin/nvim             || true
rm -rf ~/.local/lib/nvim            || true
rm -rf ~/.local/share/nvim/runtime  || true

# Install nvim
rsync -a nvim-$OS/* ~/.local/

# Cleanup
rm -rf nvim-$OS
