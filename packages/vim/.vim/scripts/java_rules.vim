
source ~/vim_scripts/jcommenter.vim
map ,c1 :call JCommentWriter()<CR>
"let @a = ',c1 nn'

"for xml
"set foldmethod=syntax
"let g:xml_syntax_folding=1
"
"Clean formatting
"1. Remove \n }
"g/^$\n}/s/$\n}/}/g

"accountNumber to account number
":s/\<\u\|\l\u/\= join(split(tolower(submatch(0)), '\zs'), ' ')/g

"update to Update
"%s/\/\/ \(\w\)/\/\/ \u\1/g

"Add setter from field
"'a,'bs/\(\w\+\) =\p\+/approvedMessageDTO.set\u\1(\1);/g

"Enum w/ docs
":'a,'bs/\(\p\+\)\((\p\+\)/\/**\r * The \1 \r *\/\r\1\2/g

"fields to mockFields
"%s/\(private \w\+\) \(\w\+\)/\1 mock\u\2/g
"Mock w/ docs
":'a,'bs/\(private \w\+ \)mock\(\w\+\);/\/**\r * The mock for {@link \2} \r *\/\r\1mock\2;/g

"Java docs for class
"'a,'bs/\(private \w\+ \)\(\w\+\);/\/**\r * The \2 \r *\/\r\1\2;/g

"Param
"'a,'b s/\(@param \)\(\w\+$\)/\1\2 the \2/g

"Change to final
"'a,'bs/\(^\s\+\)\(\w\+\)/\1final \2/g


map ,s1 :%s/",\(\S\+\)/", \1/g<CR> "‘,’ is not followed by whitespace.
map ,s2 :%s/for(/for (/g<CR> "‘for’ is not followed by whitespace.
map ,s3 :%s/if(/if (/g<CR> "‘if’ is not followed by whitespace.
map ,s4 :%s/\(\w\+\)\(=\)\(\w\+\)/\1 \2 \3/g<CR> ” = is not followed by whitespace.
map ,s5 :%s/\(\w\+\)\(\<\)\(\w\+\)/\1 \2 \3/g<CR> ” < is not followed by whitespace.
map ,s6 :%s/,\(\S\+\)/, \1/g<CR> "‘,’ is not followed by whitespace.
map ,s7 :%s/catch(/catch (/g<CR> "‘catch’ is not followed by whitespace.
map ,s8 :%s/+"/+ "/g<CR> "‘+’ is not followed by whitespace.

"'a,'bs/\(^\s\+\)\(\w\+\)/\1final \2/g #Add final prefix to all vars
"'a,'b s/\(@param \)\(\w\+$\)/\1\2 the \2/g "Add param
map ,s9 :%s/){/) {/g<CR> "‘{’ is not followed by whitespace.
map ,c3 :%s/\(@param \)\(\w\+$\)/\1\2 the \2/g "Add @param xyz to @param xyz the xyz
map ,c6 :%s/^\s*$\n^}/}/g<CR> "last empty record
map ,c7 :s/\([A-Z]\)/ \l\1/g<CR> "convert LoanId to loan id

"single space between words
map ,c5 :%s/\(\w\+\s\)\s\+/\1/g<CR>
":%s/\(\w\)\s\+\(\w\)/\1 \2/g


":'a,'b s/ \*$/ \* The/g "TODO : add the comments based on the variable
"
"%s/^\s*$\n^}/}/g "Remove blank line in the end
"
"silent! argdo %s/^\s*$\n^}/}/g

"Run spell checker for individual file
map ,a1 :!aspell check --mode ccpp % <CR>

"abc,def,ghi to
"abc,
"def,
"Use in visualize mode
map ,c2 :%s/, /,\r/g<CR>


" Java flding
set foldmarker={,}
set foldmethod=marker
set foldtext=substitute(getline(v:foldstart),'{.*','{...}',)
set foldcolumn=4
set foldlevelstart=1

"Mr flds
"set foldermarker1={,}
"set foldermarker2=/*,*/

"Fold navigation {{{
nnoremap <silent> <leader>zj :call NextClosedFold('j')<cr>
nnoremap <silent> <leader>zk :call NextClosedFold('k')<cr>
function! NextClosedFold(dir)
    let cmd = 'norm!z' . a:dir
    let view = winsaveview()
    let [l0, l, open] = [0, view.lnum, 1]
    while l != l0 && open
        exe cmd
        let [l0, l] = [l, line('.')]
        let open = foldclosed(l) < 0
    endwhile
    if open
        call winrestview(view)
    endif
endfunction
"}}}


set path=$PWD/**
"set path=/Users/visawant/fp-raptor/**
set wildignore+=**/target/**


"Remove empty lines between 2 lines {{{

"Add blank line between private
":5,12ABL
command -range=% ABL :<line1>,<line2>s/\(^\s\+private \p\+;\)/\1\r/g
command -range=% ABL1 :<line1>,<line2>s/\(^\s\+public \p\+;\)/\1\r/g
"}}}
"
command -range=% PAD :<line1>,<line2>s/\(\(public\|private\) \p\+{\)/\1\r/g

let g:xml_syntax_folding=1
au FileType xml setlocal foldmethod=syntax


:abbr fn final
:abbr pv private
