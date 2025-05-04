set number              " 行番号を表示
set tabstop=4           " タブ幅を4に
set shiftwidth=4        " インデント幅
set expandtab           " タブの代わりにスペース
set smartindent         " スマートインデント
set clipboard=unnamedplus  " クリップボード連携
set hidden              " 編集中でもバッファ切り替え可

" --- 検索 ---
set ignorecase          " 大文字小文字を無視
set smartcase           " ただし大文字が含まれていたら区別
set incsearch           " インクリメンタルサーチ
set hlsearch            " 検索結果をハイライト

" --- カラースキーム ---
syntax on
colorscheme default

" --- ファイル保存時の自動処理（例：トレーリングスペース削除） ---
autocmd BufWritePre * :%s/\\s\\+$//e

" --- キーマッピング ---

" --- プラグイン定義 (vim-plug)---
call plug#begin('~/.local/share/nvim/plugged')

" --- 追加プラグイン---

" github copilot
Plug 'github/copilot.vim'

call plug#end()

" --- プラグインの設定 ---
" Copilot の Tab キーを無効化（他プラグインと衝突させない）
let g:copilot_no_tab_map = v:true

" Copilot の補完を <C-J>（Ctrl+J）で受け入れる
imap <silent><script><expr> <C-J> copilot#Accept("\<CR>")
