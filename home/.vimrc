" Use Vim settings, rather than Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

filetype off        " required by Vundle. We will enable it afterwards

" Set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" Alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" Let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" List of plugins/Vundles
Plugin 'https://github.com/blueshirts/darcula.git'
Plugin 'mhinz/vim-startify'
Plugin 'vim-airline/vim-airline'
Plugin 'edkolev/tmuxline.vim'
Plugin 'ptzz/lf.vim'
Plugin 'mattn/webapi-vim'
Plugin 'mattn/gist-vim'
Plugin 'airblade/vim-gitgutter'
Plugin 'kshenoy/vim-signature'
Plugin 'rodjek/vim-puppet'
Plugin 'confluencewiki.vim'
Plugin 'vimwiki/vimwiki'
Plugin 'mtth/scratch.vim'
Plugin 'ZoomWin'
Plugin 'junegunn/fzf.vim'
Plugin 'qpkorr/vim-bufkill'

" All of your Plugins must be added before the following line
call vundle#end()

" Function to source only if file exists {
function! SourceIfExists(file)
  if filereadable(expand(a:file))
    exe 'source' a:file
  endif
endfunction
" }

" Load fzf
set rtp+=/usr/local/opt/fzf

filetype plugin indent on

syntax on                   " Enable syntax highlighting
silent! colorscheme darcula " Load colorschema but don't complaint if it doesn't exists
set guifont=Inconsolata\ for\ Powerline:h15
set number
if has("gui_running")
    " Make the background transparent
    highlight Normal guibg=NONE ctermbg=NONE 
endif

" Status line
set showcmd         " Show partial/incomplete commands in the last line of the screen
set showmode        " Let yorself know in which mode you are in
set wildmenu        " Display completion matches in a status line
set laststatus=2    " Always display the status line, even if only one window is displayed

" Line behaviours
set wrap            " Wrap lines visually. Long lines will be displayed as multiple lines
set textwidth=0     " Prevent automatic wrap of lines
set wrapmargin=0    " Prevent automatic wrap of lines (right margin)

" Prefer spaces over tabs
set expandtab       " Insert spaces when the tab key is pressed
set tabstop=4       " Set the number of spaces to be added (after expandtab is set)
set shiftwidth=4    " Change the number of space characters inserted for indentation
set softtabstop=4   " Makes the backspace key threat the four spaces like a tab (one backspace goes back a full 4 spaces)
set autoindent      " Copy the indentation from the previous line

" Buffers
set hidden          " Allow switching buffers with unsaved changes
set confirm         " Ask for confirmation before quitting when there are buffers with unsaved changes

" Splits
set splitbelow      " Open new vertical splits below
set splitright      " Open new horizontal splits on the right

" Search
set ignorecase      " Use case insensitive search
set smartcase       " Except when using capital letters
set hlsearch        " Highlight searches

" Centralise swap and undo files
set directory=$HOME/.vim/data/swap/
set undodir=~/.vim/data/undo/
set undofile

" Filetype settings
filetype on
filetype plugin on  " Enable file type detection
filetype indent on  " Detects indentation based on indentation scripts located in the indent folder of the vim installation

" Key mappings {{{
let mapleader=" "

vmap <up> <NOP>
vmap <down> <NOP>
vmap <left> <NOP>
vmap <right> <NOP>

noremap <up> <NOP>
noremap <down> <NOP>
noremap <left> <NOP>
noremap <right> <NOP>

" Remap ESC
inoremap jj <ESC>
inoremap jk <ESC>

