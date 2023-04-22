"Fuzzy-search,marking,diffthis
"File Naviagation ctrlp plugin 	
":set runtimepath^=~/dotconfig/.vim/bundle/ctrlp.vim 	

let g:ctrlp_show_hidden = 1	
let g:ctrlp_max_height = 30	

let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP'

let g:ctrlp_working_path_mode = 'ra'

set wildignore+=*/tmp/*,*.so,*.swp,*.zip   

let g:ctrlp_user_command = 'find %s -type f'        


"Use :diffthis when opening files marked by <c-z> to run :diffthis on the first 4 files
"Press <F5> to purge the cache for the current directory to get new files, remove deleted files and apply new ignore options.
"Press <c-f> and <c-b> to cycle between modes.
"Press <c-d> to switch to filename search instead of full path.
"Press <c-r> to switch to regexp mode.
"Use <c-j>, <c-k> or the arrow keys to navigate the result list.
"Use <c-t> or <c-v>, <c-x> to open the selected entry in a new tab or in a new split.
"Use <c-n>, <c-p> to select the next/previous string in the prompt's history.
"Use <c-y> to create a new file and its parent directories.
"Use <c-z> to mark/unmark multiple files and <c-o> to open them.
