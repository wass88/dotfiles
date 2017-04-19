" vim:set foldmethod=marker:
set nocompatible
filetype off
filetype plugin indent off
" core "{{{
"" disable default plugins "{{{
let g:loaded_gzip              = 1
let g:loaded_tar               = 1
let g:loaded_tarPlugin         = 1
let g:loaded_zip               = 1
let g:loaded_zipPlugin         = 1
let g:loaded_rrhelper          = 1
let g:loaded_vimball           = 1
let g:loaded_vimballPlugin     = 1
let g:loaded_getscript         = 1
let g:loaded_getscriptPlugin   = 1
""}}}
"" NeoBundle "{{{ 
if has('vim_starting')
  if !isdirectory(expand("~/.vim/bundle/neobundle.vim/"))
    echo "install neobundle..."
    :call system("git clone git://github.com/Shougo/neobundle.vim ~/.vim/bundle/neobundle.vim")
  endif
  if !isdirectory(expand("~/.vim/tmp/"))
    :call mkdir(expand("~/.vim/tmp/"),"p")
  endif
  set runtimepath+=~/.vim/bundle/neobundle.vim
endif
call neobundle#begin(expand('~/.vim/bundle/'))
NeoBundleFetch 'Shougo/neobundle.vim'
""}}}
"" ideone"{{{
NeoBundle "mattn/webapi-vim"
""}}}
"" vimproc "{{{
if !has('gui_running')
NeoBundle 'Shougo/vimproc', {
\ 'build' : {
\     'windows' : 'make -f make_mingw32.mak',
\     'cygwin' : 'make -f make_cygwin.mak',
\     'mac' : 'make -f make_mac.mak',
\     'unix' : 'make -f make_unix.mak',
\    },
\ }
end
""}}}
"" submode "{{{
NeoBundle "kana/vim-submode"
let g:submode_keep_leaving_key=1
set noshowmode
let g:submode_timeout=0
""}}}
"" vital "{{{
NeoBundle "vim-jp/vital.vim"
"...
""}}}
"}}}
" apperance "{{{
"" basic "{{{
set number
set display=lastline
""}}}
"" colorscheme "{{{
NeoBundle "w0ng/vim-hybrid"
NeoBundle "chriskempson/vim-tomorrow-theme"
NeoBundle "jpo/vim-railscasts-theme"
set synmaxcol =200

autocmd ColorScheme * highlight SpellBad term=underline cterm=underline ctermfg=9 ctermbg=NONE
autocmd ColorScheme * highlight LineNr ctermfg=247 guifg=#909090
autocmd ColorScheme * highlight Comment ctermfg=252 guifg=#969896 cterm=BOLD gui=BOLD
autocmd ColorScheme * highlight SpecialKey ctermfg=247 guifg=#606060
autocmd ColorScheme * highlight NonText ctermfg=247 guifg=#606060
autocmd FileType coq highlight SentToCoq ctermbg=17 guibg=#000080
" autocmd ColorScheme * highlight VertSplit ctermfg=246 ctermbg=239
set t_Co=256
syntax on
""}}}
"" character hilight "{{{
set ambiwidth=double
"set cursorline
set list
set listchars=tab:^\ ,trail:~,eol:_

set hlsearch
" turn off highlight on enter twice
nnoremap <silent><Esc><Esc> :<C-u>nohlsearch<CR>
nnoremap <silent><C-l><C-l> :<C-u>nohlsearch<CR>

" highlight parenttheses
let g:lisp_instring = 1
let g:lisp_rainbow = 1

function! ZenkakuSpace()
  highlight ZenkakuSpace cterm=underline ctermfg=darkgrey gui=underline guifg=darkgrey
endfunction

if has('syntax')
  augroup ZenkakuSpace
    autocmd!
    " ZenkakuSpaceをカラーファイルで設定するなら次の行は削除
    autocmd ColorScheme       * call ZenkakuSpace()
    " 全角スペースのハイライト指定
    autocmd VimEnter,WinEnter * match ZenkakuSpace /　/
    autocmd VimEnter,WinEnter * match ZenkakuSpace '\%u3000'
  augroup END
  call ZenkakuSpace()
endif
""}}}
"" indent highlight "{{{
NeoBundle 'Yggdroot/indentLine'
let g:indentLine_faster = 1
""}}}
"" folding "{{{
NeoBundle 'LeafCage/foldCC'
set foldmethod=marker
set foldtext=FoldCCtext()
set foldcolumn=1
set fillchars=vert:\|
noremap zs za
"}}}
"" lightline "{{{
NeoBundle 'itchyny/lightline.vim'
set laststatus=2
set cmdheight=2
set showcmd
let g:lightline = {
\   'colorscheme': 'wombat',
\   'mode_map': {'c': 'NORMAL'},
\   'active': {
\     'left': [
\       ['mode', 'paste'],
\       ['fugitive', 'gitgutter', 'filename',],
\     ],
\     'right': [
\       ['lineinfo'],
\       ['currentdir', 'filetype'],
\       ['charcode', 'fileformat', 'fileencoding'],
\     ]
\   },
\   'component_function': {
\     'modified': 'MyModified',
\     'readonly': 'MyReadonly',
\     'filename': 'MyFilename',
\     'fugitive': 'MyFugitive',
\     'lineinfo': 'MyLineinfo',
\     'currentdir': 'MyCurrentdir',
\     'fileformat': 'MyFileformat',
\     'filetype': 'MyFiletype',
\     'fileencoding': 'MyFileencoding',
\     'mode': 'MyMode',
\     'syntastic': 'SyntasticStatuslineFlag',
\     'charcode': 'MyCharCode',
\     'gitgutter': 'MyGitGutter',
\   },
\   'separator': {'left': '', 'right': ''},
\   'subseparator': {'left': '|', 'right': '|'}
\}

