"Clean blank lines
nnoremap <C-c> :g/^$/d<CR>


":%s/",\S/", /g :  " add the space before ,
":%s/^I/  /g " Replace the tabs
":%s/(\s\+/(/g "Remove the white spaces after "("
":%s/\s\+(/(/g "Remove the white spaces before "("
":%s/\s\+)/)/g "Replace all white spaces before ")"
":%g/System/d "Remove all system.out
":%s/,\(\w\+\)/, \1/g " Insert space between words separated by ',' \0 : whole string \1:matched string
":%s/if(/if (/g 
":%s/catch(/catch (/g 
":%!jq '.' " Jq formatting
"::1,$s/_\([a-z]\)/\u\1/g  :underscore to camelcase
"!grep with % | awk '{print $3}' | cut -d "(" -f1 " use of commandline
":%s/^\s\+,//gn " white-space 

"Format html
command Thtml set ft=html | execute "%!tidy -q -i"

"Format xml
"command Txml set ft=xml | execute "%!tidy -q -i"

"Use xmllint instead of tidy
command Txml set ft=xml | execute "%!xmllint --format --recover - 2>/dev/null"

"Format json
command Tjs set ft=json | execute "%!jq ."

"Sort CSS
command Scss set ft=css | execute "g/{/ .+1,/}/-1 sort"

let mapleader = ","
""Keep only single blank line
""nnoremap <C-c> g/^\_$\n\_^$/d<CR>
nnoremap <leader>c :g/^\_$\n\_^$/d<CR>
nnoremap <leader>a :?{?+1;/}/-1sort i<CR>

