" NERDTree file explorer configuration

" Toggle NERDTree
nnoremap <leader>e :NERDTreeToggle<CR>

" Find current file in NERDTree
nnoremap <leader>ef :NERDTreeFind<CR>

" NERDTree settings
let NERDTreeShowHidden=1
let NERDTreeIgnore=['\.git$', '\.DS_Store$', '__pycache__', '\.pyc$']
let NERDTreeMinimalUI=1
let NERDTreeDirArrows=1

" Close vim if NERDTree is the only window remaining
autocmd BufEnter * if winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif
