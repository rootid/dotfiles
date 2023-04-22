set omnifunc=syntaxcomplete#Complete 	

"tab complete 	
"http://stackoverflow.com/questions/2170023/how-to-map-keys-for-popup-menu-in-vim	
function! OmniPopup(action)	
if pumvisible()	
 if a:action == 'j'	
      return "\<C-N>"	
      elseif a:action == 'k'	
      return "\<C-P>"	
      endif	
    endif	
 return a:action	
endfunction	
inoremap <silent><C-j> <C-R>=OmniPopup('j')<CR>	
inoremap <silent><C-k> <C-R>=OmniPopup('k')<CR>	


" Enable omni completion.
autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
autocmd FileType cml,oml,fxml setlocal omnifunc=xmlcomplete#CompleteTags
