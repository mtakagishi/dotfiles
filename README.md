[![Dotfiles Setup](https://github.com/mtakagishi/dotfiles/actions/workflows/dotfiles-ci.yml/badge.svg)](https://github.com/mtakagishi/dotfiles/actions/workflows/dotfiles-ci.yml)

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

3. run install.sh

``` bash
bash ~/.config/bootstrap/install.sh
```

## Note
- github actionsでCIを実行しています。プルリクエストを作成すると、CIが自動で実行されます。 
- CIは60日以上更新されていない場合は自動で停止します。その場合は手動でEnableしてください。
