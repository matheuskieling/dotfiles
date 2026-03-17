#!/bin/bash
set -e  # sai se algum comando falhar

# ---- Pacotes ----
sudo pacman -S --noconfirm --needed stow
sudo pacman -S --noconfirm --needed keyd
sudo pacman -S --noconfirm --needed libsecret

# ---- Configurações Git ----
git config --global credential.helper libsecret
git config --global credential.useHttpPath true

# ---- Configuração Keyd via Stow ----
cd ~/dotfiles
sudo stow keyd -t /
sudo stow nvim --adopt
sudo stow alacritty --adopt
sudo stow hypr --adopt
cd ~
