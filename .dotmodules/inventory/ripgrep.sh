#!/usr/bin/env bash

version=${version:-15.1.0}

if [[ $(uname -m) =~ ^(arm64|aarch64)$ ]]; then
  ARCH=aarch64
else
  ARCH=x86_64
fi

unamestr="$(uname)"
if [[ "$unamestr" == "Darwin" ]]; then
  target="$ARCH-apple-darwin"
elif [[ "$unamestr" == "Linux" ]]; then
  # ripgrep only ships musl for x86_64; aarch64 Linux is gnu-only
  if [[ "$ARCH" == "aarch64" ]]; then
    target="aarch64-unknown-linux-gnu"
  else
    target="x86_64-unknown-linux-musl"
  fi
fi

filename="ripgrep-$version-$target.tar.gz"

cd /tmp
curl -LO https://github.com/BurntSushi/ripgrep/releases/download/$version/$filename
tar xzf $filename
mv ripgrep-$version-$target/rg "$HOME/.local/bin"
rm -r $filename ripgrep-$version-$target
