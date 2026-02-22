" ~/.vimrc
" vim:foldmethod=marker:foldlevel=0

" Basic Settings {{{
set number
set relativenumber
set expandtab
set tabstop=2
set shiftwidth=2
set softtabstop=2
set autoindent
set smartindent
set hidden
set updatetime=300
set signcolumn=yes
set nobackup
set nowritebackup
set cmdheight=2
set shortmess+=c
syntax on
filetype plugin indent on

" Leader key
let mapleader = " "
let maplocalleader = "\\"
" }}}

" vim-plug Plugins {{{
call plug#begin('~/.vim/plugged')

" LSP and Completion
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" File Navigation
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'preservim/nerdtree'

" Theme
Plug 'folke/tokyonight.nvim'

" Keybinding Hints
Plug 'liuchengxu/vim-which-key'

" AI Integration
Plug 'github/copilot.vim'

call plug#end()
" }}}

" Theme {{{
if has('termguicolors')
  set termguicolors
endif
colorscheme tokyonight-night
" }}}

" Plugin Configs {{{
" Load plugin-specific configs
runtime! plugin/*.vim
" }}}