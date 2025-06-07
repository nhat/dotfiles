" Plugins
" -------------------------

call plug#begin('~/.vim/plugged')
Plug 'stevearc/oil.nvim'
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
Plug 'github/copilot.vim'
Plug 'nvim-lua/plenary.nvim'
Plug 'CopilotC-Nvim/CopilotChat.nvim', { 'branch': 'canary' }
Plug 'airblade/vim-gitgutter'
Plug 'mattn/emmet-vim'
Plug 'dbakker/vim-paragraph-motion'
Plug 'chrisbra/matchit'
Plug 'justinmk/vim-sneak'
Plug 'mechatroner/rainbow_csv'
Plug 'godlygeek/tabular'
Plug 'preservim/vim-markdown'
Plug 'windwp/nvim-autopairs'
Plug 'bronson/vim-trailing-whitespace'
Plug 'google/vim-searchindex'
Plug '/usr/local/opt/fzf'
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
Plug 'lbrayner/vim-rzip'
Plug 'w0rp/ale'
Plug 'sbdchd/neoformat'
Plug 'ap/vim-buftabline'
Plug 'itchyny/lightline.vim'
Plug 'vimpostor/vim-lumen'
Plug 'rakr/vim-one'
call plug#end()

for f in glob('$HOME/.dotfiles/vim/plugins/*.vim', 0, 1)
  execute 'source' f
endfor

" Key Bindings
" -------------------------

" search files and buffers
nmap <silent><C-p> :Fzf<CR>
imap <silent><C-p> <Esc>:Fzf<CR>
nmap <silent><Leader><CR> :Buffers<CR>
nmap <silent><Leader>f :Ag<CR>

command! Fzf
    \ :FZF --prompt=🔍\  --reverse --no-separator --color=spinner:250,pointer:0,fg+:-1,bg+:-1,prompt:\#625F50,hl+:\#E75544,hl:\#E75544,info:\#FAFAFA --bind change:top

" toggle comment
nmap <M-/> <Plug>CommentaryLine j0
vmap <M-/> <Plug>Commentary

" format buffer
nmap <silent><Leader>l :Neoformat<CR>
vmap <silent><Leader>l :Neoformat<CR>

" navigate to error
nmap <silent> <f2> <Plug>(ale_next_wrap)
nmap <silent> <S-f2> <Plug>(ale_previous_wrap)


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
highlight luaFunc guifg=none
highlight PmenuSel guibg=#4078f2 guifg=white
highlight NormalFloat guibg=none
highlight FloatBorder guifg=#A0A0A8

" colorscheme for terminal
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

" vim-move
let g:move_key_modifier = 'C-S'
let g:move_key_modifier_visualmode = 'C-S'

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

" copilot
imap <C-l> <Plug>(copilot-accept-word)

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

" vim-markdown
let g:vim_markdown_folding_disabled = 1

" remove undo files which have not been modified for 30 days
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

call Tmpwatch(&undodir, 30)

" Add open recent files to macOS Recent Items
let g:addtorecent_ignore_files = ['COMMIT_EDITMSG']
function! AddToRecentIfNeeded(filepath) abort
  " Only proceed if file exists
  if !filereadable(a:filepath)
    return
  endif

  " Get the filename (not the path)
  let l:filename = fnamemodify(a:filepath, ':t')

  " Check against ignore list
  for ignored in g:addtorecent_ignore_files
    if l:filename ==# ignored
      return
    endif
  endfor

  " Construct the full app path
  let l:app_path = expand('$HOME') . '/.dotfiles/macos/AddToRecent.app'

  " Call the system command
  call system('open -a ' . shellescape(l:app_path) . ' ' . shellescape(a:filepath))
endfunction

autocmd BufReadPost * call AddToRecentIfNeeded(expand('%:p'))

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
endif

" vimr
if exists("g:gui_vimr")
    " fzf
    command! -bang Ag
    \  call fzf#vim#ag(<q-args>,
    \    fzf#vim#with_preview({'options': ['--layout=reverse', '--color=spinner:250,pointer:0,fg+:-1,bg+:-1,prompt:#625F50,hl+:#E75544,hl:#E75544,info:#FAFAFA', '--bind=change:top']}),
    \    <bang>0)

    nmap <silent><D-p> :Fzf<CR>
    imap <silent><D-p> <Esc>:Fzf<CR>

    " toggle comment
    nmap <D-S-m> <Plug>CommentaryLine j0
    vmap <D-S-m> <Plug>Commentary

    " rollback chunk
    nmap <M-D-z> <Leader>hu

    " vim move, move line up/down with ctrl+j/k
    let g:move_key_modifier = 'C'
    let g:move_key_modifier_visualmode = 'C'
endif

lua << EOF
require("nvim-autopairs").setup {}

require("oil").setup({
  delete_to_trash = true,
  keymaps = {
    ["<C-p>"] = false
  }
})

vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })

require("CopilotChat").setup {
  window = {
    layout = 'float',
    relative = 'cursor',
    width = 1,
    height = 0.4,
    row = 1,
    border = 'rounded',
  },
  show_folds = false,
  auto_insert_mode = true, -- Automatically enter insert mode when opening window and on new prompt
  separator = '',
  mappings = {
    complete = {
      insert = '<C-n>',
    },
    submit_prompt = {
      normal = '<CR>',
      insert = '<CR>',
    },
  }
}

vim.keymap.set({'n', 'v'}, "<Leader>q", function()
    if vim.fn.line('.') > (vim.fn.winheight(0) / 2) then
        vim.cmd('normal! zz')
    end

    vim.cmd("CopilotChatOpen")
end, { desc = "Open CopilotChat quick chat" })

local open_chat_keymap = vim.g.gui_vimr ~= nil and '<C-S-F19>' or '<C-S-c>'
vim.keymap.set({'n', 'v', 'i'}, open_chat_keymap, function()
  local pane_width = vim.api.nvim_win_get_width(0)
  local layout = pane_width > 100 and 'vertical' or 'horizontal'

  require("CopilotChat").toggle({
    window = {
      layout = layout,
      width = 0.35,
    },
    auto_insert_mode = false,
  }) end, { desc = "Open CopilotChat" })
EOF

