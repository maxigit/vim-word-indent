let leader = get(g:, 'word_indent_leader', '<leader>w')
execute "nnoremap <silent> ".leader."w :<C-U>call WordIndent#SetWordStops('.', -v:count)<CR>"
execute "nnoremap <silent> ".leader."k :<C-U>call WordIndent#SetWordStops('.', -v:count1)<CR>"
execute "nnoremap <silent> ".leader."j :<C-U>call WordIndent#SetWordStops('.', +v:count1)<CR>"
execute "nnoremap <silent> ".leader."W :<C-U>set varsofttabstop= colorcolumn=<CR>"
inoremap <silent> <S-Tab> <C-o>:<C-U>call WordIndent#SetWordStops('.', -1)<CR>
inoremap <silent> <Cr> <C-o>:<C-U>call WordIndent#SetWordStops('.', )<CR><Cr>

execute "nnoremap <silent> ".leader."c :<C-U>call WordIndent#SetCcFromVsts()<CR>"
execute "nnoremap <silent> ".leader."v :<C-U>call WordIndent#SetVstsFromCc()<CR>"

" autocmd InsertEnter  * call WordIndent#SetWordStops('.')
" autocmd InsertEnter  * call SetWordStopsIf()
" autocmd InsertLeave  * set varsofttabstop= colorcolumn=

function SetWordStopsIf()
	if (&varsofttabstop==0)
		call WordIndent#SetWordStops('.')
        endif
endfunction
