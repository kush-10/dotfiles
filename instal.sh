#!/usr/bin/env bash

set -euo pipefail

# Directory where this script lives = repo root
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🔧 Setting up symlinks from repo: $REPO"

#
# Helper: remove file or symlink if it exists
#
remove_if_exists() {
  local target="$1"
  if [ -e "$target" ] || [ -L "$target" ]; then
    echo "🗑  Removing existing $target"
    rm -f "$target"
  fi
}

#
# Remove existing files
#
remove_if_exists "$HOME/.zshrc"
remove_if_exists "$HOME/.mytheme.omp.json"

#
# Create symlinks pointing to files in this repo
# Adjust filenames here if your repo uses different names
#
echo "🔗 Creating symlink: ~/.zshrc → $REPO/zshrc"
ln -s "$REPO/zshrc" "$HOME/.zshrc"

echo "🔗 Creating symlink: ~/.mytheme.omp.json → $REPO/mytheme.omp.json"
ln -s "$REPO/mytheme.omp.json" "$HOME/.mytheme.omp.json"

echo
echo "✅ Done! Current links:"
ls -l "$HOME/.zshrc" "$HOME/.mytheme.omp.json"