function! MyModified()
    return &ft =~ 'help\|vimfiler\|gundo' ? '' : &modified ? '+' : &modifiable ? '' : '-'
endfunction

function! MyReadonly()
    return &ft !~? 'help\|vimfiler\|gundo' && &ro ? 'RO' : ''
endfunction

function! MyFilename()
    return ('' != MyReadonly() ? MyReadonly() . ' ' : '') .
                \ (&ft == 'vimfiler' ? vimfiler#get_status_string() :
                \  &ft == 'unite' ? unite#get_status_string() :
                \  &ft == 'vimshell' ? substitute(b:vimshell.current_dir,expand('~'),'~','') :
                \ '' != expand('%:t') ? expand('%:t') : '[No Name]') .
                \ ('' != MyModified() ? ' ' . MyModified() : '')
endfunction

function! MyCurrentdir()
    return getcwd()
endfunction

function! MyFugitive()
    try
        if &ft !~? 'vimfiler\|gundo' && exists('*fugitive#head')
            let _ = fugitive#head()
            return strlen(_) ? 'ﾄ'._ : ''
        endif
    catch
    endtry
    return ''
endfunction

function! MyLineinfo()
    return printf("%d/%d:%d", line("."), line('$'), col('.'))
endfunction

function! MyFileformat()
    return winwidth('.') > 70 ? &fileformat : ''
endfunction

function! MyFiletype()
    return winwidth('.') > 70 ? (strlen(&filetype) ? &filetype : 'no ft') : ''
endfunction

function! MyFileencoding()
    return winwidth('.') > 70 ? (strlen(&fenc) ? &fenc : &enc) : ''
endfunction

function! MyMode()
    return winwidth('.') > 60 ? lightline#mode() : ''
endfunction

function! MyGitGutter()
    if ! exists('*GitGutterGetHunkSummary')
                \ || ! get(g:, 'gitgutter_enabled', 0)
                \ || winwidth('.') <= 90
        return ''
    endif
    let symbols = [
                \ g:gitgutter_sign_added . '+',
                \ g:gitgutter_sign_modified . 'M',
                \ g:gitgutter_sign_removed . '-'
                \ ]
    let hunks = GitGutterGetHunkSummary()
    let ret = []
    for i in [0, 1, 2]
        if hunks[i] > 0
            call add(ret, symbols[i] . hunks[i])
        endif
    endfor
    return join(ret, ' ')
endfunction

function! MyCharCode()
    if winwidth('.') <= 70
        return ''
    endif

    " Get the output of :ascii
    redir => ascii
    silent! ascii
    redir END

    if match(ascii, 'NUL') != -1
        return 'NUL'
    endif

    " Zero pad hex values
    let nrformat = '0x%02x'

    let encoding = (&fenc == '' ? &enc : &fenc)

    if encoding == 'utf-8'
        " Zero pad with 4 zeroes in unicode files
        let nrformat = '0x%04x'
    endif

    " Get the character and the numeric value from the return value of :ascii 
    " This matches the two first pieces of the return value, e.g.
    " "<F> 70" => char: 'F', nr: '70'
    let [str, char, nr; rest] = matchlist(ascii, '\v\<(.{-1,})\>\s*([0-9]+)')

    " Format the numeric value
    let nr = printf(nrformat, nr)

    return "'". char ."' ". nr
