" Gemini CLI integration

" Ask Gemini about visual selection
vnoremap <leader>ai :call AskGemini()<CR>

" Explain current buffer with Gemini
nnoremap <leader>ae :call ExplainWithGemini()<CR>

function! AskGemini() range
  " Check if gemini is available
  if !executable('gemini')
    echohl ErrorMsg
    echo "Gemini CLI not found. Install from https://ai.google.dev/gemini-api/docs/cli"
    echohl None
    return
  endif

  " Get visual selection
  let l:lines = getline(a:firstline, a:lastline)
  let l:selection = join(l:lines, "\n")

  " Escape single quotes for shell
  let l:escaped = substitute(l:selection, "'", "'\\\\''", 'g')

  " Call gemini CLI
  let l:cmd = "gemini ask '" . l:escaped . "'"
  let l:result = system(l:cmd)

  if v:shell_error != 0
    echohl ErrorMsg
    echo "Gemini CLI error: " . l:result
    echohl None
    return
  endif

  " Insert result below selection
  call append(a:lastline, split(l:result, "\n"))
endfunction

function! ExplainWithGemini()
  " Check if gemini is available
  if !executable('gemini')
    echohl ErrorMsg
    echo "Gemini CLI not found. Install from https://ai.google.dev/gemini-api/docs/cli"
    echohl None
    return
  endif

  " Get buffer content
  let l:lines = getline(1, '$')
  let l:content = join(l:lines, "\n")
  let l:escaped = substitute(l:content, "'", "'\\\\''", 'g')

  " Ask gemini to explain
  let l:cmd = "gemini ask 'Explain this code: " . l:escaped . "'"
  let l:result = system(l:cmd)

  if v:shell_error != 0
    echohl ErrorMsg
    echo "Gemini CLI error: " . l:result
    echohl None
    return
  endif

  " Open result in new split
  new
  setlocal buftype=nofile bufhidden=wipe noswapfile
  call setline(1, split(l:result, "\n"))
endfunction
