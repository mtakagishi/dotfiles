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
  tmux
  pipx
  # emacs-nox
)

echo ----------------------------------------
echo 各パッケージが未インストールならインストール
echo ----------------------------------------
for pkg in "${packages[@]}"; do
  if dpkg -s "$pkg" >/dev/null 2>&1; then
    echo "[INFO] $pkg is already installed."
  else
    echo "[INFO] Installing $pkg..."
    # sudo apt-get install -y "$pkg"
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "$pkg"
  fi
done

echo  ==============================
echo  emacs-nox を特別扱いでインストール
echo  ==============================

if ! dpkg -s emacs-nox >/dev/null 2>&1; then
  echo "[INFO] Pre-setting debconf to avoid postfix interaction"
  echo "postfix postfix/main_mailer_type string No configuration" | sudo debconf-set-selections

  echo "[INFO] Installing emacs-nox with debconf pre-seeded"
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y emacs-nox
else
  echo "[INFO] emacs-nox is already installed."
fi

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

if [[ -n "${CI:-}" ]]; then
  echo "[INFO] CI環境なので chsh をスキップします。"
elif [[ "$CURRENT_SHELL" == "$ZSH_PATH" ]]; then
  echo "[INFO] Login shell is already zsh ($CURRENT_SHELL). Skipping chsh."
else
  echo "[INFO] Changing login shell to zsh..."
  chsh -s "$ZSH_PATH"
fi

echo ----------------------------------------
echo Node.js セットアップ via nvm
echo ----------------------------------------

# NVMのインストール先ディレクトリ
export NVM_DIR="$HOME/.nvm"

# nvm がすでに存在しているかチェック
if [ ! -s "$NVM_DIR/nvm.sh" ]; then
  echo "[INFO] Installing NVM..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
else
  echo "[INFO] NVM already installed. Skipping."
fi

# nvm を現在のシェルで有効化
if [ -s "$NVM_DIR/nvm.sh" ]; then
  . "$NVM_DIR/nvm.sh"
fi

# Node.js がインストールされていない場合は LTS 版を導入
if ! command -v node >/dev/null; then
  echo "[INFO] Installing Node.js via nvm..."
  nvm install --lts
else
  echo "[INFO] Node.js is already available. Version: $(node -v)"
fi

echo "------------------------------------"
echo "vim-plug をインストール（Neovim 用）"
echo "------------------------------------"

# XDG Base Directory に対応（必要に応じて）
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"

echo XDG_CONFIG_HOME: "$XDG_CONFIG_HOME"
echo XDG_DATA_HOME: "$XDG_DATA_HOME"

# 必要なディレクトリを作成
mkdir -p "$XDG_DATA_HOME/nvim/site/autoload"
mkdir -p "$XDG_DATA_HOME/nvim/plugged"

# vim-plug をインストール（未インストール時のみ）
if [ ! -f "$XDG_DATA_HOME/nvim/site/autoload/plug.vim" ]; then
  echo "[INFO] Installing vim-plug for Neovim..."
  curl -fLo "$XDG_DATA_HOME/nvim/site/autoload/plug.vim" --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
else
  echo "[INFO] vim-plug already installed. Skipping."
fi

# init.vim に plug#begin が含まれている場合のみ実行
INIT_VIM="$XDG_CONFIG_HOME/nvim/init.vim"
if grep -q 'plug#begin' "$INIT_VIM" 2>/dev/null; then
  echo "[INFO] Running :PlugInstall for Neovim..."
  nvim --headless -u "$INIT_VIM" +PlugInstall +PlugUpdate +PlugClean! +qall

  echo "--------------------------"
  echo "Neovim プラグイン確認"
  echo "--------------------------"
  nvim --headless -u "$INIT_VIM" +scriptnames +qall

  echo "--------------------------"
  echo "[INFO] To enable GitHub Copilot, open Neovim and run :Copilot setup (only once)"
else
  echo "[WARN] plug#begin not found in $INIT_VIM — skipping PlugInstall."
fi

echo --------------------------
echo python環境整備
echo --------------------------
pipx ensurepath
export PATH="$HOME/.local/bin:$PATH"
export PATH="/opt/pipx_bin:$PATH"

# poetry インストール（pipx 経由）
if ! command -v poetry >/dev/null; then
  echo "[INFO] Installing poetry via pipx..."
  pipx install poetry
fi

# 念のため再確認してもまだ poetry が無い場合
if ! command -v poetry >/dev/null; then
  echo "[ERROR] poetry が PATH に見つかりません。環境を確認してください。" >&2
  exit 127
fi

# 確認出力
python3 --version
pipx --version
poetry --version