endfunction
""}}}
"" fast scroll {{{
" Use vsplit mode
" if has("vim_starting") && !has('gui_running') && has('vertsplit')
"   function! g:EnableVsplitMode()
"     " enable origin mode and left/right margins
"     let &t_CS = "y"
"     let &t_ti = &t_ti . "\e[?6;69h"
"     let &t_te = "\e[?6;69l\e[999H" . &t_te
"     let &t_CV = "\e[%i%p1%d;%p2%ds"
"     call writefile([ "\e[?6;69h" ], "/dev/tty", "a")
"   endfunction
"
"   " old vim does not ignore CPR
"   map <special> <Esc>[3;9R <Nop>
"
"   " new vim can't handle CPR with direct mapping
"   " map <expr> ^[[3;3R  g:EnableVsplitMode()
"   set t_F9=[3;3R
"   map <expr> <t_F9> g:EnableVsplitMode()
"   let &t_RV .= "\e[?6;69h\e[1;3s\e[3;9H\e[6n\e[0;0s\e[?6;69l"
" endif
set lazyredraw
set ttyfast
""}}}
"}}}
" exec "{{{
"" quickrun&fix "{{{
NeoBundle "thinca/vim-quickrun"
NeoBundle "osyo-manga/shabadou.vim"
NeoBundle "osyo-manga/unite-quickfix"
let g:quickrun_config = {
\   "_" : {
\       "runner" : "vimproc",
\       "runner/vimproc/updatetime" : 40,
\       "hook/quickfix_replate_tempname_to_bufnr/enable_exit" : 1,
\       "hook/quickfix_replate_tempname_to_bufnr/priority_exit" : -10,
\       "outputter/buffer/split" : ":botright 5sp",
\       "hook/turret/enable" : 1,
\       "hook/turret/wait" : 5,
\       "hook/turret/redraw" : 1,
\   },
\   "cpp" : {
\       "command": "clang++",
\       "cmdopt": "-std=c++0x -Wall",
\   },
\}
nmap <Space>q <Plug>(quickrun)
nnoremap <expr><silent> <C-c> quickrun#is_running() ? quickrun#sweep_sessions() : "\<C-c>"
""}}}
"" syntax check "{{{
NeoBundle "osyo-manga/vim-watchdogs"
NeoBundle "cohama/vim-hier"
NeoBundle "dannyob/quickfixstatus"
NeoBundle "tomtom/quickfixsigns_vim"
let s:config = {
\    "watchdogs_checker/_" : {
\        "hook/close_quickfix/enable_exit" : 1,
\    },
\}
""}}}
"" wandbox "{{{
NeoBundle "rhysd/wandbox-vim"
""}}}
"" shell "{{{
" NeoBundle "Shougo/vimshell"
" let g:vimshell_split_command = "split"
" noremap <space>v :<C-u>VimShellPop<CR>
" noremap <space>V :<C-u>VimShellInteractive<space>
""}}}
"" browser{{{
" NeoBundle 'tyru/open-browser.vim'
""}}}
"" formatter "{{{
NeoBundle "Chiel92/vim-autoformat"
let g:formatdef_clangformat = "'clang-format -lines='.a:firstline.':'.a:lastline.' --assume-filename='.bufname('%').' -style=\"{BasedOnStyle: Google, AlignTrailingComments: true, '.(&textwidth ? 'ColumnLimit: '.&textwidth.', ' : '').(&expandtab ? 'UseTab: Never, IndentWidth: '.&shiftwidth : 'UseTab: Always').'}\"'"
"}}}
"" procon g++ "{{{
:command! PS :15vsplit %:r
:command! PR :normal <C-w>v | ! ./a.out < %:r
:command! PP :!echo -n "%:r.cpp.out < %:r ... " && gpp %:r.cpp && echo "done\!" && ptest ./a.out < %:r
nmap ,p :wa \| :PP<CR>
inoremap <, <Space><<","<<<Space>
inoremap <; <Space><< endl;
"}}}
"}}}
" view "{{{
"" use ja help "{{{
set helplang=ja,en
""}}}
"" Unite "{{{
NeoBundle "Shougo/unite.vim"
NeoBundle 'kmnk/vim-unite-giti'
NeoBundle "ujihisa/unite-colorscheme"
NeoBundle "Shougo/neomru.vim"
NeoBundle "tsukkee/unite-help"
NeoBundle "Shougo/unite-outline"
NeoBundle "thinca/vim-unite-history"
NeoBundle "osyo-manga/unite-fold"
NeoBundle "yuku-t/vim-ref-ri"
let g:unite_enable_start_insert=1
let g:unite_enable_ignore_case = 1
let g:unite_enable_smart_case = 1
""file list
if executable("ag")
    nnoremap <space>f :<C-u>Unite -default-action=tabswitch file_rec/async:
    let g:unite_source_find_command = 'ag'
    let g:unite_source_rec_async_command =
                \ ['ag', '--follow', '--nocolor', '--nogroup', '--hidden', '-S', '-g', '']
    let g:unite_source_grep_command = 'ag'
    let g:unite_source_grep_default_opts = '--column --nogroup --nocolor'
    let g:unite_source_grep_recursive_opt = ''
else
    nnoremap <space>f :<C-u>Unite -default-action=tabswitch file_rec: 
endif
nnoremap <space>d :<C-u>Unite -default-action=tabswitch directory_rec:
"" grep
nnoremap <space>e  :<C-u>Unite -default-action=tabswitch grep -buffer-name=search-buffer<CR>
""recently files list
noremap <space>z :<C-u>Unite -hide-source-names -default-action=tabswitch buffer file_mru<CR>
nnoremap <space>y :<C-u>Unite directory_mru -default-action=cd<CR>
command! UniteStartup Unite -no-split file file_mru file/new directory/new
augroup startup
  autocmd!
  autocmd VimEnter * nested if (@% == '' && s:GetBufByte() == 0) | call s:Startup() | endif
  function! s:GetBufByte()
    let byte = line2byte(line('$') + 1)
    if byte == -1
      return 0
    else
      return byte - 1
    endif
  endfunction
  function! s:Startup()
    UniteStartup
  endfunction
augroup END
"" show outline
noremap <space>o :<C-u>Unite outline<CR>
"" show regster
let g:unite_source_history_yank_enable = 1
noremap <space>r :<C-u>Unite register history/yank<CR>
"" unite source
noremap <space>u :<C-u>Unite source<CR>
"" gist
noremap <space>t :<C-u>Unite gista<CR>
"" mapping
noremap <space>\ :<C-u>Unite output:map\|map!\|lmap<CR>
"" changes
nnoremap <space>; :<C-u>Unite change<CR>
"" history
nnoremap <space>: :<C-u>Unite history/command<CR>
"" lines
nnoremap <space>? :<C-u>Unite -buffer-name=search line -start-insert -no-quit<CR>
"" resume
noremap <space>0 :<C-u>UniteResume<CR>
""twice esc quit
au FileType unite nnoremap <silent> <buffer> <ESC><ESC> :q<CR>
au FileType unite inoremap <silent> <buffer> <ESC><ESC> <ESC>:q<CR>
au FileType unite inoremap <silent> <buffer> jj <ESC><CR>


"""{{{
" let s:unite_source = {
"       \   'name': 'coqdef',
"       \ }
" function! s:unite_source.gather_candidates(args, context)
"     let path = expand('#:p')
"     " /^\(Theorem\|Lemma\) \zs\_.\{-}\zeProof
"     let lines = getbufline('#', 1, '$')
"     let format = '%' . strlen(len(lines)) . 'd: %s'
"         return map(lines, '{
"           \   "word": printf(format, v:key + 1, v:val),
"           \   "source": "lines",
"           \   "kind": "jump_list",
"           \   "action__path": path,
"           \   "action__line": v:key + 1,
"           \ }')
" endfunction
" call unite#define_source(s:unite_source)
" unlet s:unite_source
"""}}}
""}}}
"" reference K:search" {{{
NeoBundle "thinca/vim-ref"
""}}}
"" tag "{{{
NeoBundle 'tsukkee/unite-tag'
nnoremap <silent> <C-]> :<C-u>Unite -immediately -no-start-insert tag:<C-r>=expand('<cword>')<CR><CR>
nnoremap <buffer> <C-t> :<C-u>Unite jump<CR>
if executable("ctags")
NeoBundle 'alpaca-tc/alpaca_tags'
let g:alpaca_tags#config = {
\   '_' : '-R --sort=yes --languages=+Ruby --languages=-js,JavaScript',
\   'js' : '--languages=+js',
\   '-js' : '--languages=-js,JavaScript',
\   'vim' : '--languages=+Vim,vim',
\   'php' : '--languages=+php',
\   '-vim' : '--languages=-Vim,vim',
\   '-style': '--languages=-css,scss,js,JavaScript,html',
\   'scss' : '--languages=+scss --languages=-css',
\   'css' : '--languages=+css',
\   'java' : '--languages=+java $JAVA_HOME/src',
\   'ruby': '--languages=+Ruby',
\   'coffee': '--languages=+coffee',
\   '-coffee': '--languages=-coffee',
\   'bundle': '--languages=+Ruby',
\   }
augroup AlpacaTags
    autocmd!
    if exists(':Tags')
        autocmd BufWritePost Gemfile TagsBundle
        autocmd BufEnter * TagsSet
        autocmd BufWritePost * TagsUpdate
    endif
