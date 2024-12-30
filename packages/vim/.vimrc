" Check runtimepath/rtp- set runtimepath?
" Check packpath/rtp- set packpath?
" mkdir -p pack/{colorschemes,syntax,others}/{start,opt}
" git -C ~/.vim/pack/others/start clone https://github.com/preservim/nerdtree

" Section: basic {

" Enable project specific vimrc
" Used to try out different plugins
set exrc

set nocompatible
filetype plugin on
set modeline

if !exists("g:syntax_on")
    syntax enable
endif

set number
set showmatch     " Show matching brackets/parenthesis
set showcmd       " Show (partial) command in the last lien of the screen
set incsearch     " Find as you type search
set hlsearch      " Highlight search terms
hi Search cterm=NONE ctermfg=DarkMagenta ctermbg=white "set hlt color for fg and bg

" set global leader ,overwrt w/ maplocalleader
let mapleader = ","

" Do not cross the line
set colorcolumn=150

" Make smart search default
set smartcase
set ignorecase
" }

" Section: status line {

  " Section: ruler {
    if has('cmdline_info')
        set ruler                   " Show the ruler
        set rulerformat=%30(%=\:b%n%y%m%r%w\ %l,%c%V\ %P%) " A ruler on steroids
        set showcmd                 " Show partial commands in status line and
                                    " Selected characters/lines in visual mode
    endif
  "

  " Section: status
  if has('statusline')
      set laststatus=2

      " Broken down into easily includeable segments
      set statusline=%<%f\                     " Filename
      set statusline+=%w%h%m%r                 " Options
      set statusline+=%{exists('g:loaded_fugitive')?fugitive#statusline():''} " Git Hotness
      set statusline+=\ [%{&ff}/%Y]            " Filetype
      set statusline+=\ [%{getcwd()}]          " Current dir
      set statusline+=%=%-14.(%l,%c%V%)\ %p%%  " Right aligned file nav info
  endif
  " }

  " To display # of matches - https://vi.stackexchange.com/questions/15944/how-to-display-in-the-statusline-the-number-of-matches-from-a-search
  set shm-=S

" }

" Section: colors  {
" colorscheme murphy "For vimdiff
if &diff
  colorscheme evening
endif

colorscheme default

highlight clear SignColumn      " SignColumn should match background
highlight clear LineNr          " Current line number row will have same background color in relative mode
highlight clear CursorLineNr    " Remove highlight color from current line number

"set background=light
"set background=dark

" let g:solarized_termcolors = 16
" colorscheme solarized
" let g:molokai_italic=0
" colorscheme molokai

" }

set mouse=r

" Section: auto ops buffers {
set autoread
set autowriteall
autocmd FocusLost * silent! wall

"}

" Section: basic mapping {
imap jk <Esc>

" Remove empty lines
nnoremap <C-c> :g/^$/d<CR>

" Remove empty lines
map ,rel :g/^\s*$/d<CR>

" Easier moving in tabs and windows
" Only using horizontal directions H/L and saving J/K
map <C-L> <C-W>l<C-W>_
map <C-H> <C-W>h<C-W>_

" spell change "navigation  ]s [s
nmap <silent> ,s :set spell!<CR>
set spelllang=en_us
set spellfile=$HOME/.vim/spell/vim-spell-en.utf-8.add

" clear change
map ,cc :colorscheme mac_classic<CR>

" Create the file if not exists
map <leader>gf :e <cfile><cr>

"

" Section: external utilities {

" Ack/ag
if executable('ag')
  let g:ackprg = 'ag --vimgrep'
endif

"

" Section: undo settings {
" set undodir=~/.vim/undodir
" set undofile   " Maintain undo history between sessions

" }

" Section: Plugins {
"Plug 'KevinBockelandt/notoire'
"Plug 'junegunn/vim-easy-align'
"Plug 'tpope/vim-surround'
"Plug 'editorconfig/editorconfig-vim' "editorconfig
"Plug 'tpope/vim-fugitive' "Git
"Plug 'tpope/vim-abolish'
"Plug 'tpope/vim-repeat' "Repeat
"Plug 'tpope/vim-obsession' " Session
"Plug 'tpope/vim-commentary' " gcc
"Plug 'nathanaelkane/vim-indent-guides' "indent
"Plug 'Yggdroot/indentLine' "indent
"Plug 'mattn/emmet-vim' "HTML
"Plug 'christoomey/vim-system-copy'
"Plug 'christoomey/vim-sort-motion'
"Plug 'godlygeek/tabular'
""Plug 'airblade/vim-gitgutter'
"Plug 'morhetz/gruvbox'
"Plug 'pbogut/fzf-mru.vim'
"Plug 'dkarter/bullets.vim'
" Plug 'inkarkat/vim-SpellCheck'
" Plug 'b4b4r07/vim-sqlfmt'
" Plug 'mattn/vim-sqlfmt'

" Plug 'honza/vim-snippets'
" Plug 'SirVer/ultisnips'  "vim-snippets must install to ultisnips work

" If installed using Homebrew
"Plug '/usr/local/opt/fzf'
"Plug 'junegunn/fzf.vim'

"Plug 'vimwiki/vimwiki'
"Plug 'mattn/calendar-vim'
" }

" Section: plugin config {

" Trigger configuration. Do not use <tab> if you use https://github.com/Valloric/YouCompleteMe.
" let g:UltiSnipsExpandTrigger="<tab>"
" let g:UltiSnipsJumpForwardTrigger="<c-b>"
" let g:UltiSnipsJumpBackwardTrigger="<c-z>"
" If you want :UltiSnipsEdit to split your window.
" let g:UltiSnipsEditSplit="vertical"
" let g:UltiSnipsSnippetsDir = "~/.vim-plug/plugged/vim-snippets/UltiSnips"
" let g:UltiSnipsSnippetDirectories=['UltiSnips']

   " Fugitive shortcuts {
   if isdirectory(expand("~/.vim-plug/plugged/vim-fugitive/"))
    if &diff
      set diffopt-=internal
      set diffopt+=vertical
     endif
     "set diffopt+=vertical
     nnoremap <silent> <leader>gs :Gstatus<CR>
     nnoremap <silent> <leader>gd :Gdiff<CR>
     nnoremap <silent> <leader>gc :Gcommit<CR>
     nnoremap <silent> <leader>gb :Gblame<CR>
     nnoremap <silent> <leader>gl :Glog<CR>
     nnoremap <silent> <leader>gp :Git push<CR>
     nnoremap <silent> <leader>gr :Gread<CR>
     nnoremap <silent> <leader>gw :Gwrite<CR>
     nnoremap <silent> <leader>ge :Gedit<CR>
     " Mnemonic _i_nteractive
     nnoremap <silent> <leader>gi :Git add -p %<CR>
     nnoremap <silent> <leader>gg :SignifyToggle<CR>
   endif
   "}
" }

" Functions {

  " Use ctrl+l to switch btn reln and noreln
  function! g:TglRelNmMode()
    set rnu!
  endfunction

  " Toggle relative line number
  nnoremap ,trl :call g:TglRelNmMode()<cr>

  " Smart search
  function! g:SrchSmart()
    set smartcase
    set ignorecase
  endfunction

  nnoremap ,f2 :call g:SrchSmart()<cr>

  " Strip whitespace
  function! StripTrailingWhitespace()
    " Preparation: save last search, and cursor position.
    let _s=@/
    let l = line(".")
    let c = col(".")
    " do the business:
    %s/\s\+$//e
    " clean up: restore previous search history, and cursor position
    let @/=_s
    call cursor(l, c)
  endfunction
"}

  " set zj and zk go to find open folds {
  function! GoToOpenFold(direction)
    if (a:direction == "next")
      normal zj
      let start = line('.')
      while foldclosed(start) != -1
        let start = start + 1
      endwhile
    else
      normal zk
      let start = line('.')
      while foldclosed(start) != -1
        let start = start - 1
      endwhile
    endif
    call cursor(start, 0)
  endfunction
  " }

  " Session {

     " Creates a session {
      function! MakeSession()
        let b:sessiondir = $HOME . "/.vim_sessions" . getcwd()
        if (filewritable(b:sessiondir) != 2)
          exe 'silent !mkdir -p ' b:sessiondir
          redraw!
        endif
        let b:filename = b:sessiondir . '/session.vim'
        exe "mksession! " . b:filename
      endfunction
      " }

      " Updates a session, BUT ONLY IF IT ALREADY EXISTS {
      function! UpdateSession()
        let b:sessiondir = $HOME . "/.vim_session" . getcwd()
        let b:sessionfile = b:sessiondir . "session.vim"
        if (filereadable(b:sessionfile))
          exe "mksession! " . b:filename
        endif
      endfunction
      " }

      " Loads a session if it exists {
      function! LoadSession()
        let b:sessiondir = $HOME . "/.vim_sessions" . getcwd()
        let b:sessionfile = b:sessiondir . "/session.vim"
        if (filereadable(b:sessionfile))
          exe 'source ' b:sessionfile
        else
          echo "No session loaded."
        endif
      endfunction
      "

      " Mapping session {
      "au VimEnter * nested :call LoadSession()
      "Forceful update session automatic
      au VimLeave * :call UpdateSession()
      "Forceful update session manual
      map ,u :call UpdateSession()<CR>
      map ,l :call LoadSession()<CR>
      map ,m :call MakeSession()<CR>
      " }

  " }

  " Marker {
    " Marker generate for the text files
    function! PrependMarker(lvl)
      let l:marker= "--"

      let l:markerspace = l:marker . ' '
      "Add space
      call setline('.', l:markerspace . getline('.'))

      let i = 1
      while i < a:lvl
        let i += 1
        call setline('.', l:marker . getline('.'))
      endwhile

    endfunction

    nnoremap <silent> ,pmr :call PrependMarker(1)<CR>
    nnoremap <silent> ,pmr2 :call PrependMarker(2)<CR>
    nnoremap <silent> ,pmr3 :call PrependMarker(3)<CR>
    nnoremap <silent> ,pmr4 :call PrependMarker(4)<CR>
  " }

" }

" Section: Formatter {

" For when you forget to sudo.. Really Write the file.
cmap w!! w !sudo tee % >/dev/null

" Remove empty lines between the range
":5,12REL
command -range=% REL :<line1>,<line2>g/^\s*$/d

" Format html
command Thtml set ft=html | execute "%!tidy -q -i"

" Format xml
" command Txml set ft=xml | execute "%!tidy -q --indent auto --indent-spaces 4"

" Use xmllint instead of tidy
let $XMLLINT_INDENT="    "
command Txml set ft=xml | execute "%!xmllint --format --recover - 2>/dev/null"

" Format json w/ http://lloyd.github.io/yajl/
command Tjs set ft=json | execute "%!json_reformat"

" Keep single blank
command -range=% KSB :<line1>,<line2>s/\n\{3,}/\r\r/e

" code review with blind eye for vertical distance
"%s/\w/X/g

" Fast formatting pretty print line > 100
nmap ,f1 :g/.\{100,\}/ .!par w100<CR>

set expandtab 
set shiftwidth=2 
set softtabstop=2
set tabstop=2

" Invoke StripTrailingWhitespace for all below files types
autocmd FileType c,cpp,java,go,javascript,python,rst,ruby,rust,yml,perl autocmd BufWritePre <buffer> call StripTrailingWhitespace()

autocmd FileType make setlocal noexpandtab

" }

" Section: Folds {

function! VimNotesFolds(lnum)
  let thisline = getline(a:lnum)
  if thisline =~ "/$"
    return '1'
  elseif thisline =~ "-$"
    return '1'
  else
    return '2'
  endif
endfunction

autocmd BufRead *.vim,.*vimrc set foldenable foldmethod=marker foldlevel=0
set foldmethod=syntax
set foldmarker={,}

" Folds for the note
autocmd FileType note setlocal expandtab shiftwidth=2 softtabstop=2 foldmethod=expr foldexpr=VimNotesFolds(v:lnum)

" XML folding
let g:xml_syntax_folding=1

" }

" Section: Multi Vim Window Settings {
set splitright           " Puts new vsplit windows to the right of the current
set splitbelow           " Puts new split windows to the bottom of the current
set matchpairs+=<:>,`:'  " Match, to be used with %
" }

" Section: vim command auto completion {
" https://stackoverflow.com/questions/9511253/how-to-effectively-use-vim-wildmenu
set wildmenu
set wildmode=longest:list,full
" set wildmenu=list:full
"}

" Section: netrw config {

let g:netrw_banner = 0 "Remove top banner
let g:netrw_liststyle = 3 "tree view
let g:netrw_list_hide = &wildignore
let g:netrw_altv = 1

" let g:netrw_winsize = 25
" let g:netrw_browse_split = 4

"}

" Section: fuzzy finder {

nnoremap <C-p> :Files<CR>
nnoremap <silent> <Leader>. :Files <C-r>=expand("%:h")<CR>/<CR>

" Custom mapping
nnoremap <silent> <Leader>bfs :Files ~/bfs<CR>
nnoremap <silent> <Leader>spec :Files ~/spec<CR>
nnoremap <silent> <Leader>test :Files app/views<CR>

" Most recently used files
nnoremap <silent> <Leader>mru :FZFMru<CR>

" List buffers
nnoremap <silent> <Leader>b :Buffers<CR>

" Open files in vertical horizontal split
nnoremap <silent> <Leader>v :call fzf#run({
\   'right': winwidth('.') / 2,
\   'sink':  'vertical botright split' })<CR>

function! s:buflist()
  redir => ls
  silent ls
  redir END
  return split(ls, '\n')
endfunction

function! s:bufopen(e)
  execute 'buffer' matchstr(a:e, '^[ 0-9]*')
endfunction

nnoremap <silent> <Leader><Enter> :call fzf#run({
\   'source':  reverse(<sid>buflist()),
\   'sink':    function('<sid>bufopen'),
\   'options': '+m',
\   'down':    len(<sid>buflist()) + 2
\ })<CR>

"}

" Section: Navigation {
map <Leader>1 :tabn 1<CR>
map <Leader>2 :tabn 2<CR>
map <Leader>3 :tabn 3<CR>
map <Leader>4 :tabn 4<CR>
map <Leader>5 :tabn 5<CR>
map <Leader>6 :tabn 6<CR>
map <Leader>7 :tabn 7<CR>
map <Leader>8 :tabn 8<CR>
map <Leader>9 :tabn 9<CR>
map <Leader>0 :tab split<CR>
"}

" Section: ag {
" The Silver Searcher
if executable('ag')
  " Use ag over grep
  set grepprg=ag\ --nogroup\ --nocolor

  " Use ag in CtrlP for listing files. Lightning fast and respects .gitignore
  "let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'

  " ag is fast enough that CtrlP doesn't need to cache
  "let g:ctrlp_use_caching = 0
endif

" bind K to grep word under cursor
"nnoremap K :grep! "\b<C-R><C-W>\b"<CR>:cw<CR>

"}
"

" Section: Empty template {
"}

if has('python3')
  silent! python3 1
endif

" Section: copy current file name (relative/absolute) to system clipboard {
if has("mac") || has("gui_macvim") || has("gui_mac")
  " filename       (foo.txt)
  nnoremap <leader>cf :let @*=expand("%:t")<CR>

  " absolute path  (/something/src/foo.txt)
  nnoremap <leader>cF :let @*=expand("%:p")<CR>
endif

" copy current file name (relative/absolute) to system clipboard (Linux version)
if has("gui_gtk") || has("gui_gtk2") || has("gui_gnome") || has("unix")
  " filename (foo.txt)
  nnoremap <leader>cf :let @+=expand("%:t")<CR>

  " absolute path (/something/src/foo.txt)
  nnoremap <leader>cF :let @+=expand("%:p")<CR>

endif
"}

" Section: bullet configuration {
" https://github.com/dkarter/bullets.vim
let g:bullets_enabled_file_types = [
    \ 'markdown',
    \ 'note',
    \ 'text',
    \ 'gitcommit',
    \ 'scratch'
    \]
"}
"

" Section: Java Templates {

autocmd FileType java iabbrev <buffer> psvm public static void main(String[] args) {<CR>}
autocmd FileType java iabbrev <buffer> syo System.out.println();
autocmd FileType java iabbrev <buffer> pcl public class {<CR>}

" Package declaration
autocmd FileType java iabbrev <buffer> pkg package 
" Import statement
autocmd FileType java iabbrev <buffer> imp import 
" Class declaration
autocmd FileType java iabbrev <buffer> puc public class
" Interface declaration
autocmd FileType java iabbrev <buffer> pui public interface

" Methods and Variables
autocmd FileType java iabbrev <buffer> pri private
"" Protected variable
autocmd FileType java iabbrev <buffer> pro protected
" Public method
autocmd FileType java iabbrev <buffer> pub public void

" Java folding
autocmd FileType java setlocal foldmethod=syntax
set foldnestmax=2
set foldlevelstart=1

"}
"
" vim: set et tw=79 foldmarker={,} foldlevel=0 foldmethod=marker spell:
