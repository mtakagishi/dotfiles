![Dotfiles Setup](https://github.com/mtakagishi/dotfiles/actions/workflows/dotfiles-ci.yml/badge.svg)

# dotfiles

## SETUP

1. install package

``` bash
sudo apt update -y && sudo apt install -y git curl vim
```

2. checkout dotfiles

``` bash
git clone --bare https://github.com/mtakagishi/dotfiles.git $HOME/.dotfiles \
&& git --git-dir=$HOME/.dotfiles --work-tree=$HOME checkout --force\
&& git --git-dir=$HOME/.dotfiles --work-tree=$HOME \
config --local status.showUntrackedFiles no
``` 

checkout時にファイルが存在する場合は上書き。バックアップが必要なら --forceを付けずに実行してください。

3. run instal.sh

``` bash
bash ~/.config/bootstrap/install.sh
```
