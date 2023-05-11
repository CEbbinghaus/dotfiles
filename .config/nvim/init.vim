" Install vim-plug if not already
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

"Wraps cursor up and down lines https://vim.fandom.com/wiki/Automatically_wrap_left_and_right
set whichwrap+=<,>,h,l,[,]

" Load Plug
call plug#begin()

Plug 'ethanholz/nvim-lastplace'
Plug 'catppuccin/nvim', { 'as': 'catppuccin' }

call plug#end()

" Neovim specific commands
if has('nvim')
	" Loads Lua configuration
	" let luaInit = stdpath('config') . 'linit'
	lua require('config')
endif

colorscheme catppuccin-macchiato " catppuccin-latte, catppuccin-frappe, catppuccin-macchiato, catppuccin-mocha

