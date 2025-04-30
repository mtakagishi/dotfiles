#!/usr/bin/env bash
set -euo pipefail

# 必要なら root に昇格
if [[ $EUID -ne 0 ]]; then
  exec sudo -E "$0" "$@"
fi

# localeコマンドがなければ jaパックをインストール
if ! command -v locale >/dev/null; then
  apt update -qq
  apt install -y language-pack-ja
fi

# ロケールと言語設定
locale-gen ja_JP.UTF-8
update-locale LANG=ja_JP.UTF-8

# タイムゾーン設定
timedatectl set-timezone Asia/Tokyo

# ufwがなければインストール
if ! command -v ufw >/dev/null; then
  apt install -y ufw
fi

ufw --force enable
ufw allow OpenSSH

# 状態表示
locale
timedatectl
ufw status verbose

