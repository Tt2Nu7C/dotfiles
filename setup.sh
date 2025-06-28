#!/bin/bash

echo -e "Installing tools\n"
# Detect distro and install packages
if [ -f /etc/debian_version ]; then
    sudo apt update
    sudo apt install -y zsh zoxide duf wireguard-tools vim bat tmux git nmap
elif [ -f /etc/arch-release ]; then
    sudo pacman -S --noconfirm zsh zoxide duf wireguard-tools vim bat tmux git nmap
else
    echo "Unsupported distribution. Only Debian and Arch-based distros are supported."
    exit 1
fi

echo -e "Configuring ZSH\n"
mkdir -p ~/.cache
touch ~/.cache/.histfile


base_dir="/usr/local/share/zsh_conf"
dirs=(
    "ohmyzsh"
    "zsh-autosuggestions"
    "zsh-syntax-highlighting"
    "powerlevel10k"
)

for dir in "${dirs[@]}"; do
    if [ -d "$base_dir/$dir" ]; then
        echo "Deleting $base_dir/$dir"
        sudo rm -rf "$base_dir/$dir"
    fi
done

sudo install -d -o "$USER" -g "$USER" /usr/local/share/zsh_conf

# Clone ZSH plugins/themes
repos=(
    "https://github.com/ohmyzsh/ohmyzsh"
    "https://github.com/zsh-users/zsh-autosuggestions"
    "https://github.com/zsh-users/zsh-syntax-highlighting"
    "https://github.com/romkatv/powerlevel10k.git --depth=1"
)


for repo in "${repos[@]}"; do
    url=${repo%% *}
    opts=${repo#"$url"}
    name=$(basename "${url%%.git}")
    git clone $opts "$url" "/usr/local/share/zsh_conf/$name"
done

echo -e "Configuring TMUX\n"
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Copy dotfiles (ensure they exist first)
cp -f -v .tmux.conf .vimrc .zshrc .p10k.zsh ~/ 2>/dev/null || echo "Dotfiles not found, skipped copy."
sudo cp -f -v .tmux.conf .vimrc .zshrc .p10k.zsh /root/ 2>/dev/null || echo "Dotfiles not found, skipped copy."
sudo cp -f -v sshd_config /etc/ssh/

# Change default shell to ZSH
chsh -s /bin/zsh

echo -e "\nSetup done. Logout and login again to use ZSH."
echo -e "To install tmux plugins: press prefix + I (capital i, as in Install).\n"
