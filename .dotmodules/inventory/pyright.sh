#!/usr/bin/env zsh

set -euo pipefail

VERSION=${VERSION:-"23"}

if [[ $(uname -m) = arm64 ]]; then
  ARCH=arm64
else
  ARCH=x64
fi

KERNEL="$(uname | awk '{print tolower($0)}')"

if ! command -v node 2>&1 > /dev/null; then
  cd /tmp
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.2/install.sh | bash
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  nvm install $VERSION
  nvm use $VERSION
  if ! command -v node 2>&1 > /dev/null; then
    echo "NVM install failed"
    exit 1
  fi
fi

npm install -g pyright
