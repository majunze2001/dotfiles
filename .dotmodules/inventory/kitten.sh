#!/usr/bin/env bash

set -e

version=${version:-0.47.4}

if [[ $(uname -m) =~ ^(arm64|aarch64)$ ]]; then
  ARCH=arm64
else
  ARCH=x86_64
fi

filename="kitty-$version-$ARCH.txz"

cd /tmp
curl -LO https://github.com/kovidgoyal/kitty/releases/download/v$version/$filename

# The tarball extracts to a full kitty.app tree (bin/kitty, bin/kitten, lib, share).
# kitten relies on the surrounding app tree, so install the whole thing and symlink.
rm -rf "$HOME/.local/kitty.app"
mkdir -p "$HOME/.local/kitty.app"
tar xJf $filename -C "$HOME/.local/kitty.app"

ln -sf "$HOME/.local/kitty.app/bin/kitten" "$HOME/.local/bin/kitten"

rm $filename