augroup END
endif
""}}}
"}}}
" manager "{{{
"" backup directory "{{{
set backup
set directory=~/.vim/tmp
set backupdir=~/.vim/tmp
set viminfo+=n~/.vim/tmp/viminfo.txt
set undodir=~/.vim/tmp
augroup vimrc-undofile
  autocmd!
  autocmd BufReadPre ~/* setlocal undofile
augroup END
""}}}
"" fugitive "{{{
NeoBundle "tpope/vim-fugitive"
noremap <space>g :Gstatus<CR>
""}}}
"" diff tools "{{{
NeoBundle 'lambdalisue/vim-unified-diff'
set diffexpr=unified_diff#diffexpr()
set diffopt=filler,vertical

NeoBundle 'AndrewRadev/linediff.vim' , { 'commands': ['Linediff'] }

"}}}
"" gist "{{{
NeoBundle "lambdalisue/vim-gista"
let g:gista#github_user = "wass80"
" let g:gista#update_on_write = 1
" let g:gista#gist_api_url = 'https://gist.github.com'
let g:gista#directory = expand('~/.gista/')
let g:gista#token_directory = g:gista#directory . 'tokens/' 
"" }}}
"" vimcoder"{{{
NeoBundle "vim-scripts/VimCoder.jar"
"}}}
"" vimcoder"{{{
if !has('win32')
  NeoBundle "editorconfig/editorconfig-vim"
end
"}}}
"}}}
" completion "{{{
"" command completion "{{{
set wildmenu
set wildmode=longest:full,full
"}}}
"" neocomplcache "{{{
NeoBundle "Shougo/neocomplete"
NeoBundle "Shougo/neosnippet.vim"
NeoBundle "wass80/neosnippet-snippets"

" number of pop up items
set pumheight=15

let g:neosnippet#snippets_directory='~/.vim/bundle/neosnippet-snippets/neosnippets/'

let g:neocomplete#enable_at_startup = 1
let g:neocomplete#enable_smart_case = 1
let g:neocomplete#sources#syntax#min_keyword_length = 3
let g:neocomplete#lock_buffer_name_pattern = '\*ku\*'

" vim keyword.
if !exists('g:neocomplete#keyword_patterns')
    let g:neocomplete#keyword_patterns = {}
endif
let g:neocomplete#keyword_patterns['default'] = '\h\w*'

inoremap <expr><C-l>     neocomplete#complete_common_string()

" <CR>: close popup and save indent.
inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
function! s:my_cr_function()
  return neocomplete#close_popup() . "\<CR>"
  " For no inserting <CR> key.
  "return pumvisible() ? neocomplete#close_popup() : "\<CR>"
endfunction

" SuperTab like snippets behavior.
imap <expr><TAB> pumvisible() ? "\<C-n>"
\: neosnippet#expandable_or_jumpable() ?
\ "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"
smap <expr><TAB> neosnippet#jumpable() ?
\ "\<Plug>(neosnippet_jump)"
\: "\<TAB>"

" <C-h>, <BS>: close popup and delete backword char.
inoremap <expr><C-h> neocomplete#smart_close_popup()."\<C-h>"
inoremap <expr><BS> neocomplete#smart_close_popup()."\<C-h>"
inoremap <expr><C-y>  neocomplete#cancel_popup()."\<C-y>"
inoremap <expr><C-e>  neocomplete#cancel_popup()."\<C-e>"

" Plugin key-mappings.
imap <C-k>     <Plug>(neosnippet_expand_or_jump)
smap <C-k>     <Plug>(neosnippet_expand_or_jump)
xmap <C-k>     <Plug>(neosnippet_expand_target)

" For snippet_complete marker.
if has('conceal')
  set conceallevel=2 concealcursor=i
endif

" Enable omni completion.
augroup omni
    autocmd!
    autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
    autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
    autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
    autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
    autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
augroup END

" Enable heavy omni completion.
if !exists('g:neocomplete#sources#omni#input_patterns')
  let g:neocomplete#sources#omni#input_patterns = {}
endif
let g:neocomplete#sources#omni#input_patterns.php = '[^. \t]->\h\w*\|\h\w*::'
let g:neocomplete#sources#omni#input_patterns.c = '[^.[:digit:] *\t]\%(\.\|->\)'
let g:neocomplete#sources#omni#input_patterns.cpp = '[^.[:digit:] *\t]\%(\.\|->\)\|\h\w*::'
autocmd FileType ruby setlocal omnifunc=rubycomplete#Complete
if !exists('g:neocomplete#force_omni_input_patterns')
  let g:neocomplete#force_omni_input_patterns = {}
endif
let g:neocomplete#force_omni_input_patterns.ruby = '[^. *\t]\.\w*\|\h\w*::'
let g:neocomplete#sources#omni#input_patterns.typescript = '\h\w*\|[^. \t]\.\w*'
""}}}
"" cpp "{{{
" if executable("clang")
"   NeoBundleLazy 'osyo-manga/vim-marching', { 'autoload' : {
"   \ 'filetypes': ['cpp','c'],
"   \ }}
"  
"   let g:marching_enable_neocomplete = 1
"   if !exists('g:neocomplete#force_omni_input_patterns')
"     let g:neocomplete#force_omni_input_patterns = {}
"   endif
"   let g:neocomplete#force_omni_input_patterns.cpp =
"     \ '[^.[:digit:] *\t]\%(\.\|->\)\w*\|\h\w*::\w*'
" endif
""}}}
"" rsense "{{{
NeoBundleLazy 'NigoroJr/rsense', { 'autoload' : {
\ 'filetypes': 'ruby',
\ }}
" NeoBundleLazy 'supermomonga/neocomplete-rsense.vim', { 'autoload' : {
" \ 'filetypes': 'ruby',
" \ }}
""}}}
"" js tern "{{{
if executable("tern")
  NeoBundleLazy 'marijnh/tern_for_vim', { 'autoload' : {
  \ 'filetypes': 'javascript',
  \ }}
endif
""}}}
"" completion "end" "{{{
NeoBundle 'taichouchou2/vim-endwise.git'
let g:endwise_no_mappings=1
""}}}
"}}}
" cursor & search "{{{
"" search setting "{{{
" change search in UpperCase
set ignorecase
set smartcase
set report=0
"}}}
"" addtional pair % "{{{
if !exists('loaded_matchit')
  runtime macros/matchit.vim
endif
""}}}
"" easy cursor moving "{{{
NeoBundle 'Lokaltog/vim-easymotion'
let g:EasyMotion_keys = 'hjklasdfgyuiopqwertnmzxcvbHJKLASDFGYUIOPQWERTNMZXCVB'
let g:EasyMotion_grouping = 1
let g:EasyMotion_do_mapping = 0
let g:EasyMotion_smartcase = 1
let g:EasyMotion_skipfoldedline = 0
let g:EasyMotion_startofline = 0
let g:EasyMotion_enter_jump_first = 1
if(has('migemo'))
    let g:EasyMotion_use_migemo = 1
endif
hi EasyMotionTarget ctermbg=none ctermfg=red
hi EasyMotionShade  ctermbg=none ctermfg=blue
map s <Plug>(easymotion-s2)
nmap <Space>/ <Plug>(easymotion-sn)
xmap <Space>/ <Plug>(easymotion-sn)
omap <Space>/ <Plug>(easymotion-tn)
let g:EasyMotion_startofline = 0
map <Space>w <Plug>(easymotion-bd-wl)
map <Space>W <Plug>(easymotion-bd-el)
" continue f
NeoBundle 'rhysd/clever-f.vim'
let g:clever_f_use_migemo=1
" let g:clever_f_chars_match_any_signs=1 " has bug on 't/T'
let g:clever_f_fix_key_direction=1
""}}}
"" multple cursors "{{{
NeoBundle "terryma/vim-multiple-cursors"
"}}}
"" switch "{{{
NeoBundle "AndrewRadev/switch.vim"
let g:switch_mapping = ""
nnoremap <Space>n  :<C-u>Switch<CR>
let g:switch_custom_definitions =
    \ [
    \   ['pick', 'squash', 'fixup', 'edit'],
    \   ['->', '<-']
    \ ]
"}}}
"" ime "{{{
if !has('gui_running')
  set t_SI+=[<r
  set t_EI+=[<s[<0t
  set t_te+=[<0t[<s
  set ttimeoutlen=100
end
""}}}
"}}}
" operation "{{{
"" basic "{{{
" warp japanese
set formatoptions+=mM
" deleat backspace word
set backspace=indent,eol,start
" visiable around cursor
set scrolloff=5
" c type indent
set cindent
set cino=(0,W2,m1
" tab into space
set smarttab
set tabstop=2
set softtabstop=2
set expandtab
set shiftwidth=2
set shiftround
" no using octed
set nrformats-=octal
" no comment at new line
augroup nocr
    autocmd!
    autocmd CursorMoved,CursorMoved * setlocal formatoptions-=ro
augroup END
" new line by enter
noremap <CR> a<CR><ESC>
" without shift
noremap <Space>h ^
noremap <Space>l $
noremap <Space>b %
" one char insert
nnoremap <space>i i_<ESC>r
" go normal mode with jj
inoremap jj <Esc>
" ignore Q
nnoremap Q gq
" Y <-> D
nnoremap Y y$
" switch window
nnoremap ,h <C-w>h
nnoremap ,l <C-w>j
nnoremap ,k <C-w>k
nnoremap ,l <C-w>l
""}}}
"" textobj "{{{
NeoBundle 'kana/vim-operator-user.git'
NeoBundle 'emonkak/vim-operator-comment'
map co <Plug>(operator-comment)
map cO <Plug>(operator-uncomment)
NeoBundle 'tommcdo/vim-exchange'
" cx, cxx, X(in visual), cxc(reset)
map cd cx
map cdd cxx
map cdc cxc
NeoBundle 'kana/vim-operator-replace.git'
map R  <Plug>(operator-replace)
NeoBundle 'rhysd/vim-operator-surround'
noremap gh gd
map gs <Plug>(operator-surround-append)
map gd <Plug>(operator-surround-delete)
map gc <Plug>(operator-surround-replace)
NeoBundle 'thinca/vim-visualstar'
NeoBundle 'tyru/operator-star.vim'
map *  <Plug>(operator-*)
map g*  <Plug>(operator-g*)
map #  <Plug>(operator-#)
map g#  <Plug>(operator-g#)
NeoBundle 'osyo-manga/vim-operator-jump_side'
map <Space>j <Plug>(operator-jump-tail-out)
map <Space>k <Plug>(operator-jump-head-out)
map ; <Plug>(operator-jump-toggle)

NeoBundle 'kana/vim-textobj-user'
NeoBundle 'kana/vim-textobj-line'
" al / il
NeoBundle 'kana/vim-textobj-indent'
" ai / ii
NeoBundle 'kana/vim-textobj-function'
let g:textobj_function_no_default_key_mappings=1
omap iF <Plug>(textobj-function-i)
omap aF <Plug>(textobj-function-a)
vmap iF <Plug>(textobj-function-i)
vmap aF <Plug>(textobj-function-a)
NeoBundle 'thinca/vim-textobj-between'
" af* / if*
NeoBundle 'kana/vim-textobj-entire'
let g:textobj_entire_no_default_key_mappings=1
omap ao <Plug>(textobj-entire-a)
omap ao <Plug>(textobj-entire-a)
vmap io <Plug>(textobj-entire-i)
vmap io <Plug>(textobj-entire-i)
NeoBundle 'osyo-manga/vim-textobj-multiblock'
omap ab <Plug>(textobj-multiblock-a)
omap ib <Plug>(textobj-multiblock-i)
vmap ab <Plug>(textobj-multiblock-a)
vmap ib <Plug>(textobj-multiblock-i)
NeoBundle 'kana/vim-textobj-fold'
" az / iz
NeoBundle 'rhysd/vim-textobj-ruby'
" ar / ir
NeoBundle 'rbonvall/vim-textobj-latex'
" a\, a$, aq, aQ, ae
NeoBundle 'sgur/vim-textobj-parameter'
" a, / i,
NeoBundle 'glts/vim-textobj-comment'
" ac / ic
NeoBundle 'kana/vim-textobj-syntax'
" ay / iy
NeoBundle 'rhysd/vim-textobj-word-column'
" av, aV
NeoBundle 'gilligan/textobj-lastpaste'
" ip

NeoBundle 'terryma/vim-expand-region'
let g:expand_region_text_objects = {
      \ 'iw'  :0,
      \ 'iW'  :0,
      \ 'i"'  :0,
      \ 'i''' :0,
      \ 'i]'  :1,
      \ 'ib'  :1,
      \ 'iB'  :1,
      \ 'i,'  :0,
      \ 'il'  :0,
      \ 'al'  :0,
      \ 'ip'  :0,
      \ 'io'  :0,
      \ }
vmap v <Plug>(expand_region_expand)
vmap V <Plug>(expand_region_shrink)

""}}}
"" repeat plugin command "{{{
NeoBundle "tpope/vim-repeat"
""}}}
"" undo tree "{{{
NeoBundle "sjl/gundo.vim"
""}}}
"" aline text "{{{
NeoBundle "junegunn/vim-easy-align"
" Start interactive EasyAlign in visual mode (e.g. vip<Enter>)
vmap <Enter> <Plug>(EasyAlign)
" Start interactive EasyAlign for a motion/text object (e.g. <Leader>aip)
nmap ga <Plug>(EasyAlign)
""}}}
"" move text in virtual mode "{{{
NeoBundle "t9md/vim-textmanip"
xmap <C-j> <Plug>(textmanip-move-down)
xmap <C-k> <Plug>(textmanip-move-up)
xmap <C-h> <Plug>(textmanip-move-left)
xmap <C-l> <Plug>(textmanip-move-right)
""}}}
"" interactive substitute "{{{
NeoBundle "osyo-manga/vim-over"
nnoremap <silent> <Space>s :OverCommandLine <CR>
vnoremap <silent> <Space>s :OverCommandLine '<,'>s/<CR>
""}}}
"" case-sensitive substitute "{{{
NeoBundle "tpope/vim-abolish"
""}}}
"" disable F1 "{{{
map <F1> <nop>
cmap <F1> <nop>
imap <F1> <nop>
vmap <F1> <nop>
"}}} 
"" continue visual "{{{
vnoremap > >gv
vnoremap < <gv
vnoremap <C-a> <C-a>gv
vnoremap <C-X> <C-X>gv
"}}} 
"" multi lines <-> single line "{{{
NeoBundle "AndrewRadev/splitjoin.vim"
" gS gJ
"}}}
"" macro edit "{{{
nnoremap <space>@  :<c-u><c-r><c-r>='let @'. v:register .' = '. string(getreg(v:register))<cr><c-f><left>
"}}}
"}}} 
" window & tab "{{{
set tabpagemax=100
"" smooth scroll "{{{
NeoBundle "yonchu/accelerated-smooth-scroll"
"}}}
"" edit many buffer "{{{
set hidden
""}}}
"" shortcut "{{{
nnoremap ,o :tabe<space>
""}}}
"" sudo write "{{
cabbr w!! w !sudo tee > /dev/null %
""}}
"" window position "{{{
nnoremap <M-h> <C-w>h
nnoremap <M-j> <C-w>j
nnoremap <M-k> <C-w>k
nnoremap <M-l> <C-w>l
""}}}
"" shortcut "{{{
nnoremap ,1 1gt
nnoremap ,2 2gt
nnoremap ,3 3gt
nnoremap ,4 4gt
nnoremap ,5 5gt
nnoremap ,6 6gt
nnoremap ,7 7gt
nnoremap ,8 8gt
nnoremap ,9 9gt
nnoremap ,0 :<C-u>Unite -default-action=tabswitch tab buffer<CR>
nnoremap ,t :<C-u>tab ba<CR>
nnoremap ,, <C-w><C-w>
nnoremap ,w :w<CR>
nnoremap ,q :q<CR>
nnoremap ,e :tabe
"}}}
" language "{{{
"" cpp "{{{
NeoBundleLazy 'vim-jp/cpp-vim', {
\ 'autoload' : {'filetypes' : 'cpp'}}
""}}}
"" ruby "{{{
" this plugin has a bag on editing a new ruby file.
" NeoBundleLazy 'todesking/ruby_hl_lvar.vim', {
" \ 'autoload' : {'filetypes' : 'ruby'}}
""}}}
"" slim "{{{
NeoBundleLazy 'slim-template/vim-slim',{
\ 'autoload' : {'filetypes' : 'slim' }}
augroup Slim
    autocmd!
    autocmd BufWinEnter,BufNewFile *.slim set filetype=slim
augroup END
""}}}
"" haskell "{{{
NeoBundleLazy 'kana/vim-filetype-haskell', { 'filetypes': ['haskell'] }
NeoBundleLazy 'eagletmt/ghcmod-vim', { 'filetypes': ['haskell'] }
NeoBundleLazy 'ujihisa/neco-ghc', { 'commands': ['GhcModType'] }
noremap <space>m :GhcModType<CR>
NeoBundleLazy 'ujihisa/ref-hoogle', { 'filetypes': ['haskell'] }
NeoBundleLazy 'ujihisa/unite-haskellimport', { 'filetypes': ['haskell'] }
""}}}
"" markdown "{{{
NeoBundle 'rcmdnk/vim-markdown',{
\ 'autoload' : {'filetypes' : 'markdown' }}
NeoBundleLazy 'joker1007/vim-markdown-quote-syntax',{
\ 'autoload' : {'filetypes' : 'markdown' }}
""}}}
"" html "{{{
NeoBundleLazy 'othree/html5.vim' ,{
\ 'autoload' : {'filetypes' : 'html'}}
NeoBundleLazy 'mattn/emmet-vim' ,{
\ 'autoload' : {'filetypes' : ['html','css']}}
""}}}
"" css "{{{
NeoBundleLazy 'hail2u/vim-css3-syntax' ,{
\ 'autoload' : {'filetypes' : 'css'}}
""}}}
"" coffeescript "{{{
NeoBundle 'kchmck/vim-coffee-script' ,{
\ 'autoload' : {'filetypes' : 'coffeescript' }}
""}}}
"" rust "{{{
NeoBundle 'rust-lang/rust.vim' ,{
\ 'autoload' : {'filetypes' : 'rust' }}
" require rustfmt
let g:rustfmt_command = $HOME . '/.cargo/bin/rustfmt'
augroup Rust
    autocmd!
    autocmd BufWinEnter,BufNewFile *.rs set filetype=rust
augroup END
"}}}
"" js "{{{
NeoBundle 'isRuslan/vim-es6' ,{
\ 'autoload' : {'filetypes' : 'javascript' }}
NeoBundle 'jiangmiao/simple-javascript-indenter' ,{
\ 'autoload' : {'filetypes' : 'javascript' }}
NeoBundle 'mattn/jscomplete-vim' ,{
\ 'autoload' : {'filetypes' : 'javascript' }}
NeoBundleLazy 'clausreinke/typescript-tools', {
\ 'build' : 'npm install -g',
\ 'autoload' : {'filetypes' : 'typescript' }
\}
NeoBundleLazy 'clausreinke/typescript-tools', {
\ 'autoload' : {'filetypes' : 'typescript' }
\}
augroup TypeScript
    autocmd!
    autocmd BufWinEnter,BufNewFile *.ts set filetype=typescript
augroup END
"}}}
"" hbs "{{{
NeoBundle 'mustache/vim-mustache-handlebars'
au BufNewFile,BufRead *.hbs setf html.handlebars
"}}}
"" json "{{{
NeoBundle 'vim-scripts/JSON.vim' ,{
\ 'autoload' : {'filetypes' : 'json' }}

au BufRead,BufNewFile *.json set filetype=json
""}}}
"" coq "{{{
NeoBundle 'jvoorhis/coq.vim'
NeoBundle 'def-lkb/vimbufsync'
NeoBundleLazy 'the-lambda-church/coquille', {
      \ 'autoload' : { 'filetypes' : 'coq' }}
augroup Coq
    autocmd!
    autocmd BufWinEnter,BufNewFile *.v set filetype=coq
    autocmd FileType coq imap <buffer> . .<C-o>:CoqUndo<CR><C-o>:CoqToCursor<CR>
    autocmd FileType coq imap <buffer> @i intros<space>
    autocmd FileType coq imap <buffer> @a apply<space>
    autocmd FileType coq imap <buffer> @s simpl
    autocmd FileType coq imap <buffer> @f reflexivity.
    autocmd FileType coq imap <buffer> @r rewrite<space>
    autocmd FileType coq imap <buffer> @b rewrite <-<space>
    autocmd FileType coq imap <buffer> @v inversion<space>
    autocmd FileType coq imap <buffer> @d destruct<space>
    autocmd FileType coq imap <buffer> @u induction<space>
    autocmd FileType coq imap <buffer> @g generalize dependent<space>
augroup END
au FileType coq call coquille#FNMapping()
""}}}
"}}}
"}}}
" after "{{{
call neobundle#end()
"" vital
let s:V = vital#of('vital')
"" colorscheme
colorscheme Tomorrow-Night-Bright
"" shabadou
call quickrun#module#register(shabadou#make_quickrun_hook_anim(
\   "turret",
\   ['{:}-', '{:}--', '{:}---', '{:}----', '{:}-----', '{:}<the cake is a lie.'],
\   12,
\), 1)
"" watchdogs
call extend(g:quickrun_config, s:config)
unlet s:config
call watchdogs#setup(g:quickrun_config)
let g:watchdogs_check_BufWritePost_enable = 1
"" unite
""short cut directory
call unite#custom#substitute('files', '\$\w\+', '\=eval(submatch(0))', 200)
call unite#custom#substitute('files', '^@@', '\=fnamemodify(expand("#"), ":p:h")."/"', 2)
call unite#custom#substitute('files', '^@', '\=getcwd()."/*"', 1)
call unite#custom#substitute('files', '^;r', '\=$VIMRUNTIME."/"')
call unite#custom#substitute('files', '^\~', escape($HOME, '\'), -2)
call unite#custom#substitute('files', '\\\@<! ', '\\ ', -20)
call unite#custom#substitute('files', '\\ \@!', '/', -30)
""open new tab
call unite#custom_default_action('file', 'tabopen')
"" back and back "{{{
call submode#enter_with('undo/redo', 'n', '', 'g-', 'g-')
call submode#enter_with('undo/redo', 'n', '', 'g+', 'g+')
call submode#map('undo/redo', 'n', '', '-', 'g-')
call submode#map('undo/redo', 'n', '', '+', 'g+')
""}}}
"" packing x "{{{
function! s:my_x()
    undojoin
    normal! x
endfunction
nnoremap <silent> <Plug>(my-x) :<C-u>call <SID>my_x()<CR>
call submode#enter_with('my_x', 'n', '', 'x', 'x')
call submode#map('my_x', 'n', 'r', 'x', '<Plug>(my-x)')
"}}}
"" tab move "{{{
call submode#enter_with('changetab', 'n', '', 'gt', 'gt')
call submode#enter_with('changetab', 'n', '', 'gT', 'gT')
call submode#map('changetab', 'n', '', 't', 'gt')
call submode#map('changetab', 'n', '', 'T', 'gT')
let s:Math = s:V.import('Math')
function! s:SIDP()
	  return '<SNR>' . matchstr(expand('<sfile>'), '<SNR>\zs\d\+\ze_SIDP$') . '_'
  endfunction
  function! s:movetab(nr)
	    execute 'tabmove' s:Math.modulo(tabpagenr() + a:nr - 1, tabpagenr('$'))
    endfunction
    let s:movetab = ':<C-u>call ' . s:SIDP() . 'movetab(%d)<CR>'
    call submode#enter_with('movetab', 'n', '', '<Space>ct', printf(s:movetab, 1))
    call submode#enter_with('movetab', 'n', '', '<Space>cT', printf(s:movetab, -1))
    call submode#map('movetab', 'n', '', '<Space>t', printf(s:movetab, 1))
    call submode#map('movetab', 'n', '', '<Space>T', printf(s:movetab, -1))
    unlet s:movetab
""}}}
"" window size "{{{
call submode#enter_with('winsize', 'n', '', '<C-w>>', '<C-w>>')
call submode#enter_with('winsize', 'n', '', '<C-w><', '<C-w><')
call submode#enter_with('winsize', 'n', '', '<C-w>+', '<C-w>-')
call submode#enter_with('winsize', 'n', '', '<C-w>-', '<C-w>+')
call submode#map('winsize', 'n', '', '>', '<C-w>>')
call submode#map('winsize', 'n', '', '<', '<C-w><')
call submode#map('winsize', 'n', '', '+', '<C-w>-')
call submode#map('winsize', 'n', '', '-', '<C-w>+')
""}}}
"}}}
NeoBundleCheck
filetype plugin indent on
