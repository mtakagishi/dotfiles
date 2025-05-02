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
