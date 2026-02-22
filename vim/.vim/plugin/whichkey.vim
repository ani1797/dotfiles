" vim-which-key configuration

" Enable which-key on leader key
nnoremap <silent> <leader> :<c-u>WhichKey '<Space>'<CR>
nnoremap <silent> <localleader> :<c-u>WhichKey '\'<CR>

" Define leader key mappings
let g:which_key_map = {}

" File operations
let g:which_key_map.f = {
      \ 'name' : '+find',
      \ 'f' : 'files',
      \ 'g' : 'grep',
      \ 'b' : 'buffers',
      \ 'h' : 'history',
      \ }

" Explorer
let g:which_key_map.e = {
      \ 'name' : '+explorer',
      \ '' : 'toggle',
      \ 'f' : 'find-current',
      \ }

" AI
let g:which_key_map.a = {
      \ 'name' : '+ai',
      \ 'i' : 'ask-gemini',
      \ 'e' : 'explain',
      \ }

" Code
let g:which_key_map.c = {
      \ 'name' : '+code',
      \ 'a' : 'action',
      \ }

" Rename
let g:which_key_map.r = {
      \ 'name' : '+refactor',
      \ 'n' : 'rename',
      \ }

" Register which-key map
call which_key#register('<Space>', "g:which_key_map")

" Show which-key popup on leader key
set timeoutlen=500
