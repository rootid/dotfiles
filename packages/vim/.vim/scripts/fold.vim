
set foldexpr=strlen(matchstr(getline(v:lnum),'^-*'))
set foldmethod=expr

set foldmethod=marker
set foldmarker={,}


" }}}
" Java {{{

"augroup ft_java
"    au!
"
"    au FileType java setlocal foldmethod=marker
"    au FileType java setlocal foldmarker={,}
"augroup END
"
"" }}}
"
"" }}}
"" Javascript {{{
"
"
"
"" Python {{{
"
"augroup ft_python
"    au!
"
"    au FileType python setlocal define=^\s*\\(def\\\\|class\\)
"    au FileType man nnoremap <buffer> <cr> :q<cr>
"
"    " Jesus tapdancing Christ, built-in Python syntax, you couldn't let me
"    " override this in a normal way, could you?
"    au FileType python if exists("python_space_error_highlight") | unlet python_space_error_highlight | endif
"
"    " Jesus, Python.  Five characters of punctuation for a damn string?
"    au FileType python inoremap <buffer> <c-g> _(u'')<left><left>
"
"    au FileType python inoremap <buffer> <c-b> """"""<left><left><left>
"augroup END
"
"" }}}
"
"augroup ft_javascript
"    au!
"
"    au FileType javascript setlocal foldmethod=marker
"    au FileType javascript setlocal foldmarker={,}
"
"    " Make {<cr> insert a pair of brackets in such a way that the cursor is correctly
"    " positioned inside of them AND the following code doesn't get unfolded.
"    au Filetype javascript inoremap <buffer> {<cr> {}<left><cr><space><space><space><space>.<cr><esc>kA<bs>
"augroup END
"
"" }}}
"
