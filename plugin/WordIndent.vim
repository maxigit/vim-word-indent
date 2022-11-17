let leader = get(g:, 'word_indent_leader', '<leader>w')
execute "nnoremap <silent> ".leader."w :<C-U>call WordIndent#SetWordStops('.', -v:count)<CR>"
execute "nnoremap <silent> ".leader."k :<C-U>call WordIndent#SetWordStops('.', -v:count1)<CR>"
execute "nnoremap <silent> ".leader."j :<C-U>call WordIndent#SetWordStops('.', +v:count1)<CR>"
execute "nnoremap <silent> ".leader."W :<C-U>set varsofttabstop= colorcolumn=<CR>"
inoremap <silent> <S-Tab> <C-o>:<C-U>call WordIndent#SetWordStops('.', -1)<CR>
" inoremap <silent> <Cr> <C-o>:<C-U>call WordIndent#SetWordStops('.', )<CR><Cr>

execute "nnoremap <silent> ".leader."c :<C-U>call WordIndent#SetCcFromVsts()<CR>"
execute "nnoremap <silent> ".leader."v :<C-U>call WordIndent#SetVstsFromCc()<CR>"
execute "nnoremap <silent> ".leader."a :<C-U>call WordIndent#AddCc()<CR>"
execute "nnoremap <silent> ".leader."s :<C-U>call WordIndent#SetCc()<CR>"
execute "nnoremap <silent> ".leader."i :<C-U>call WordIndent#ToggleIndent()<CR>"

set indentexpr=WordIndent#ToggleIndent()

" autocmd InsertEnter  * call WordIndent#SetWordStops('.')
autocmd InsertEnter  * call SetWordStopsIf()
autocmd InsertLeave  * call UnsetWordStops()

function SetWordStopsIf()
  echo ':' &vsts ':'
	if &varsofttabstop == 0
      let b:word_indent_set_ = 1
		call WordIndent#SetWordStops('.')
  endif
endfunction

function UnsetWordStops()
  if get(b:, 'word_indent_set_') == 1
    set varsofttabstop= colorcolumn=
    let b:word_indent_set_ = 0
  endif
endfunction
