#!/usr/bin/env bash
set -euo pipefail

os_name="$(uname -s)"

ensure_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing required command: $1" >&2
    exit 1
  fi
}

ensure_cmd curl
ensure_cmd git

echo "Installing Oh My Zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  echo "Oh My Zsh already installed."
fi

zsh_custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
plugin_dir="$zsh_custom/plugins/zsh-autosuggestions"

if [ ! -d "$plugin_dir" ]; then
  echo "Installing zsh-autosuggestions..."
  git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "$plugin_dir"
else
  echo "zsh-autosuggestions already installed."
fi

install_fzf_from_git() {
  if [ ! -d "$HOME/.fzf" ]; then
    echo "Cloning fzf..."
    git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
  fi

  echo "Installing fzf shell integration..."
  "$HOME/.fzf/install" --key-bindings --completion --no-update-rc --no-bash --no-fish

  if ! "$HOME/.fzf/bin/fzf" --version >/dev/null 2>&1; then
    echo "fzf binary failed to run; trying to build from source..."
    if command -v go >/dev/null 2>&1; then
      (cd "$HOME/.fzf" && go build -o bin/fzf ./cmd/fzf)
    else
      echo "Go not available; will try OS package manager." >&2
      return 1
    fi
  fi
}

install_fzf_from_pkg() {
  if command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update
    sudo apt-get install -y fzf
  elif command -v dnf >/dev/null 2>&1; then
    sudo dnf install -y fzf
  elif command -v yum >/dev/null 2>&1; then
    sudo yum install -y fzf
  elif command -v pacman >/dev/null 2>&1; then
    sudo pacman -S --noconfirm fzf
  else
    echo "No supported package manager found for fzf." >&2
    return 1
  fi
}

echo "Installing fzf..."
if ! install_fzf_from_git; then
  if [ "$os_name" = "Linux" ]; then
    echo "Falling back to package manager for fzf on Linux..."
    install_fzf_from_pkg || true
  else
    echo "fzf install failed; consider reinstalling manually." >&2
  fi
fi

echo "Installing oh-my-posh..."
mkdir -p "$HOME/.local/bin"
if ! command -v oh-my-posh >/dev/null 2>&1; then
  curl -s https://ohmyposh.dev/install.sh | bash -s -- -d "$HOME/.local/bin"
else
  echo "oh-my-posh already installed."
fi

echo "Done. Run scripts/link_zshrc.sh to link your .zshrc." 
