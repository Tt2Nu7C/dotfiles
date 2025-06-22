syntax on
filetype plugin indent on
filetype plugin on
set number
set noswapfile
set t_Co=256
set cursorline

" Automatically remove trailing whitespace on save
autocmd BufWritePre * %s/\s\+$//e

