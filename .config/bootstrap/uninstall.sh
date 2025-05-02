#!/usr/bin/env bash
set -euxo pipefail

# install.sh で使ったパッケージ一覧
packages=(
  build-essential
  language-pack-ja
  ufw
  zsh
  fontconfig
  unzip
  neovim
)

# emacs-nox 関連（対話が発生したり、副作用の多いもの）
emacs_related=(
  emacs-nox
  emacs-common
  emacsen-common
  mailutils
  mailutils-common
  libmailutils9t64
  postfix
)

echo "----------------------------------------"
echo "[INFO] Removing all installed packages from install.sh"
echo "----------------------------------------"

# 通常パッケージを削除
sudo apt-get purge -y "${packages[@]}"

# emacs-nox 関連を削除（個別に特別対応）
sudo apt-get purge -y "${emacs_related[@]}"

# 依存関係の自動削除とキャッシュクリア
sudo apt-get autoremove -y
sudo apt-get clean

# dpkg に設定ファイルのみ残っているパッケージ(rc)があれば削除
if dpkg -l | grep -q '^rc'; then
  echo "[INFO] Purging residual configuration files (rc packages)"
  dpkg -l | awk '/^rc/ {print $2}' | xargs sudo apt-get purge -y
else
  echo "[INFO] No rc packages found"
fi

# 確認出力
echo "----------------------------------------"
echo "[INFO] Remaining relevant packages (should be empty)"
echo "----------------------------------------"
dpkg -l | grep -E 'emacs|mailutils|postfix|zsh|ufw|fontconfig|neovim|unzip|language-pack-ja|build-essential' || echo "[INFO] All target packages successfully removed"

