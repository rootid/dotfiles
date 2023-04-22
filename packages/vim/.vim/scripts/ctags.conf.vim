"Reload the ctags
nnoremap <f5> :!ctags -R <CR>
"tags =./tags,tags
" horizontal and vertical split with alt + [
map <A-[> :tab split<CR>:exec("tag ".expand("<cword>"))<CR>
map <A-]> :vsp <CR>:exec("tag ".expand("<cword>"))<CR>
