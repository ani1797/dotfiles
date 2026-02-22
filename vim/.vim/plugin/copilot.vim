" GitHub Copilot configuration

" Copilot is enabled by default
" Accept suggestion with Tab (if copilot has suggestion, otherwise normal tab)
imap <silent><script><expr> <Tab> copilot#Accept("\<Tab>")
let g:copilot_no_tab_map = v:true

" Disable for certain filetypes
let g:copilot_filetypes = {
      \ 'gitcommit': v:false,
      \ 'markdown': v:true,
      \ 'yaml': v:true,
      \ }

" Copilot commands (shown in which-key)
" :Copilot setup - Initial GitHub authentication
" :Copilot enable/disable - Toggle on/off
" :Copilot panel - Open suggestions panel
