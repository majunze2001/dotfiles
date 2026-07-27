#!/usr/bin/env zsh

pprint() {
  printf "%*s\n" $(( (${#1} + $(tput cols) * 2 / 3) / 2 )) "$1"
}

installing() {
  pprint "#################################################"
  pprint "Installing $1"
  pprint "#################################################"
}

# Check and install Rust
if ! command -v rustc >/dev/null 2>&1; then
  installing "Rust"
  curl --proto '=https' --tlsv1.2 https://sh.rustup.rs -sSf | sh -s -- -y
  source "$HOME/.cargo/env"
else
  pprint "Rust is already installed. Skipping."
fi

if ! command -v rg >/dev/null 2>&1; then
  installing "ripgrep"
  cargo install ripgrep
else
  pprint "ripgrep is already installed. Skipping."
fi

if ! command -v fd >/dev/null 2>&1; then
  installing "fd"
  cargo install fd-find
else
  pprint "fd is already installed. Skipping."
fi

installing "eza"
cargo install eza
