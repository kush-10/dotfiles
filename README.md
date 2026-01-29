# Dotfiles

## Files:

- `.git`: Git metadata directory for this repo.
- `.greeting`: Custom greeting text/config.
- `.mytheme.omp.json`: oh-my-posh theme configuration.
- `.tmux.conf`: tmux configuration.
- `.zshrc.mac`: zsh shell configuration for macOS.
- `.zshrc.linux`: zsh shell configuration for Linux.
- `ghostty.config`: Ghostty terminal configuration (symlink to `~/.config/ghostty/config`).
- `nvim/`: Neovim configuration.
- `tmux-sessionizer`: tmux sessionizer script (copied to `~/.local/bin`) [Orginal File](https://github.com/ThePrimeagen/tmux-sessionizer).
- `tmux-sessionizer.conf`: tmux sessionizer config (copied to `~/.config/tmux-sessionizer/`).
- `ducky.json`: karabiner elements json for a ducky 1-3 sf

## Scripts:

- `scripts/link_zshrc.sh`: Symlink the correct `.zshrc`, shared files, and copy tmux-sessionizer files into place.
- `scripts/install_zsh_tools.sh`: Install Oh My Zsh, zsh-autosuggestions, fzf, and oh-my-posh.
- `scripts/README.md`: Notes and manual linking commands.
