"External programs
" Use ACK for vimgrep
set grepprg=ack 
set grepformat=%f:%l:%m

"invoke with gq
:set formatprg=par\ -w80j
highlight ColorColumn ctermbg=magenta
call matchadd('ColorColumn','\%81v',100)
"set colorcolumn=81

