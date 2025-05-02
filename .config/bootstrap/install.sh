#!/usr/bin/env bash
set -euo pipefail

echo -----------------------
echo root実行防止
echo -----------------------
if [[ $EUID -eq 0 ]]; then
  echo "[ERROR] This script should NOT be run as root."
  exit 1
fi

echo "[INFO] install.sh started as $USER"

echo ----------------------
echo 最小限のパッケージ更新
echo ----------------------
echo "[INFO] Updating package list..."
sudo apt-get update -qq
sudo apt-get upgrade -qq -y

# インストール対象のパッケージ一覧
packages=(
  build-essential
  language-pack-ja
  ufw
  zsh
  fontconfig
  unzip
  neovim
)

echo ----------------------------------------
echo 各パッケージが未インストールならインストール
echo ----------------------------------------
for pkg in "${packages[@]}"; do
  if dpkg -s "$pkg" >/dev/null 2>&1; then
    echo "[INFO] $pkg is already installed."
  else
    echo "[INFO] Installing $pkg..."
    sudo apt-get install -y "$pkg"
  fi
done

echo -------------------
echo ロケールと言語設定
echo -------------------
if locale -a | grep -q '^ja_JP\.utf8$'; then
  echo "[INFO] ja_JP.UTF-8 is already generated."
else
  echo "[INFO] Generating ja_JP.UTF-8 locale..."
  sudo locale-gen ja_JP.UTF-8
fi

echo ----------------------------------------------
echo LANG=ja_JP.UTF-8 が既に設定されているか確認
echo ----------------------------------------------
CURRENT_LANG=$(localectl status | grep "LANG=" | cut -d= -f2)

if [[ "$CURRENT_LANG" == "ja_JP.UTF-8" ]]; then
  echo "[INFO] LANG is already set to ja_JP.UTF-8."
else
  echo "[INFO] Setting LANG to ja_JP.UTF-8..."
  sudo update-locale LANG=ja_JP.UTF-8
  source /etc/default/locale
fi

echo ----------------
echo タイムゾーン設定
echo ----------------
TARGET_TZ="Asia/Tokyo"
CURRENT_TZ=$(timedatectl show -p TimeZone --value)

if [[ "$CURRENT_TZ" == "$TARGET_TZ" ]]; then
  echo "[INFO] TimeZone is already set to $TARGET_TZ."
else
  echo "[INFO] Setting TimeZone to $TARGET_TZ..."
  sudo timedatectl set-timezone "$TARGET_TZ"
fi

echo ----------------------
echo ファイアウォールの設定
echo ----------------------
if sudo ufw status | grep -q "Status: active"; then
  echo "[INFO] ufw is already enabled."
else
  echo "[INFO] Enabling ufw..."
  sudo ufw --force enable
fi

echo --------------------------------------------------
echo OpenSSH が許可されているか確認（ポート番号でも可）
echo --------------------------------------------------
if sudo ufw status | grep -q "OpenSSH"; then
  echo "[INFO] OpenSSH is already allowed."
else
  echo "[INFO] Allowing OpenSSH through ufw..."
  sudo ufw allow OpenSSH
fi

echo ------------
echo フォント設定
echo ------------
FONT_NAME="Nerd Font"
if fc-list | grep -qi "$FONT_NAME"; then
  echo "[INFO] $FONT_NAME is already installed. Skipping installation."
else
  echo "[INFO] $FONT_NAME not found. Installing..."
  mkdir -p ~/.local/share/fonts
  cd ~/.local/share/fonts
  curl -LO https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip
  unzip -o FiraCode.zip
  rm FiraCode.zip
  cd ~
  echo "[INFO] $FONT_NAME installed successfully."
fi

echo -------------------
echo フォント表示確認
echo -------------------
echo -e "\ufb00 \ufb13 \ue0b0 \uf09b"

echo ---------
echo zshへ切替
echo ---------
ZSH_PATH="$(command -v zsh)"
CURRENT_SHELL="$(getent passwd "$USER" | cut -d: -f7)"

if [[ "$CURRENT_SHELL" == "$ZSH_PATH" ]]; then
  echo "[INFO] Login shell is already zsh ($CURRENT_SHELL). Skipping chsh."
else
  echo "[INFO] Changing login shell to zsh..."
  chsh -s "$ZSH_PATH"
fi

