```bash
# 1) 必要なパッケージのインストール
sudo apt update -y && sudo apt install -y git curl vim

# 2) dotfiles の bare-repo 方式での管理
git clone --bare https://github.com/mtakagishi/dotfiles.git $HOME/.dotfiles \
&& git --git-dir=$HOME/.dotfiles --work-tree=$HOME checkout \
&& git --git-dir=$HOME/.dotfiles --work-tree=$HOME \
config --local status.showUntrackedFiles no

# 3) install.sh の実行
bash ~/.config/bootstrap/install.sh
```
