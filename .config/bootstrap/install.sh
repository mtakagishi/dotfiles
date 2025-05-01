#!/usr/bin/env bash
set -euo pipefail

# 必要なら root に昇格
if [[ $EUID -ne 0 ]]; then
  exec sudo -E "$0" "$@"
fi

apt update && apt upgrade -y
apt install -y build-essential
apt install -y language-pack-ja
apt install -y ufw
apt install -y zsh fontconfig unzip

# ロケールと言語設定
locale-gen ja_JP.UTF-8
update-locale LANG=ja_JP.UTF-8
source /etc/default/locale

# タイムゾーン設定
timedatectl set-timezone Asia/Tokyo

# ファイアウォールの設定
ufw --force enable
ufw allow OpenSSH

# 状態表示
locale
timedatectl
ufw status verbose

# フォント設定
mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts
curl -LO https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip
unzip FiraCode.zip
rm FiraCode.zip
cd ~

echo font表示確認
echo -e "\ufb00 \ufb13 \ue0b0 \uf09b"

# zsh設定
chsh -s $(command -v zsh)"
