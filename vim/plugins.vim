" Plugins
" -------------------------

call plug#begin('~/.vim/plugged')
Plug 'tpope/vim-vinegar'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-unimpaired'
Plug 'moll/vim-bbye' " dependency for vim-symlink
Plug 'aymericbeaumet/vim-symlink'
Plug 'matze/vim-move'
Plug 'terryma/vim-expand-region'
Plug 'arecarn/vim-crunch'
Plug 't9md/vim-smalls'
Plug 'airblade/vim-gitgutter'
Plug 'w0rp/ale'
Plug 'mattn/emmet-vim'
Plug 'bronson/vim-trailing-whitespace'
Plug 'google/vim-searchindex'
Plug 'tmsvg/pear-tree'
Plug '/usr/local/opt/fzf'
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
Plug 'sbdchd/neoformat'
Plug 'sheerun/vim-polyglot'
Plug 'ap/vim-buftabline'
Plug 'itchyny/lightline.vim'
Plug 'rakr/vim-one'
call plug#end()


" Key Bindings
" -------------------------

" search files and buffers
nmap <silent><C-p> :FZF<CR>
imap <silent><C-p> <Esc>:FZF<CR>
nmap <silent><Leader><CR> :Buffers<CR>

" toggle comment
nmap <M-/> <Plug>CommentaryLine j0
vmap <M-/> <Plug>Commentary

" make f search for 2 chars
nmap <Leader>f <Plug>(smalls)

" format buffer
nmap <silent><Leader>l :Neoformat<CR>
vmap <silent><Leader>l :Neoformat<CR>

