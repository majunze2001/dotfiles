#!/usr/bin/env zsh

pprint() {
  printf "%*s\n" $(( (${#1} + $(tput cols) * 2 / 3) / 2 )) "$1"
}

installing() {
  pprint "#################################################"
  pprint "Installing $1"
  pprint "#################################################"
}

# Install Oh-my-zsh
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  installing "Oh-my-zsh"
  export RUNZSH=no
  export KEEP_ZSHRC=yes
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  source ~/.zshrc
else
  pprint "Oh-my-zsh is already installed. Skipping."
fi

# Install Powerlevel10k
if [[ ! -d "$HOME/.oh-my-zsh/themes/powerlevel10k" ]]; then
  installing "Powerlevel10k"
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$HOME/.oh-my-zsh/themes/powerlevel10k"
else
  pprint "Powerlevel10k is already installed. Skipping."
fi

# Install fast-syntax-highlighting
if [[ ! -d "$HOME/.oh-my-zsh/plugins/fast-syntax-highlighting" ]]; then
  installing "fast-syntax-highlighting"
  git clone --depth=1 https://github.com/zdharma-continuum/fast-syntax-highlighting.git "$HOME/.oh-my-zsh/plugins/fast-syntax-highlighting"
else
  pprint "fast-syntax-highlighting is already installed. Skipping."
fi

# Install zsh-autosuggestions
if [[ ! -d "$HOME/.oh-my-zsh/plugins/zsh-autosuggestions" ]]; then
  installing "zsh-autosuggestions"
  git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions.git "$HOME/.oh-my-zsh/plugins/zsh-autosuggestions"
else
  pprint "zsh-autosuggestions is already installed. Skipping."
fi

# Install direnv
if command -v direnv >/dev/null 2>&1; then
  pprint "direnv is already installed. Skipping."
else
  installing "direnv"
  mkdir -p ~/.local/bin
  if [[ $(uname -s) = Darwin ]]; then
    brew install direnv
  else
    curl -sfL https://direnv.net/install.sh | bin_path=~/.local/bin bash
  fi
fi
