# Windows規定値対策
cd ~
# --- ヒストリ設定 ---
HISTFILE=~/.zsh_history
HISTSIZE=1000
SAVEHIST=2000
setopt append_history        # bashの histappend 相当
setopt inc_append_history    # 実行後すぐ保存
setopt hist_ignore_dups      # 重複除外
setopt hist_ignore_space     # 先頭がスペースのコマンドを記録しない

# --- プロンプトの設定（簡易版） ---
PROMPT='%F{green}%n@%m%f:%F{blue}%~%f %# '

# --- debian_chroot 表示（不要なら省略可） ---
if [[ -z "$debian_chroot" && -r /etc/debian_chroot ]]; then
  debian_chroot=$(< /etc/debian_chroot)
fi

# --- ls / grep のカラー表示と alias ---
if [[ -x /usr/bin/dircolors ]]; then
  eval "$(dircolors -b ~/.dircolors 2>/dev/null || dircolors -b)"
  alias ls='ls --color=auto'
  alias grep='grep --color=auto'
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'
fi

# --- ls の便利 alias ---
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# --- 長時間コマンド後の通知（GUI環境限定） ---
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history 1 | sed -e '\''s/^\s*[0-9]\+\s*//'\'' | sed '\''s/[;&|]\s*alert$//'\'' )"'

# --- 補完機能の有効化 ---
autoload -Uz compinit
compinit

# export
export SUDO_EDITOR=nvim
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
export PATH="$HOME/.local/bin:$PATH"

# alias
alias dot='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
alias dotcheck='dot status --untracked-files=all'
alias vim='nvim'
alias view='nvim -R'
alias vimdiff='nvim -d'

# --- starship 初期化 -----------------------------------------------
eval "$(starship init zsh)"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
