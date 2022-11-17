let leader = get(g:, 'word_indent_leader', '<leader>w')
execute "nnoremap <silent> ".leader."w :<C-U>call WordIndent#SetTabStops('.', -v:count)<CR>"
execute "nnoremap <silent> ".leader."k :<C-U>call WordIndent#SetTabStops('.', -v:count1)<CR>"
execute "nnoremap <silent> ".leader."j :<C-U>call WordIndent#SetTabStops('.', +v:count1)<CR>"
execute "nnoremap <silent> ".leader."W :<C-U>set varsofttabstop= colorcolumn=<CR>"
inoremap <silent> <S-Tab> <C-o>:<C-U>call WordIndent#SetTabStops('.', -1)<CR>
inoremap <silent> <Cr> <C-o>:<C-U>call WordIndent#SetTabStops('.', )<CR><Cr>


" autocmd InsertEnter  * call WordIndent#SetTabStops('.')
" autocmd InsertEnter  * call SetTabStopsIf()
" autocmd InsertLeave  * set varsofttabstop= colorcolumn=

function SetTabStopsIf()
	if (&varsofttabstop==0)
		call WordIndent#SetTabStops('.')
        endif
endfunction
