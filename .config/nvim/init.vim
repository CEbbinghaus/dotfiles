" Install vim-plug if not already
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

"Wraps cursor up and down lines https://vim.fandom.com/wiki/Automatically_wrap_left_and_right
set whichwrap+=<,>,h,l,[,]

"Allows moving lines up and down with Alt+[J,K] https://vim.fandom.com/wiki/Moving_lines_up_or_down#:~:text=In%20normal%20mode%20or%20in,to%20move%20the%20block%20up.

nnoremap <A-j> :m .+1<CR>==
nnoremap <A-k> :m .-2<CR>==
inoremap <A-j> <Esc>:m .+1<CR>==gi
inoremap <A-k> <Esc>:m .-2<CR>==gi
vnoremap <A-j> :m '>+1<CR>gv=gv
vnoremap <A-k> :m '<-2<CR>gv=gv

" Map Ctrl+Backspace to delete previous word
inoremap <C-BS> <C-W>
inoremap <C-H> <C-W>

" Map Ctrl+Delete to delete next word
inoremap <C-Del> X<Esc>lbce

set number
set cursorline
hi CursorLineNr guifg=#af00af

" Load Plug
call plug#begin()

" Theme
Plug 'catppuccin/nvim', { 'as': 'catppuccin' }

" Saves last location
Plug 'ethanholz/nvim-lastplace'

" Syntax Highlighting
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

" File Browser
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-tree/nvim-web-devicons'
Plug 'MunifTanjim/nui.nvim'
Plug 'nvim-neo-tree/neo-tree.nvim'

" Git blame per line
Plug 'f-person/git-blame.nvim'

call plug#end()

" Neovim specific commands
if has('nvim')
	" Loads Lua configuration
	" let luaInit = stdpath('config') . 'linit'
	lua require('config')
endif

colorscheme catppuccin-macchiato " catppuccin-latte, catppuccin-frappe, catppuccin-macchiato, catppuccin-mocha

