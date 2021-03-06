function! s:GetSelection(type)

  " Save the contents of the register.
  let saved_reg = @@
  let saved_selection = &selection
  let &selection = "inclusive"

  " Ignore blockwise selection types.
  if a:type ==# "<C-v>" || a:type ==# 'block'
    return ''
  end

  " Choose the marks based on the mode.
  let is_visual = a:type ==# 'v' || a:type ==# 'V'
  let [m1, m2] = is_visual ? ['`<', '`>'] : ['`[', '`]']

  " Infer the selection type.
  let is_line = a:type ==# 'V' || a:type ==# 'line'
  let selection_type = is_line ? 'V' : 'v'

  " Select the text.
  execute 'normal! ' . m1 . selection_type . m2 . 'y'
  let selection = @@

  " Restore the contents of the register.
  let @@ = saved_reg
  let &selection = saved_selection

  " Return the selection
  return selection
endfunction


function! s:Operate(type)

  " Retrieve the selection for the operator.
  let selection = <SID>GetSelection(a:type)

  " Return early if there is no selection.
  if empty(selection)
    return
  end

  " Evaluate the selection.
  call mrepl#buffer#EvalSelection(selection)
endfunction


" Script mappings.
nnoremap <silent> <script>
      \ <Plug>ReplEval
      \ :set operatorfunc=<SID>Operate<CR>g@
vnoremap <silent> <script>
      \ <Plug>ReplEval
      \ :<C-u>call <SID>Operate(visualmode())<CR>

" Default mappings.
if !hasmapto('<Plug>ReplEval')
  nmap <leader>re <Plug>ReplEval
  vmap <leader>re <Plug>ReplEval
end