" Move around (get the codes by typing CTRL + V and CTRL + desired key in insert mode)
noremap [B ddp                                " Move lines down
noremap [A ddkP                               " Move lines up

" Splits 
nnoremap <c-j> <c-w><c-j>                       " Move to the split below
nnoremap <c-k> <c-w><c-k>                       " Move to the split above
nnoremap <c-l> <c-w><c-l>                       " Move to the split at the right
nnoremap <c-h> <c-w><c-h>                       " Move to the split at the left

nnoremap <c-w>M <C-W>\| <C-W>_                  " Maximize the window
nnoremap <c-w>m <C-W>=                          " Resize window (50%)

" Clipboard
noremap YY "*y<CR>
noremap PP "*gP<CR>
noremap XX "*x<CR>

nmap <silent> <leader>ev :e $HOME/.vimrc<cr>    " Edit this file ('e'dit 'v'imrc)
nmap <silent> <leader>sv :so $HOME/.vimrc<cr>   " Source this file ('s'ource 'v'imrc)

nnoremap <leader>r :nohl<CR><C-L>               " Map Redraw screen (<leader>r) to also turn off search highlighting

noremap <Leader>W :w !sudo tee % > /dev/null    " Save as sudo

map <silent> <c-s> :Startify<CR>                " Open Startify
map <silent> <c-n> :NERDTreeToggle<CR>          " Open NERDTree

" Plugings Settings {{{
" =====================
" = Plugings Settings =
" =====================

" Startify
let g:startify_bookmarks = [ {'v': '~/.vimrc'} , {'z': '~/.zshrc'} ]
let g:startify_list_order = [
        \ ['   Bookmarks:'], 'bookmarks',
        \ ['   Recently used files:'], 'files',
        \ ['   Recently used in current directory:'], 'dir',
        \ ['   Sessions:'], 'sessions',
        \ ['   Command:'], 'commands',
    \ ]

" NERDTree
" let g:NERDTreeDirArrowExpandable="▸"
" let g:NERDTreeDirArrowCollapsible="▾"

" Gist
let g:gist_show_privates = 1
let g:gist_post_private = 1
let g:gist_detect_filetype = 1

" Gitgutter
let g:gitgutter_enabled = 1
let g:gitgutter_signs = 1
let g:gitgutter_highlight_lines = 0

" Tmuxline
let g:airline#extensions#tmuxline#enabled = 0 " Let vim-airline manage the colors

" Vim Wiki
let wiki_1 = {}
let wiki_1.path = '~/Dropbox/Josemi/Documents/Wikis/Personal/'
let wiki_1.html_path = '~/Dropbox/Josemi/Public/Wikis/Personal/Export/'
let wiki_1.auto_export = 1 " Won't work since at the moment only works for default syntax and not for markdown
let wiki_1.auto_toc = 1
let wiki_1.index = 'index'
let wiki_1.syntax = 'markdown'
let wiki_1.ext = '.md'
let wiki_1.nested_syntaxes = {'php': 'php', 'bash': 'sh', 'py': 'python', 'js': 'javascript', 'html': 'html', 'css': 'css'}

let wiki_2 = {}
let wiki_2.path = '~/Dropbox/Josemi/Documents/Wikis/Westwing/'
let wiki_2.html_path = '~/Dropbox/Josemi/Public/Wikis/Westwing/Export/'
let wiki_2.auto_export = 1 " Won't work since at the moment only works for default syntax and not for markdown
let wiki_2.auto_toc = 1
let wiki_2.index = 'index'
let wiki_2.syntax = 'markdown'
let wiki_2.ext = '.md'
let wiki_2.nested_syntaxes = {'php': 'php', 'bash': 'sh', 'py': 'python', 'js': 'javascript', 'html': 'html', 'css': 'css'}

let g:vimwiki_list = [wiki_1, wiki_2]

let g:vimwiki_hl_headers = 1 " Colors for headers
let g_vimwiki_hl_cb_checked = 1
let g:vimwiki_global_ext = 0
let g:vimwiki_menu = ''
let g:vimwiki_listsyms = '✗○◐●✓'

" Scratch.vim
let g:scratch_persistence_file = '~/.scratch.md'

" vimpager
let g:vimpager = {}
let g:less     = {}

let g:vimpager.ansiesc = 0
let g:vimpager.passthrough = 1

" DbExt
let g:dbext_default_passwd_use_secret = 1
let g:dbext_default_prompt_for_variables = 0
let g:dbext_default_stop_prompt_for_variables = 2
let g:dbext_default_display_cmd_line = 0 
let g:dbext_default_variable_remember = 1

call SourceIfExists("~/.vim/dbextrc")

" Lf
let g:lf_replace_netrw = 1 
