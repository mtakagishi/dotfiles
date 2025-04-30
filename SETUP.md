```bash
# 1) 必要パッケージ & zsh を入れる
sudo apt update -y && sudo apt install -y git curl

# 2) dotfiles を bare-repo 方式で配置
git clone --bare https://github.com/mtakagishi/dotfiles.git $HOME/.dotfiles \
 && git --git-dir=$HOME/.dotfiles --work-tree=$HOME checkout \
 && git --git-dir=$HOME/.dotfiles --work-tree=$HOME \
      config --local status.showUntrackedFiles no

# 3) 言語／ツールブートストラップ
bash ~/.config/bootstrap/install.sh        # ← dotfiles 内に置いたスクリプト
```
