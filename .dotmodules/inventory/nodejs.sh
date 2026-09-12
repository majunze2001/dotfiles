#!/usr/bin/env zsh

set -euo pipefail

VERSION=${VERSION:-"24"}
NVM_VERSION=${NVM_VERSION:-"v0.40.7"}

export NVM_DIR="$HOME/.nvm"

if [ ! -s "$NVM_DIR/nvm.sh" ]; then
  cd /tmp
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/$NVM_VERSION/install.sh | bash
fi

# nvm is a shell function rather than a binary, so it has to be sourced before use
\. "$NVM_DIR/nvm.sh"

nvm install "$VERSION"
nvm use "$VERSION"
# Persist the choice so future shells get this version without an explicit nvm use
nvm alias default "$VERSION"

if ! command -v node >/dev/null 2>&1; then
  echo "NVM install failed"
  exit 1
fi

node --version
