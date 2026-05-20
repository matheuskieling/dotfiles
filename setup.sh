#!/bin/bash
set -e  # sai se algum comando falhar

# ---- Pacotes ----
sudo pacman -S --noconfirm --needed stow || true
sudo pacman -S --noconfirm --needed libsecret || true
sudo pacman -S --noconfirm --needed tmux || true
sudo pacman -S --noconfirm --needed fzf || true
sudo pacman -S --noconfirm --needed dotnet-sdk-8.0 || true
sudo pacman -S --noconfirm --needed aspnet-runtime-8.0 || true
sudo pacman -S --noconfirm --needed discord || true
sudo pacman -S --noconfirm --needed dbeaver || true
sudo pacman -S --noconfirm --needed git-delta || true

# ---- AUR ----
yay -S --noconfirm --needed google-chrome || true
yay -S --noconfirm --needed kanata || true

# ---- Remove remappers concorrentes (keyd e makima do omarchy) ----
sudo systemctl disable --now keyd 2>/dev/null || true
sudo pacman -Rns --noconfirm keyd 2>/dev/null || true
sudo systemctl disable --now makima 2>/dev/null || true
systemctl --user restart kanata.service 2>/dev/null || true
# ---- Configurações Git ----
git config --global credential.helper libsecret
git config --global credential.useHttpPath true
git config --global core.pager delta
git config --global interactive.diffFilter "delta --color-only"
git config --global delta.navigate true
git config --global delta.dark true
git config --global delta.line-numbers true

cd ~/dotfiles

stow kanata --adopt
stow xkb --adopt
stow tmux --adopt
stow scripts --adopt
stow nvim --adopt
stow alacritty --adopt
stow hypr --adopt
stow waybar --adopt
stow starship --adopt
stow bash --adopt
stow lazygit --adopt
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

# ---- CNPJ Serendipe ----
if [ ! -d ~/cnpj ]; then
  git clone https://github.com/matheuskieling/CNPJ-Serendipe.git ~/cnpj
fi

# ---- OpenVPN ----
if [ ! -d ~/openvpn ]; then
  git clone https://github.com/matheuskieling/openvpn.git ~/openvpn
fi

# ---- Timezone ----
sudo timedatectl set-timezone America/Sao_Paulo

# ---- Kanata user service ----
systemctl --user daemon-reload
systemctl --user enable --now kanata.service || true
systemctl --user restart kanata.service || true

tmux source-file ~/.config/tmux/tmux.conf 2>/dev/null || true
