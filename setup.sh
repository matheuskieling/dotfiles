sudo pacman -S stow --noconfirm ---needed
sudo pacman -S keyd --noconfirm --needed


cd ~/dotfiles && sudo stow keyd -t /
cd ~
