#!/bin/bash
# Install the Buildkite CLI (bk) to ~/.local/bin without sudo.
set -euo pipefail

DEST="$HOME/.local/bin"
mkdir -p "$DEST"

# Resolve OS/arch to a release asset name.
os="$(uname -s)"
arch="$(uname -m)"
case "$os" in
  Linux)  plat="linux" ;;
  Darwin) plat="macOS" ;;
  *) echo "Unsupported OS: $os"; exit 1 ;;
esac
case "$arch" in
  x86_64|amd64)  arch="amd64" ;;
  aarch64|arm64) arch="arm64" ;;
  *) echo "Unsupported arch: $arch"; exit 1 ;;
esac

# Find the latest release tag.
tag="$(curl -fsSL https://api.github.com/repos/buildkite/cli/releases/latest \
  | grep '"tag_name"' | cut -d'"' -f4)"
version="${tag#v}"
echo "Installing bk $version ($plat/$arch)..."

# Linux ships tar.gz, macOS ships zip.
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
if [ "$plat" = "linux" ]; then
  curl -fsSL "https://github.com/buildkite/cli/releases/download/$tag/bk_${version}_${plat}_${arch}.tar.gz" \
    | tar -xz -C "$tmp"
else
  curl -fsSL "https://github.com/buildkite/cli/releases/download/$tag/bk_${version}_${plat}_${arch}.zip" \
    -o "$tmp/bk.zip"
  unzip -q -o "$tmp/bk.zip" -d "$tmp"
fi

install -m 0755 "$(find "$tmp" -type f -name bk | head -1)" "$DEST/bk"
echo "Installed: $("$DEST/bk" version)"
echo "Ensure $DEST is on your PATH."
