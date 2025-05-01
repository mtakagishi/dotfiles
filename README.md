![Dotfiles Setup](https://github.com/mtakagishi/dotfiles/actions/workflows/setup-test.yml/badge.svg)

# dotfiles

## SETUP

1. install package

``` bash
sudo apt update -y && sudo apt install -y git curl vim
```

2. checkout dotfiles

``` bash
git clone --bare https://github.com/mtakagishi/dotfiles.git $HOME/.dotfiles \
&& git --git-dir=$HOME/.dotfiles --work-tree=$HOME checkout \
&& git --git-dir=$HOME/.dotfiles --work-tree=$HOME \
config --local status.showUntrackedFiles no
``` 

3. run instal.sh

``` bash
bash ~/.config/bootstrap/install.sh
```
