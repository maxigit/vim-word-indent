let leader = get(g:, 'word_indent_leader', '<leader>w')
execute "nnoremap <silent> ".leader."w :<C-U>call WordIndent#SetWordStops('.', -v:count)<CR>"
execute "nnoremap <silent> ".leader."k :<C-U>call WordIndent#SetWordStops('.', -v:count1)<CR>"
execute "nnoremap <silent> ".leader."j :<C-U>call WordIndent#SetWordStops('.', +v:count1)<CR>"
execute "nnoremap <silent> ".leader."W :<C-U>set varsofttabstop= colorcolumn=<CR>"
inoremap <expr> <S-Tab> WordIndent#ToggleWordStops() ?? "<Tab>"
inoremap <C-D> <C-O>:call WordIndent#SetShiftWidth('left', 1)<Cr>
               \<C-F>
               \<C-\><C-O>:call WordIndent#RestoreShiftWidth()<Cr>
inoremap <C-T> <C-O>:call WordIndent#SetShiftWidth('right', 1)<Cr>
               \<C-F>
               \<C-\><C-O>:call WordIndent#RestoreShiftWidth()<Cr>
noremap <expr> < WordIndent#ShiftLeft()
noremap <expr> > WordIndent#ShiftRight()
" map >> >>
" map << <<

execute "nnoremap <silent> ".leader."c :<C-U>call WordIndent#SetCcFromVsts()<CR>"
execute "nnoremap <silent> ".leader."v :<C-U>call WordIndent#SetVstsFromCc()<CR>"
execute "nnoremap <silent> ".leader."a :<C-U>call WordIndent#AddCc()<CR>"
execute "nnoremap <silent> ".leader."s :<C-U>call WordIndent#SetCc()<CR>"
execute "nnoremap <silent> ".leader."i :<C-U>call WordIndent#ToggleIndent()<CR>"

set indentexpr=WordIndent#ToggleIndent()

if  get(g:, 'word_indent_auto_stops', get(b:, 'word_indent_auto_stops', 1))
 augroup word_indent
 autocmd InsertEnter  * call WordIndent#SetWordStopsIf()
 autocmd InsertLeave  * call WordIndent#UnsetWordStops()
 augroup END            
endif

