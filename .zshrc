# export

# alias
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias dot='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
alias dotcheck='dot status --untracked-files=all'

# --- starship 初期化 -----------------------------------------------
eval "$(starship init zsh)"
