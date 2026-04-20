" iTerm2 pane navigation — sentinel file + Hammerspoon handoff.
let s:save_cpo = &cpo | set cpo&vim

" ITERM_SESSION_ID format is "wXtXpX:UUID" — extract just the UUID part so
" Hammerspoon can stat /tmp/.vim_iterm_<uuid> directly (no shell glob needed).
let s:iterm_uuid = matchstr($ITERM_SESSION_ID, '[^:]\+$')
if !empty(s:iterm_uuid)
  augroup itermNavigatorSentinel
    autocmd!
    autocmd VimEnter * silent! call writefile([], '/tmp/.vim_iterm_' . s:iterm_uuid)
    autocmd VimLeave * silent! call delete('/tmp/.vim_iterm_' . s:iterm_uuid)
  augroup END
endif

" Navigate vim splits; at edge write to file so Hammerspoon switches the iTerm2
" pane via pathwatcher (~15ms vs ~80ms for spawning shell+hs+IPC).
" SwitchWindow must be global — switch.py calls it by name via escape sequence.
function! SwitchWindow(dir)
  let l:prev = winnr()
  execute 'wincmd ' . a:dir
  if winnr() == l:prev
    silent! call writefile([a:dir], '/tmp/.hs_nav_request')
  endif
endfunction

" Bound in VimEnter so these load after plugins (vim-move claims <C-j/k>).
augroup itermNavigatorKeys
  autocmd!
  autocmd VimEnter * nnoremap <silent> <C-h> :call SwitchWindow('h')<CR>
  autocmd VimEnter * nnoremap <silent> <C-j> :call SwitchWindow('j')<CR>
  autocmd VimEnter * nnoremap <silent> <C-k> :call SwitchWindow('k')<CR>
  autocmd VimEnter * nnoremap <silent> <C-l> :call SwitchWindow('l')<CR>
augroup END

let &cpo = s:save_cpo | unlet s:save_cpo
