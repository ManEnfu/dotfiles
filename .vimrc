set number
set laststatus=2
set tabstop=4 shiftwidth=4 expandtab

" so ~/.vim/plugins.vim

call plug#begin('~/.vim/plugged')

Plug 'itchyny/lightline.vim'
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
Plug 'terryma/vim-multiple-cursors'
Plug 'airblade/vim-gitgutter'
Plug 'scrooloose/nerdtree'
Plug 'tpope/vim-surround'
Plug 'majutsushi/tagbar'
Plug 'Shougo/deoplete.nvim'
Plug 'roxma/nvim-yarp'
Plug 'roxma/vim-hug-neovim-rpc'
Plug 'webastien/vim-ctags'
Plug 'Townk/vim-autoclose'
Plug 'vim-syntastic/syntastic'
Plug 'doums/darcula'

call plug#end()

nnoremap to :NERDTreeToggle<CR>
nnoremap tp :TagbarToggle<CR>

colorscheme darcula

let g:deoplete#enable_at_startup = 1
let g:lightline = { 'colorscheme': 'darculaOriginal' }

set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_c_include_dirs = ['../headers', 'headers', '../include', 'include']
