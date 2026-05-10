" Settings
" -------------------------
set clipboard=unnamed
set number                             " show line numbers
set cursorline                         " highlight current line
set laststatus=2                       " last window always has a statusline
set hlsearch                           " highlight searched phrases
set ignorecase                         " make searches case-insensitive
set smartcase                          " ignore case unless there is an uppercase letter
set ruler                              " always show info along bottom
set showmatch
set wildmenu
set wildignorecase
set splitbelow
set splitright
set autoindent                         " auto-indent
set tabstop=2                          " tab spacing
set softtabstop=2                      " unify
set shiftwidth=2                       " indent/outdent by 2 columns
set shiftround                         " always indent/outdent to the nearest tabstop
set expandtab                          " use spaces instead of tabs
set shortmess+=I                       " hide the launch screen
set visualbell
set noshowmode
set nowrap
set scrolloff=2
set sidescroll=1
set sidescrolloff=5
set noswapfile
set undofile
set autowriteall
set autoread
set confirm
set updatetime=150
set lazyredraw                         " redraw only when we need to.
set mouse=a
set title                              " enable setting title
set titlestring=%F%a%r%m               " configure title to look like: /path/to/file
set titlelen=120
set bg=light
set fillchars=eob:\ ,fold:\ ,vert:\│   " show blank chars for lines after end of file

filetype indent on
autocmd FocusGained,BufEnter * silent! checktime                " reload buffer when focus changes
autocmd FocusLost,Bufleave * silent! wa                         " save buffer when focus changes
autocmd StdinReadPost * set buftype=nofile
autocmd BufRead,BufNewFile *.csv set filetype=none              " show plain csv files
autocmd VimEnter * silent! lcd %:p:h                            " set working directory

let g:java_ignore_markdown = 1         " prevent E28 errors from markdown highlight groups in javadoc

" Key Bindings
" -------------------------

let mapleader = " "
nmap <silent> Q :qa<CR>
nmap U <C-r>
nmap <silent> gt :bnext<CR>
nmap <silent> gr :bprev<CR>

nnoremap <silent> <Esc> :noh<CR>
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

" indent with tab key
nnoremap <Tab> >>_
nnoremap <S-Tab> <<_
inoremap <S-Tab> <C-d>
vnoremap <Tab> >gv
vnoremap <S-Tab> <gv

" easier page navigation
nmap <C-d> 20<C-e>
nmap <C-u> 20<C-y>
nmap <BS> {
nmap <expr> <CR> empty(&buftype) ? '}' : '<CR>'
omap <expr> <CR> empty(&buftype) ? '}' : '<CR>'
vmap <BS> {
vmap <CR> }

" break into new lines with shift+enter
nnoremap <S-CR> i<CR><Esc>

" new line above with shift+meta+enter
inoremap <S-M-CR> <Esc>O
nnoremap <S-M-CR> O<Esc>

" make Y yank until end of line
nnoremap Y y$

" have x (removes single character) not go into the default register
noremap x "_x
noremap X "_X

" paste from last yanked register
nmap <silent><Leader>p "0p
vmap <silent><Leader>p "0p
nmap <silent><Leader>P "0P
vmap <silent><Leader>P "0P

" make quotes into movements
onoremap q i"
onoremap Q i'
onoremap aq a"

onoremap aQ a'

vnoremap q i"
vnoremap Q i'
vnoremap aq a"
vnoremap aQ a'


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

" nvim
if has("nvim")
    " highlight code by file type
    syntax on

    " new line below with meta+enter
    inoremap <M-CR> <Esc>o
    nnoremap <M-CR> o<Esc>

    " move cursor through soft-wrapped lines
    nnoremap <expr> k (v:count == 0 ? 'gk' : 'k')
    nnoremap <expr> j (v:count == 0 ? 'gj' : 'j')
    inoremap <silent> <Down> <C-o>gj
    inoremap <silent> <Up> <C-o>gk
end

" neovide
if exists("g:neovide")
    let g:neovide_scroll_animation_length = 0
    let g:neovide_cursor_animation_length = 0
    let g:neovide_cursor_trail_size = 0

    let g:neovide_input_macos_option_key_is_meta = 'only_left'
    let g:neovide_proxy_icon = v:true
    let g:neovide_confirm_quit = v:true
    let g:neovide_remember_window_size = v:true
    let g:neovide_theme = 'auto'

    " new line below with cmd+enter
    inoremap <D-CR> <Esc>o
    nnoremap <D-CR> o<Esc>

    " add macOS shortcuts for editing in insert mode
    inoremap <M-Left> <C-Left>
    inoremap <M-Right> <Esc>ea
    inoremap <M-BS> <C-w>
    inoremap <M-DEL> <C-O>de
    inoremap <D-BS> <C-u>
    inoremap <D-DEL> <C-o>D
    inoremap <D-Left> <Home>
    inoremap <D-Right> <End>

    " toggle word case
    nnoremap <S-D-u> viw~
    inoremap <S-D-u> <Esc>viw~ea
endif

