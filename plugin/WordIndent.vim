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

execute "nnoremap <silent> ".leader."c :<C-U>call WordIndent#SetCcFromVsts()<CR>"
execute "nnoremap <silent> ".leader."v :<C-U>call WordIndent#SetVstsFromCc()<CR>"
execute "nnoremap <silent> ".leader."a :<C-U>call WordIndent#AddCc()<CR>"
execute "nnoremap <silent> ".leader."s :<C-U>call WordIndent#SetCc()<CR>"
execute "nnoremap <silent> ".leader."i :<C-U>call WordIndent#ToggleIndent()<CR>"
execute "nnoremap <silent> ".leader."I :<C-U>call WordIndent#ToggleAuto()<CR>"

set indentexpr=WordIndent#ToggleIndent()

call WordIndent#InstallAuto(1)

