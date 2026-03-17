#!/bin/bash
set -e  # sai se algum comando falhar

# ---- Pacotes ----
sudo pacman -S --noconfirm --needed stow
sudo pacman -S --noconfirm --needed keyd
sudo pacman -S --noconfirm --needed libsecret

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

# ---- Configuração Keyd via Stow ----
cd ~/dotfiles
sudo stow keyd -t / --adopt
stow xkb --adopt
sudo stow nvim --adopt
sudo stow alacritty --adopt
sudo stow hypr --adopt
sudo stow waybar --adopt
cd ~

# ---- CLAUDE CODE ----
if ! command -v claude >/dev/null 2>&1; then
  curl -fsSL https://claude.ai/install.sh | bash
fi

sudo keyd reload
