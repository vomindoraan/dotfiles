set laststatus=2
set mouse=a
set nowrap
set number relativenumber
set tabstop=4 shiftwidth=4 expandtab

noremap Q :qa<CR>

cnoremap clip w !clip.exe
cnoremap w!! execute 'w !sudo tee % >/dev/null' <bar> edit!

colorscheme delek
