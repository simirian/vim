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
function! Find(...)
    if a:0 == 0
    elseif a:1 == "f"
        let g:finder_cmd = "find . | grep -v '/\\.'"
        let g:finder_select = "edit"
    elseif a:1 == "a"
        let g:finder_cmd = "find ."
        let g:finder_select = "edit"
    elseif a:1 == "h"
        let files = join(globpath(&runtimepath, "**/doc/tags", 1, 1), " ")
        let g:finder_cmd = "grep -ohe '^[^[:space:]]*' " .. files
        let g:finder_select = "help"
    elseif a:1 == "g"
        let g:finder_cmd = "git ls-tree -r $(git branch --show) --name-only"
        let g:finder_select = "edit"
    endif
    edit finder
endfunction
nnoremap <leader>ff <cmd>call Find("f")<cr>
nnoremap <leader>fa <cmd>call Find("a")<cr>
nnoremap <leader>fh <cmd>call Find("h")<cr>
nnoremap <leader>fg <cmd>call Find("g")<cr>

" markdown TOC
noremap gO :lvim /#\+ \w\+/ % \| cope<cr>