" navigate to error
nmap <silent> <f2> <Plug>(ale_next_wrap)
nmap <silent> <S-f2> <Plug>(ale_previous_wr


" Other
" -------------------------

" colorscheme
colorscheme one
highlight Normal ctermbg=white
highlight Directory gui=bold
highlight Comment gui=italic
highlight Search guibg=#EBCB8B guifg=#3C3C3C
highlight Incsearch gui=none guibg=LightGoldenrod1 guifg=#3C3C3C
call one#highlight('xmlNamespace', 'e45649', '', 'none')
call one#highlight('xmlAttribPunct', 'e45649', '', 'none')

" corlorscheme for terminal
let g:terminal_color_0 = '#3c3c3c'
let g:terminal_color_1 = '#e45649'
let g:terminal_color_2 = '#50a14f'
let g:terminal_color_3 = '#ebcb8b'
let g:terminal_color_4 = '#4078f2'
let g:terminal_color_5 = '#a626a4'
let g:terminal_color_6 = '#0184bc'
let g:terminal_color_7 = '#a0a1a7'
let g:terminal_color_8 = '#3c3c3c'
let g:terminal_color_9 = '#e45649'
let g:terminal_color_10 = '#50a14f'
let g:terminal_color_11 = '#c18401'
let g:terminal_color_12 = '#4078f2'
let g:terminal_color_13 = '#a626a4'
let g:terminal_color_14 = '#0184bc'
let g:terminal_color_15 = '#fafafa'

" buffline
let g:buftabline_show = 1
let g:buftabline_indicators = 1
highlight default link BufTabLineHidden PmenuSel

" smalls
let g:smalls_auto_jump = 1
let g:smalls_shade = 0
let g:smalls_jump_keys = 'ASDFJKLQWERZXCNMUIOP'
let g:smalls_auto_jump_min_input_length = 1
let g:smalls_auto_jump_timeout = 0.0
let g:smalls_highlight = {
    \ 'SmallsJumpTarget':
    \     [['NONE', 'NONE', 'Red'],[ 'bold', '#FDD945', 'Black']],
    \ 'SmallsCandidate':
    \     [['NONE', 'Gray', 'Magenta'],[ 'NONE', '#DCDCDC', 'Red']],
    \ 'SmallsPos':
    \     [['NONE', 'Green', 'Black'],[ 'NONE', '#4078F2', 'White']]
    \ }

" gitgutter
let g:gitgutter_realtime = 1
let g:gitgutter_sign_added = '█'
let g:gitgutter_sign_modified = '█'
let g:gitgutter_sign_removed = '▁'
let g:gitgutter_sign_modified_removed = '█'

" fzf
let g:fzf_layout = { 'down': '~30%' }
" search files in git root directory
function! s:find_git_root()
  return system('git rev-parse --show-toplevel 2> /dev/null')[:-2]
endfunction
command! ProjectFiles execute 'Files' s:find_git_root()

" vinegar
let g:netrw_fastbrowse = 0
" don't show hidden files
let g:netrw_list_hide = '\(^\|\s\s\)\zs\.\S\+'

" apply macro to selected lines
xnoremap @ :<C-u>call ExecuteMacroOverVisualRange()<CR>
function! ExecuteMacroOverVisualRange()
  echo "@".getcmdline()
  execute ":'<,'>normal @".nr2char(getchar())
endfunction

" neoformat
autocmd FileType javascript,typescript setlocal formatprg=prettier
    \\ --stdin
    \\ --print-width\ 120
    \\ --single-quote
    \\ --trailing-comma\ es5
autocmd FileType xml,html setlocal formatprg=js-beautify\ --type\ html\ --quiet\ --wrap-line-length\ 120\ -
autocmd FileType lua setlocal formatprg=luafmt\ --indent-count\ 2\ --stdin
let g:neoformat_enabled_json = ['jq']
let g:neoformat_basic_format_align = 1
let g:neoformat_basic_format_retab = 1
let g:neoformat_try_formatprg = 1

" ale
let g:ale_lint_on_text_changed = 'never'
let g:ale_lint_on_enter = 0
let g:ale_sign_error = '✖︎'
let g:ale_sign_warning = '⚠'
autocmd InsertLeave,TextChanged * silent! if (&filetype ==# 'json' || &filetype ==# 'xml') | ALELint | endif
highlight ALEError guibg=#e45649 guifg=white cterm=undercurl

" emmet
let g:user_emmet_install_global = 0
autocmd FileType html,css EmmetInstall
autocmd FileType html,css imap <silent><expr><tab> emmet#expandAbbrIntelligent("\<tab>")

" fix whitespace
autocmd BufEnter * highlight clear ExtraWhitespace      " don't show whitespace
autocmd BufWrite * FixWhitespace

" show highlight groups at cursor
nmap <Leader>k :call <SID>SynStack()<CR>
function! <SID>SynStack()
    if !exists("*synstack")
        return
    endif
    echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfunc

" lightline
let g:lightline = {
    \ 'colorscheme': 'one',
    \ 'active': {
    \   'left': [ [ 'mode', 'paste' ],
    \             [ 'fugitive', 'readonly', 'filename', 'modified' ] ]
    \ },
    \ 'component': {
    \   'readonly': '%{&filetype=="help"?"":&readonly?"":""}',
    \   'modified': '%{&filetype=="help"?"":&modified?"+":&modifiable?"":"-"}',
    \   'fugitive': '%{exists("*fugitive#head")?fugitive#head():""}'
    \ },
    \ 'component_visible_condition': {
    \   'readonly': '(&filetype!="help"&& &readonly)',
    \   'modified': '(&filetype!="help"&&(&modified||!&modifiable))',
    \   'fugitive': '(exists("*fugitive#head") && ""!=fugitive#head())'
    \ },
    \ 'separator': { 'left': '', 'right': '' },
    \ 'subseparator': { 'left': '', 'right': '' }
    \ }

if has('nvim')
    if (has("termguicolors"))
        set termguicolors
    endif
    set signcolumn=yes

    " no line highlight in terminal
    autocmd TermOpen * setlocal listchars= | set nocursorline | set nocursorcolumn

    tnoremap jj <C-\><C-n>
    tnoremap kk <C-\><C-n>

    autocmd! FileType fzf
    autocmd  FileType fzf setlocal laststatus=0 noruler titlestring=fzf
        \| autocmd BufLeave <buffer> set laststatus=2 ruler titlestring=%F%a%r%m

    function! Tmpwatch(path, days)
        let l:path = expand(a:path)
        if isdirectory(l:path)
            for file in split(globpath(l:path, "*"), "\n")
                if localtime() > getftime(file) + 86400 * a:days && delete(file) != 0
                    echo "Tmpwatch(): Error deleting '" . file . "'"
                endif
            endfor
        else
            echo "Tmpwatch(): Directory '" . l:path . "' not found and will be created"
            !mkdir -p l:path
        endif
    endfunction

    " remove undo files which have not been modified for 30 days
    call Tmpwatch(&undodir, 30)
endif

" vimr
if has("gui_vimr")
    " fzf
    nmap <silent><D-p> :FZF --reverse --color=spinner:250,pointer:0,fg+:-1,bg+:-1,prompt:241,hl+:9,hl:9,info:255 --bind change:top<CR>
    imap <silent><D-p> <Esc>:FZF --reverse --color=spinner:250,pointer:0,fg+:-1,bg+:-1,prompt:241,hl+:9,hl:9,info:255 --bind change:top<CR>

    " toggle comment
    nmap <D-S-m> <Plug>CommentaryLine j0
    vmap <D-S-m> <Plug>Commentary

    " rollback chunk
    nmap <M-D-z> <Leader>hu

    " vim move
    let g:move_key_modifier = 'D'
endif

