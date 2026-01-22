#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
dotfiles_dir="$(cd "$script_dir/.." && pwd)"

os_name="$(uname -s)"
case "$os_name" in
  Darwin)
    src="$dotfiles_dir/.zshrc.mac"
    ;;
  Linux)
    src="$dotfiles_dir/.zshrc.linux"
    ;;
  *)
    echo "Unsupported OS: $os_name" >&2
    exit 1
    ;;
 esac

ln -snf "$src" "$HOME/.zshrc"

# Also link shared files used by the zshrcs.
if [ -f "$dotfiles_dir/.mytheme.omp.json" ]; then
  ln -snf "$dotfiles_dir/.mytheme.omp.json" "$HOME/.mytheme.omp.json"
fi

if [ -f "$dotfiles_dir/.greeting" ]; then
  ln -snf "$dotfiles_dir/.greeting" "$HOME/.greeting"
fi

echo "Linked $src -> $HOME/.zshrc"
