#!/bin/bash
set -e  # sai se algum comando falhar

# ---- Pacotes ----
sudo pacman -S --noconfirm --needed stow
sudo pacman -S --noconfirm --needed keyd
sudo pacman -S --noconfirm --needed libsecret
sudo pacman -S --noconfirm --needed tmux
sudo pacman -S --noconfirm --needed fzf
sudo pacman -S --noconfirm --needed dotnet-sdk-8.0
sudo pacman -S --noconfirm --needed discord

# ---- AUR ----
yay -S --noconfirm --needed google-chrome
yay -S --noconfirm --needed zapzap

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

# ---- Stow configs (--adopt overwrites existing files) ----
cd ~/dotfiles
sudo stow keyd -t / --adopt
stow xkb --adopt
stow tmux --adopt
stow scripts --adopt
stow nvim --adopt
stow alacritty --adopt
stow hypr --adopt
stow waybar --adopt
stow starship --adopt
git checkout .
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
