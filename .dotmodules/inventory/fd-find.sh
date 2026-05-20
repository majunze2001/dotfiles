#!/usr/bin/env bash

version=${version:-10.4.2}

if [[ $(uname -m) =~ ^(arm64|aarch64)$ ]]; then
  ARCH=aarch64
else
  ARCH=x86_64
fi

unamestr="$(uname)"
if [[ "$unamestr" == "Darwin" ]]; then
  target="$ARCH-apple-darwin"
elif [[ "$unamestr" == "Linux" ]]; then
  target="$ARCH-unknown-linux-musl"
fi

filename="fd-v$version-$target.tar.gz"

cd /tmp
curl -LO https://github.com/sharkdp/fd/releases/download/v$version/$filename
tar xzf $filename
mv fd-v$version-$target/fd "$HOME/.local/bin"
rm -r $filename fd-v$version-$target
