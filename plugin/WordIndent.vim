let leader = get(g:, 'word_indent_leader', '<leader>w')
execute "nnoremap <silent> ".leader."w :<C-U>call WordIndent#SetWordStops('.', -v:count)<CR>"
execute "nnoremap <silent> ".leader."k :<C-U>call WordIndent#SetWordStops('.', -v:count1)<CR>"
execute "nnoremap <silent> ".leader."j :<C-U>call WordIndent#SetWordStops('.', +v:count1)<CR>"
execute "nnoremap <silent> ".leader."W :<C-U>set varsofttabstop= colorcolumn=<CR>"
noremap <expr> < WordIndent#ShiftLeft()
noremap <expr> > WordIndent#ShiftRight()

execute "nnoremap <silent> ".leader."c :<C-U>call WordIndent#SetCcFromVsts()<CR>"
execute "nnoremap <silent> ".leader."v :<C-U>call WordIndent#SetVstsFromCc()<CR>"
execute "nnoremap <silent> ".leader."a :<C-U>call WordIndent#AddCc()<CR>"
execute "nnoremap <silent> ".leader."s :<C-U>call WordIndent#SetCc()<CR>"
execute "nnoremap <silent> ".leader."i :<C-U>call WordIndent#ToggleIndent()<CR>"
execute "nnoremap <silent> ".leader."I :<C-U>call WordIndent#ToggleAuto()<CR>"
execute "nnoremap <silent> ".leader."C :<C-U>let g:word_indent_auto_cc=1-get(g:, 'word_indent_auto_cc', 1)<Cr>"

" INSERT mode mapping
inoremap <expr> <S-Tab> WordIndent#ToggleWordStops() ?? "<Tab>"
inoremap <Cr> <C-\><C-o>:<C-U>call WordIndent#SetWordStopsIf()<Cr><Cr>
inoremap <expr> <C-G><C-G> WordIndent#ToggleWordStops() ?? ""
inoremap <expr> <C-D> WordIndent#SetShiftWidth('left', 1) ??  "<C-F>"
inoremap <expr> <C-T> WordIndent#SetShiftWidth('right', 1) ?? "<C-F>"
inoremap <C-G>0 0<C-D>
inoremap <C-G><Tab> 0<C-D><Tab>
imap <C-G><S-Tab> <C-G>0<C-g><C-g><C-T><C-g><C-g>

set indentexpr=WordIndent#ToggleIndent()

call WordIndent#InstallAuto(1)

set rulerformat=#%{undotree().seq_cur}

augroup word_indent_shift
  autocmd InsertLeave * call WordIndent#RestoreShiftWidth()
augroup END
