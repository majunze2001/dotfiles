#!/usr/bin/env zsh

# Ensure zsh is available; if it isn't, install a relocatable static build into ~/.local
if ! command -v zsh >/dev/null 2>&1; then
  echo "zsh not found - installing a static build into ~/.local via zsh-bin..."
  mkdir -p "$HOME/.local/bin"
  installer="$(mktemp "${TMPDIR:-/tmp}/zsh-bin-install.XXXXXX")" || exit 1
  # zsh-bin provides relocatable static zsh binaries (no root required)
  if ! curl -fsSL https://raw.githubusercontent.com/romkatv/zsh-bin/master/install -o "$installer"; then
    echo "Error: failed to download the zsh-bin installer. Aborting." >&2
    exit 1
  fi
  # -d: install prefix (zsh lands in ~/.local/bin);  -e no: skip /etc/shells (no sudo/prompt)
  if ! sh "$installer" -d "$HOME/.local" -e no; then
    echo "Error: zsh-bin installation failed. Aborting." >&2
    rm -f "$installer"
    exit 1
  fi
  rm -f "$installer"
  export PATH="$HOME/.local/bin:$PATH"
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"  # persist for future bash sessions
  if ! command -v zsh >/dev/null 2>&1; then
    echo "Error: zsh still not on PATH after install. Aborting." >&2
    exit 1
  fi
fi

# Clone the bare repo
if [ -n "$SSH" ]; then
  git clone --bare git@github.com:majunze2001/dotfiles $HOME/.dotfiles
else
  git clone --bare https://github.com/majunze2001/dotfiles.git $HOME/.dotfiles
fi

# We use $HOME as working tree so we can use the dotfiles directly
git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME checkout unified

# Install packages, tools, etc
zsh $HOME/.dotmodules/install/all.sh
