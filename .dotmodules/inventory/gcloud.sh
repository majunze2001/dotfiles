#!/usr/bin/env zsh

set -euo pipefail

PREFIX=${PREFIX:-"$HOME/.local"}
SDK_DIR="$PREFIX/google-cloud-sdk"

# gcloud's shell preamble only accepts interpreters in [3.9, 3.14], so this has to
# stay on 3.14.x -- a 3.15 build would be rejected outright.
PYTHON_VERSION=${PYTHON_VERSION:-"3.14.7"}
PYTHON_BUILD=${PYTHON_BUILD:-"20260901"}
PYTHON_MM="${PYTHON_VERSION%.*}"

if [ "$(uname)" != "Darwin" ]; then
  echo "gcloud.sh supports macOS only"
  exit 1
fi

if [ "$(uname -m)" = arm64 ]; then
  SDK_ARCH=arm        # Google publishes Apple Silicon as "arm", not "arm64"
  PY_ARCH=aarch64
else
  SDK_ARCH=x86_64
  PY_ARCH=x86_64
fi

SDK_TARBALL="google-cloud-cli-darwin-$SDK_ARCH.tar.gz"
PY_TARBALL="cpython-$PYTHON_VERSION+$PYTHON_BUILD-$PY_ARCH-apple-darwin-install_only.tar.gz"

cd /tmp
curl -fLO "https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/$SDK_TARBALL"
curl -fLO "https://github.com/astral-sh/python-build-standalone/releases/download/$PYTHON_BUILD/$PY_TARBALL"

# Extracting over an existing tree leaves stale files behind, so start clean
rm -rf "$SDK_DIR"
mkdir -p "$PREFIX"
tar xzf "$SDK_TARBALL" -C "$PREFIX"

# macOS ships python 3.9, which gcloud's vendored urllib3 no longer parses, and
# Google's bundled-python component for darwin is a 111-byte empty stub. Supply a
# standalone interpreter inside the SDK so the install stays self-contained.
rm -rf /tmp/gcloud-python
mkdir -p /tmp/gcloud-python
tar xzf "$PY_TARBALL" -C /tmp/gcloud-python
mv /tmp/gcloud-python/python "$SDK_DIR/platform/bundledpythonunix"
rm -rf /tmp/gcloud-python "$SDK_TARBALL" "$PY_TARBALL"

# install.sh only auto-detects the bundled interpreter when uname -m is x86_64,
# so Apple Silicon has to be pointed at it explicitly.
CLOUDSDK_PYTHON="$SDK_DIR/platform/bundledpythonunix/bin/python3" "$SDK_DIR/install.sh" \
  --quiet \
  --usage-reporting false \
  --path-update false \
  --command-completion false \
  --install-python false

# The wrapper follows symlinks back to the SDK root, so linking the binaries out of
# the tree is safe. python3.14 goes along because it is the first interpreter gcloud
# looks for on PATH, which is what saves us exporting CLOUDSDK_PYTHON at runtime.
mkdir -p "$PREFIX/bin"
for binary in "$SDK_DIR"/bin/*; do
  if [ -f "$binary" ] && [ -x "$binary" ]; then
    ln -sf "$binary" "$PREFIX/bin/$(basename "$binary")"
  fi
done
ln -sf "$SDK_DIR/platform/bundledpythonunix/bin/python$PYTHON_MM" "$PREFIX/bin/python$PYTHON_MM"

"$PREFIX/bin/gcloud" version
