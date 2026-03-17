#!/bin/bash
set -e  # sai se algum comando falhar

# ---- Pacotes ----
sudo pacman -S --noconfirm --needed stow
sudo pacman -S --noconfirm --needed keyd
sudo pacman -S --noconfirm --needed libsecret
sudo pacman -S --noconfirm --needed tmux
sudo pacman -S --noconfirm --needed fzf

# ---- AUR ----
yay -S --noconfirm --needed google-chrome

# ---- Configurações Git ----
git config --global credential.helper libsecret
git config --global credential.useHttpPath true

# ---- Clone Dotfiles ----
cd ~
if [ -d ".git" ]; then
  echo "Já dentro do repo"
else
  cd ~
  if [ ! -d "dotfiles" ]; then
    git clone https://github.com/matheuskieling/dotfiles.git
  fi
  cd dotfiles
fi

# ---- Stow configs ----
cd ~/dotfiles
sudo stow keyd -t / --restow
stow xkb --restow
stow tmux --restow
stow scripts --restow
stow nvim --restow
stow alacritty --restow
stow hypr --restow
stow waybar --restow
cd ~

# ---- CLAUDE CODE ----
if ! command -v claude >/dev/null 2>&1; then
  curl -fsSL https://claude.ai/install.sh | bash
fi

# ---- TPM ----
if [ ! -d ~/.tmux/plugins/tpm ]; then
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

sudo keyd reload
tmux source-file ~/.config/tmux/tmux.conf 2>/dev/null || true
