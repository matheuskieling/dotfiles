#!/bin/bash
set -e  # sai se algum comando falhar

# ---- Pacotes ----
sudo pacman -S --noconfirm --needed stow
sudo pacman -S --noconfirm --needed keyd
sudo pacman -S --noconfirm --needed libsecret
sudo pacman -S --noconfirm --needed tmux
sudo pacman -S --noconfirm --needed fzf
sudo pacman -S --noconfirm --needed dotnet-sdk-8.0
sudo pacman -S --noconfirm --needed aspnet-runtime-8.0
sudo pacman -S --noconfirm --needed discord
sudo pacman -S --noconfirm --needed dbeaver

# ---- AUR ----
yay -S --noconfirm --needed google-chrome
# ---- Configurações Git ----
git config --global credential.helper libsecret
git config --global credential.useHttpPath true

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
stow bash --adopt
git checkout .

cd ~

# ---- pnpm ----
if ! command -v pnpm >/dev/null 2>&1; then
  npm install -g pnpm
fi

# ---- CLAUDE CODE ----
if ! command -v claude >/dev/null 2>&1; then
  curl -fsSL https://claude.ai/install.sh | bash
fi

# ---- Notes ----
if [ ! -d ~/notes ]; then
  git clone https://github.com/matheuskieling/notes-.git ~/notes
fi

# ---- TPM ----
if [ ! -d ~/.tmux/plugins/tpm ]; then
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

# ---- Timezone ----
sudo timedatectl set-timezone America/Sao_Paulo

sudo keyd reload
tmux source-file ~/.config/tmux/tmux.conf 2>/dev/null || true
