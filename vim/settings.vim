" Settings
" -------------------------
set clipboard=unnamed
set number                          " show line numbers
set cursorline                      " highlight current line
set laststatus=2                    " last window always has a statusline
set hlsearch                        " highlight searched phrases
set ignorecase                      " make searches case-insensitive
set smartcase                       " ignore case unless there is an uppercase letter
set ruler                           " always show info along bottom
set showmatch
set wildmenu
set wildignorecase
set splitbelow
set splitright
set autoindent                      " auto-indent
set tabstop=2                       " tab spacing
set softtabstop=2                   " unify
set shiftwidth=2                    " indent/outdent by 2 columns
set shiftround                      " always indent/outdent to the nearest tabstop
set expandtab                       " use spaces instead of tabs
set smarttab                        " use tabs at the start of a line, spaces elsewhere
set shortmess+=I                    " hide the launch screen
set visualbell
set noshowmode
set scrolloff=2
set sidescroll=1
set sidescrolloff=5
set noswapfile
set undofile
set autowriteall
set confirm
set updatetime=150
set lazyredraw                      " redraw only when we need to.
set mouse=a
set title                           " enable setting title
set titlestring=%F%a%r%m            " configure title to look like: /path/to/file
set titlelen=120
set bg=light

filetype indent on
syntax on
autocmd FocusGained,BufEnter * silent! checktime                " reload buffer when focus changes
autocmd FocusLost,Bufleave * silent! wa                         " save buffer when focus changes
autocmd StdinReadPost * set buftype=nofile
autocmd VimEnter * silent! lcd %:p:h                            " set working directory


" Key Bindings
" -------------------------

let mapleader = " "
nmap <silent> Q :qa<CR>
nmap U <C-r>
nmap <silent> gt :bnext<CR>
nmap <silent> gr :bprev<CR>
inoremap <M-CR> <Esc>o
inoremap <S-CR> <Esc>O
nnoremap <M-CR> o<Esc>
nnoremap <S-CR> O<Esc>
nnoremap <silent> <Esc> :noh<CR>
nnoremap <C-CR> i<CR><Esc>
nnoremap <C-n> <Tab>
nnoremap <Leader>o :e
nnoremap <silent> <Leader>n :enew<CR>
nnoremap <Leader>w :terminal<CR>
nnoremap <Leader>W :split<CR>:terminal<CR>
nnoremap <Leader>s <C-w>s
nnoremap <Leader>v <C-w>v
nnoremap <Leader>c :bp\|bd #<CR>
nnoremap <Leader><Leader> :w<CR>
nnoremap <silent> <Leader>C <C-w>c
nnoremap <Leader>r :%s///gc<Left><Left><Left><Left>
vnoremap <Leader>r :s///gc<Left><Left><Left><Left>
map ö [
map ä ]

" indent with tab key
nnoremap <Tab> >>_
nnoremap <S-Tab> <<_
inoremap <S-Tab> <C-d>
vnoremap <Tab> >gv
vnoremap <S-Tab> <gv

" easier page navigation
nnoremap <C-d> 20<C-e>
nnoremap <C-u> 20<C-y>
nnoremap j gj
nnoremap k gk
nnoremap gj j
nnoremap gk k
nnoremap <BS> {
nnoremap <expr> <CR> empty(&buftype) ? '}' : '<CR>'
onoremap <expr> <CR> empty(&buftype) ? '}' : '<CR>'
vnoremap <BS> {
vnoremap <CR> }
nnoremap ü <C-^>
noremap ß g_

" make Y yank until end of line
nnoremap Y y$

" have x (removes single character) not go into the default registry
noremap x "_x
noremap X "_X
"
" make quotes into movements
onoremap q i"
onoremap Q i'
onoremap aq a"
onoremap aQ a'

vnoremap q i"
vnoremap Q i'
vnoremap aq a"
vnoremap aQ a'

" navigate splits
nnoremap <C-h> <C-w><C-h>
nnoremap <C-j> <C-w><C-j>
nnoremap <C-k> <C-w><C-k>
nnoremap <C-l> <C-w><C-l>

" make current folder working directory
nmap <Leader>h :lcd %:p:h<bar>:echo 'Working directory: ' . expand('%:p:h')<CR>

" toggle word case
nnoremap <M-u> viw~
inoremap <M-u> <Esc>viw~ea

" add macOS shortcuts for editing in insert mode
inoremap <M-b> <C-Left>
inoremap <M-f> <Esc>ea
inoremap <M-BS> <C-w>
inoremap <M-d> <C-O>de
inoremap <C-a> <Home>
inoremap <C-e> <End>
inoremap <C-x><BS> <C-u>
inoremap <C-k> <C-o>D
inoremap <C-_> <C-o>u
inoremap <C-x><C-_> <C-O><C-r>
inoremap <C-u> <Esc>ddI

" add macOS shortcuts for editing in command mode
cnoremap <C-a> <Home>
cnoremap <C-e> <End>
cnoremap <M-BS> <C-w>
cnoremap <C-x><BS> <C-u>
cnoremap <M-b> <S-Left>
cnoremap <M-f> <S-Right>


" Other
" -------------------------

" vimr
if has("gui_vimr")
    " add macOS shortcuts for editing in insert mode
    inoremap <M-Left> <C-Left>
    inoremap <M-Right> <Esc>ea
    inoremap <M-BS> <C-w>
    inoremap <M-DEL> <C-O>de
    inoremap <D-BS> <C-u>
    inoremap <D-DEL> <C-o>D
    inoremap <D-Left> <Home>
    inoremap <D-Right> <End>

    " new line shortcuts in insert mode
    nnoremap <C-g> i<CR><Esc>
    inoremap <D-g> <Esc>o
    inoremap <S-D-g> <Esc>O
    nnoremap <D-g> o<Esc>
    nnoremap <S-D-g> O<Esc>

    " toggle word case
    nnoremap <S-D-u> viw~
    inoremap <S-D-u> <Esc>viw~ea
endif
