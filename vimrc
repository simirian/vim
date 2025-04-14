" basic vimrc configuration by simitian

" basics
set termguicolors
syntax on
filetype plugin indent on
colorscheme desert
colorscheme habamax

" basic maps
let g:mapleader = " "
inoremap jj <esc>
noremap <C-j> <C-w>w
noremap <C-k> <C-w>W
noremap <C-h> gT
noremap <C-l> gt
noremap U <C-r>

" terminal maps
tnoremap <esc><esc> <C-\><C-n>
tnoremap <C-j> <C-w>w
tnoremap <C-k> <C-w>W
tnoremap <C-h> <C-w>gT
tnoremap <C-l> <C-w>gt

" cursor
let &t_SI = "\e[6 q"
let &t_EI = "\e[2 q"

" tabs
set tabstop=4
set softtabstop=4
set shiftwidth=0
set expandtab
set shiftround

"indenting
set autoindent
au FileType c,cpp set cindent

" decoration
set cursorline
au BufWinEnter * if &tw == 0 | set colorcolumn=81 | else | set colorcolumn=+1 | endif
set wildmenu

" misc
set ignorecase
set smartcase
set nohlsearch
set incsearch
set scrolloff=0
set viminfo=
set belloff=all
set hidden
set directory=~/.vim/.swap//

au FileType text,markdown set tw=80 colorcolumn=+1

" lines
set statusline=\ %y\ %t\ %n\ %M%=%l/%L\ %v\ 
set laststatus=2
function TabLine()
    let str = "%#Search# %{fnamemodify(getcwd(), ':t:r')} | %{strftime('%H:%M')} %#TabLineFill#%="
    for i in range(tabpagenr("$"))
        let str ..= (i + 1 == tabpagenr() ? "%#TabLineSel# " : "%#TabLine# ") .. (i + 1) .. " "
    endfor
    return str
endfunction
set tabline=%!TabLine()
set showtabline=2

" explorer
let g:netrw_banner = 0
nnoremap - <cmd>e %:h<cr>
nnoremap _ <cmd>e .<cr>

" finder
nnoremap <leader>ff <cmd>e find://files<cr>
nnoremap <leader>fa <cmd>e find://all<cr>
nnoremap <leader>fh <cmd>e find://help<cr>
nnoremap <leader>fg <cmd>e find://git<cr>

" markdown TOC
au FileType markdown noremap gO <cmd>lvim /#\+ \w\+/ % \| lope<cr>
au FileType help noremap gO <cmd>lvim /^\(=\+\n\)\@<=.*\*.*\*.*$\\|^[[:upper:]][^[:lower:]]\+\s\+\*.*\*.*$/ % \| lope<cr>
