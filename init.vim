" Dein settings {{{
" reset augroup
augroup MyAutoCmd
  autocmd!
augroup END
" dein自体の自動インストール
let s:cache_home = empty($XDG_CACHE_HOME) ? expand('~/.cache') : $XDG_CACHE_HOME
let s:dein_dir = s:cache_home . '/dein'
let s:dein_repo_dir = s:dein_dir . '/repos/github.com/Shougo/dein.vim'
if !isdirectory(s:dein_repo_dir)
  call system('git clone https://github.com/Shougo/dein.vim ' . shellescape(s:dein_repo_dir))
endif
let &runtimepath = s:dein_repo_dir .",". &runtimepath
" プラグイン読み込み＆キャッシュ作成
let s:toml_file = fnamemodify(expand('<sfile>'), ':h').'/dein.toml'
if dein#load_state(s:dein_dir)
  call dein#begin(s:dein_dir, [$MYVIMRC, s:toml_file])
  call dein#load_toml(s:toml_file)

  " merlin
  if executable('ocamlmerlin')
    let g:opamshare = substitute(system('opam config var share'),'\n$','','''')
    call dein#add(g:opamshare . "/merlin/vim", {'lazy': 1, 'on_ft': 'ocaml'})
  end

  call dein#end()
  call dein#save_state()
endif

filetype plugin indent on
syntax enable

" 不足プラグインの自動インストール
if has('vim_starting') && dein#check_install()
  call dein#install()
endif

augroup MyPost
  autocmd!
  autocmd VimEnter * call dein#call_hook('post_source')
augroup END
"}}}
" Appearance {{{
set number
set display=lastline
set ambiwidth=double

" Show hide chars
set list
set listchars=tab:^\ ,trail:~,eol:_
function! ZenkakuSpace()
  highlight ZenkakuSpace cterm=underline ctermfg=darkgrey gui=underline guifg=darkgrey
endfunction
augroup ZenkakuSpace
autocmd!
  autocmd ColorScheme       * call ZenkakuSpace()
  autocmd VimEnter,WinEnter * match ZenkakuSpace /　/
  autocmd VimEnter,WinEnter * match ZenkakuSpace '\%u3000'
augroup END
call ZenkakuSpace()

" Turn off highlight on enter twice
nnoremap <silent><Esc><Esc> :<C-u>nohlsearch<CR>
nnoremap <silent><C-l><C-l> :<C-u>nohlsearch<CR>

" Folding
noremap zs za

" Highlight parenttheses
let g:lisp_instring = 1
let g:lisp_rainbow = 1

" Colorscheme
au ColorScheme * highlight SpellBad term=underline cterm=underline ctermfg=9 ctermbg=NONE
au ColorScheme * highlight SpellLocal term=underline cterm=underline ctermbg=234 ctermbg=NONE
au ColorScheme * highlight LineNr ctermfg=247 guifg=#909090
au ColorScheme * highlight Comment ctermfg=228 guifg=#969896 cterm=BOLD gui=BOLD
au ColorScheme * highlight SpecialKey ctermfg=45 guifg=#606060
au ColorScheme * highlight NonText ctermfg=247 guifg=#606060
au FileType coq highlight SentToCoq ctermbg=17 guibg=#000080

" Status line
set laststatus=2
set cmdheight=2
set showcmd
" Light line{{{
let g:lightline = {
\   'colorscheme': 'wombat',
\   'mode_map': {'c': 'NORMAL'},
\   'active': {
\     'left': [
\       ['mode', 'paste'],
\       ['fugitive', 'gitgutter', 'filename',],
\       ['ale'],
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
\     'ale': 'LinterStatus',
\   },
\   'separator': {'left': '', 'right': ''},
\   'subseparator': {'left': '|', 'right': '|'}
\}

function! LinterStatus() abort
    let l:counts = ale#statusline#Count(bufnr(''))

    let l:all_errors = l:counts.error + l:counts.style_error
    let l:all_non_errors = l:counts.total - l:all_errors

    return l:counts.total == 0 ? '' : printf(
    \   '%dW %dE',
    \   all_non_errors,
    \   all_errors
    \)
endfunction

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
"}}}
"}}}
" View {{{
set helplang=ja,en
" TODO unite
"}}}
" Manage {{{
set hidden
set backup
set directory=~/.vim/tmp
set backupdir=~/.vim/tmp
set viminfo+=n~/.vim/tmp/nviminfo.txt
set undodir=~/.vim/tmp
augroup vimrc-undofile
  autocmd!
  autocmd BufReadPre ~/* setlocal undofile
augroup END
"}}}
" Completion {{{
set wildmode=longest:full,full
set pumheight=15
set isfname-==
" TODO neocomplete
"" OCaml
if executable('ocamlmerlin')
  if !exists('g:neocomplete#force_omni_input_patterns')
      let g:neocomplete#force_omni_input_patterns = {}
  endif
  let g:neocomplete#force_omni_input_patterns.ocaml = '[^. *\t]\.\w*\|\h\w*|#'
endif
"}}}
" Cursor and Search {{{
set ignorecase
set smartcase
set report=0
" addtional pair %
if !exists('loaded_matchit')
  runtime macros/matchit.vim
endif
"}}}
" Shortcut {{{
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
" move anywhere
set virtualedit+=block
" no comment at new line
augroup nocr
    autocmd!
    autocmd CursorMoved,CursorMoved * setlocal formatoptions-=ro
augroup END
" new line by enter
nnoremap <CR> i<CR><ESC>
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
" prcn
command! PS :15vsplit %:r
command! PR :normal <C-w>v | ! ./a.out < %:r
command! PP :!echo -n "%:r.cpp.out < %:r ... " && gpp %:r.cpp && echo "done\!" && ptest ./a.out < %:r
nmap ,p :wa \| :PP<CR>
inoremap <, <Space><<","<<<Space>
inoremap <; <Space><< endl;
" disable F1
map <F1> <nop>
cmap <F1> <nop>
imap <F1> <nop>
vmap <F1> <nop>
" continue visual
vnoremap > >gv
vnoremap < <gv
vnoremap <C-a> <C-a>gv
vnoremap <C-X> <C-X>gv
" window position
nnoremap <M-h> <C-w>h
nnoremap <M-j> <C-w>j
nnoremap <M-k> <C-w>k
nnoremap <M-l> <C-w>l
" sudo write
cabbr w!! w !sudo tee > /dev/null %
" tab
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
nnoremap ,e :tabe<space>
"}}}
" Filetype {{{
augroup Setfiletype
  autocmd!
  autocmd BufWinEnter,BufNewFile *.slim set filetype=slim
  autocmd BufWinEnter,BufNewFile *.rs set filetype=rust
  autocmd BufWinEnter,BufNewFile *.ts set filetype=typescript
  autocmd BufNewFile,BufRead *.hbs setf html.handlebars
  au BufRead,BufNewFile *.json set filetype=json
augroup END

" Coq
" augroup Coq
"           distractor.dig("data", "correct")
"   autocmd!
"   autocmd BufWinEnter,BufNewFile *.v set filetype=coq
"   autocmd FileType coq imap <buffer> . .<C-o>:CoqUndo<CR><C-o>:CoqToCursor<CR>
"   autocmd FileType coq imap <buffer> @i intros<space>
"   autocmd FileType coq imap <buffer> @a apply<space>
"   autocmd FileType coq imap <buffer> @s simpl
"   autocmd FileType coq imap <buffer> @f reflexivity.
"   autocmd FileType coq imap <buffer> @r rewrite<space>
"   autocmd FileType coq imap <buffer> @b rewrite <-<space>
"   autocmd FileType coq imap <buffer> @v inversion<space>
"   autocmd FileType coq imap <buffer> @d destruct<space>
"   autocmd FileType coq imap <buffer> @u induction<space>
"   autocmd FileType coq imap <buffer> @g generalize dependent<space>
"   au FileType coq call coquille#FNMapping()
" augroup END
"}}}
" Submode {{{
call submode#enter_with('undo/redo', 'n', '', 'g-', 'g-')
call submode#enter_with('undo/redo', 'n', '', 'g+', 'g+')
call submode#map('undo/redo', 'n', '', '-', 'g-')
call submode#map('undo/redo', 'n', '', '+', 'g+')
" packing x
function! s:my_x()
    undojoin
    normal! x
endfunction
nnoremap <silent> <Plug>(my-x) :<C-u>call <SID>my_x()<CR>
call submode#enter_with('my_x', 'n', '', 'x', 'x')
call submode#map('my_x', 'n', 'r', 'x', '<Plug>(my-x)')
" tab move
call submode#enter_with('changetab', 'n', '', 'gt', 'gt')
call submode#enter_with('changetab', 'n', '', 'gT', 'gT')
call submode#map('changetab', 'n', '', 't', 'gt')
call submode#map('changetab', 'n', '', 'T', 'gT')
" window size
call submode#enter_with('winsize', 'n', '', '<C-w>>', '<C-w>>')
call submode#enter_with('winsize', 'n', '', '<C-w><', '<C-w><')
call submode#enter_with('winsize', 'n', '', '<C-w>+', '<C-w>-')
call submode#enter_with('winsize', 'n', '', '<C-w>-', '<C-w>+')
call submode#map('winsize', 'n', '', '>', '<C-w>>')
call submode#map('winsize', 'n', '', '<', '<C-w><')
call submode#map('winsize', 'n', '', '+', '<C-w>-')
call submode#map('winsize', 'n', '', '-', '<C-w>+')
"}}}
if filereadable(expand("~/dotfiles/nvim.local"))
  source ~/dotfiles/nvim.local
endif
