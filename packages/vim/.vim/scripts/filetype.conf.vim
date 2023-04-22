if has("autocmd") "to listen for an event and to execute the specified commands whenever that event fires
    "set no
    set nocompatible
    " Enable file type detection
    filetype on
    " Syntax of these languages is fussy over tabs Vs spaces

    "automatic sourcing after saving the file
    autocmd bufwritepost .vimrc source $MYVIMRC

    autocmd FileType make setlocal ts=8 sts=8 sw=8 noexpandtab
    autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab

    " Customisations based on house-style (arbitrary)
    autocmd FileType html setlocal ts=2 sts=2 sw=2 expandtab
    autocmd FileType css setlocal ts=2 sts=2 sw=2 expandtab
    autocmd FileType javascript setlocal ts=4 sts=4 sw=4 noexpandtab

    " Treat .rss files as XML
    autocmd BufNewFile,BufRead *.rss setfiletype xml
    au BufNewFile,BufRead *.handlebars setfiletype html

    "Redo use <ctrl-r>	
    "autocmd BufRead *.py set smartindent cinwords=if,elif,else,for,while,try,except,finally,def,class
endif

