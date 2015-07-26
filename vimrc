" Note: Skip initialization for vim-tiny or vim-small.
if 0 | endif

if &compatible
  set nocompatible
endif

function! IsMac()
  return (has('mac') || has('macunix') || has('gui_macvim') ||
        \   (!executable('xdg-open') && system('uname') =~? '^darwin'))
endfunction

function! s:source_rc(path)
  execute 'source' fnameescape(expand('~/.vim/rc/' . a:path))
endfunction

augroup uAutoCmd
  autocmd!
augroup END

command! -nargs=1 Source
      \ execute 'source' expand('~/.vim/' . <args> . '.vim')

let $CACHE = expand('~/.cache')
set viminfo+=n~/.vim/tmp/info.txt
set path+=/usr/include/c++/HEAD/

if filereadable(expand('~/.vimrc_local_before'))
  source $HOME/.vimrc_local_before
endif

" #Release keymaps"{{{
let mapleader = ";"
nnoremap Q <Nop>
nnoremap ; <Nop>
xnoremap ; <Nop>
nnoremap , <Nop>
xnoremap , <Nop>
nnoremap s <Nop>
xnoremap s <Nop>
nnoremap gs <Nop>
xnoremap gs <Nop>
nnoremap gr <Nop>
xnoremap gr <Nop>
nnoremap gR <Nop>
xnoremap gR <Nop>
nnoremap gh <Nop>
xnoremap gh <Nop>
nnoremap gm <Nop>
xnoremap gm <Nop>
nnoremap g8 <Nop>
xnoremap g8 <Nop>
nnoremap g<C-G> <Nop>
xnoremap g<C-G> <Nop>
nnoremap g<C-A> <Nop>
xnoremap g<C-A> <Nop>
"}}}

Source 'neobundle'
filetype plugin indent on
syntax enable

if has('vim_starting')
  NeoBundleCheck
endif

language message C
scriptencoding=utf-8
set encoding=utf-8
set fileformats=unix,dos,mac
" set fileencodings=ucs-bom,utf-8,iso-2022-jp-3,iso-2022-jp,eucjp-ms,euc-jisx0213,euc-jp,sjis,cp932

set report=0  " コマンドで0行以上変更されたらmessage
set number
set hidden
set showcmd
set cursorline
set showmatch
set laststatus=2
set cmdheight=2 cmdwinheight=4
set mouse=a
set nobackup
set modeline

set nowrap
set sidescroll=1
set sidescrolloff=12

" Keymapping timeout.
set timeout timeoutlen=3000 ttimeoutlen=100
" CursorHold time.
set updatetime=1000

set autoindent smartindent
set ignorecase smartcase

set backspace=start,eol,indent
set whichwrap=b,s,[,],<,>
set matchpairs+=<:>
set iskeyword+=$,@-@  "設定された文字が続く限り単語として扱われる @は英数字を表す

" Enable virtualedit in visual block mode.
set virtualedit=block

" #menu
set wildmenu
set wildmode=longest:full,full
set nrformats-=octal  " 加減算で数値を8進数として扱わない

" #search
set incsearch
set hlsearch | nohlsearch "Highlight search patterns, support reloading

" #tab
set shiftround
set expandtab     "Tabキーでスペース挿入
set tabstop=2     "Tab表示幅
set softtabstop=2 "Tab押下時のカーソル移動量
set shiftwidth=2  "インデント幅
" set smarttab

" #fold
set foldmethod=marker
set foldcolumn=1
set foldtext=FoldCCtext()
set foldlevel=0     " どのレベルから折りたたむか
set foldnestmax=2   " どの深さまで折りたたむか
" set foldenable
" set foldclose=all " 折りたたんでるエリアからでると自動で閉じる

" set list
set listchars=tab:❯\ ,trail:˼,extends:»,precedes:«,nbsp:%

let &clipboard = IsMac()? 'unnamed' : 'unnamedplus'
set cpoptions-=m

set t_Co=256
set background=dark

" Change cursor shape.
if &term =~ "xterm"
  let &t_SI = "\<Esc>]12;lightgreen\x7"
  let &t_EI = "\<Esc>]12;white\x7"
endif

Source 'function'
Source 'keymap'

" #auto commands

au uAutoCmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
"Todo: 起動時のみにするかも
au uAutoCmd BufEnter    * lcd %:p:h
au uAutoCmd VimResized  * wincmd =

" 引数を全てタブで開く 条件付けないとcommittiaがうまくいなかくなる
" au uAutoCmd VimEnter    * nested if 2 <= argc() | tab ball | endif

" windowの行数の20%にセットする scrolloffはglobal-option
command! SmartScrolloff let &scrolloff=float2nr(winheight('')*0.2)
au uAutoCmd VimEnter * SmartScrolloff
au uAutoCmd WinEnter * SmartScrolloff

" _を除くと*での検索がやりずらい
au uAutoCmd FileType vim setl iskeyword-=#
au uAutoCmd FileType * setl formatoptions-=ro
" r When type <return> in insert-mode auto insert commentstring
" o	ノーマルモードで'o'、'O'を打った後に、現在のコメント指示を自動的に挿入する。

au uAutoCmd FileType * nested call s:set_colors()
au uAutoCmd ColorScheme * highlight Visual cterm=reverse
au uAutoCmd ColorScheme * hi Todo ctermfg=201 ctermbg=56
"au uAutoCmd CursorMoved * nohlsearch

function! s:set_colors() "{{{
  if exists("g:set_colors")
    return 0
  end

  if &filetype == 'cpp' || &filetype == 'c'
    colorscheme lettuce
    " colorscheme kalisi
  elseif &filetype == 'ruby' || &filetype == 'gitcommit'
    colorscheme railscasts_u10
  elseif &filetype == 'vimfiler'
    " 一度だけ実行するautocmd
    augroup set_airline_color
      autocmd!
      autocmd FileType * colorscheme airline_color | autocmd! set_airline_color
    aug END

    colorscheme vimfiler_color
    return 0
  else
    colorscheme molokai
  endif

  colorscheme vimfiler_color

  let g:set_colors=1
endfunction "}}}

" each filetype config
au uAutoCmd FileType c,cpp,ruby,zsh,php,perl set cindent
au uAutoCmd FileType c,cpp set commentstring=//\ %s
au uAutoCmd FileType html,css set foldmethod=indent
au uAutoCmd FileType diff nnoremap <silent><buffer> q :<CR>

au uAutoCmd FileType help call s:help_config()
function! s:help_config()
  nnoremap <silent><buffer> q :q<CR>
  setlocal foldmethod=indent
  setlocal number
endfunction

" InsertLeave
let g:autosave_when_insertleave = 0
command! AutoSaveWhenInsertLeaveToggle let g:autosave_when_insertleave=!g:autosave_when_insertleave | echo "autosave when insertleave toggled"
nnoremap <silent><buffer> <F2> :AutoSaveWhenInsertLeaveToggle<CR>
au uAutoCmd InsertLeave * nested if g:autosave_when_insertleave != 0 | write | endif

if filereadable(expand('~/.vimrc_local_after'))
  source $HOME/.vimrc_local_after
endif

