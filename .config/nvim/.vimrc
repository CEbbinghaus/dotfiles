




"Wraps cursor up and down lines https://vim.fandom.com/wiki/Automatically_wrap_left_and_right
set whichwrap+=<,>,h,l,[,]

"Allows moving lines up/down with Alt+J/K https://vim.fandom.com/wiki/Moving_lines_up_or_down#:~:text=In%20normal%20mode%20or%20in,to%20move%20the%20block%20up.

nnoremap <M-j> :m .+1<CR>==
nnoremap <M-k> :m .-2<CR>==
inoremap <M-j> <Esc>:m .+1<CR>==gi
inoremap <M-k> <Esc>:m .-2<CR>==gi
vnoremap <M-j> :m '>+1<CR>gv=gv
vnoremap <M-k> :m '<-2<CR>gv=gv

" Move lines up/down with Alt+Up/Down
nnoremap <M-Down> :m .+1<CR>==
nnoremap <M-Up> :m .-2<CR>==
inoremap <M-Down> <Esc>:m .+1<CR>==gi
inoremap <M-Up> <Esc>:m .-2<CR>==gi
vnoremap <M-Down> :m '>+1<CR>gv=gv
vnoremap <M-Up> :m '<-2<CR>gv=gv

" Duplciate lines up/down with Alt+Shift+J/K
nnoremap <M-J> :t .<CR>==
nnoremap <M-K> :t .-1<CR>==
inoremap <M-J> <Esc>:t .<CR>==gi
inoremap <M-K> <Esc>:t .-1<CR>==gi
vnoremap <M-J> :t '><CR>gv=gv
vnoremap <M-K> :t '<-1<CR>gv=gv

" Duplicate lines up/down with Alt+Shift+Up/Down
nnoremap <M-S-Down> :t .<CR>==
nnoremap <M-S-Up> :t .-1<CR>==
inoremap <M-S-Down> <Esc>:t .<CR>==gi
inoremap <M-S-Up> <Esc>:t .-1<CR>==gi
vnoremap <M-S-Down> :t '><CR>gv=gv
vnoremap <M-S-Up> :t '<-1<CR>gv=gv

" Record next key litterally and insert it 
inoremap <M-r> <C-V>

" Map Ctrl+Backspace to delete previous word
inoremap <C-BS> <C-W>
inoremap <C-H> <C-W>

" Map Ctrl+Delete to delete next word
inoremap <C-Del> X<Esc>lbce

" Ctrl+S saves current buffer
nnoremap <C-s> :w <CR>==
inoremap <C-s> <Esc>:w <CR>==gi
vnoremap <C-s> <Esc>:w <CR>==gv=gv

" Escape terminal mode by hitting Esc
tnoremap <Esc> <C-\><C-N>


" Closes the current buffer and opens the next to ensure that neo-tree doesn't
" close the window.
function! CloseBuffer()
  try
	  execute 'bn | bd#'
  catch
	  execute 'bd'
  endtry
endfunction

noremap <silent> <C-w> :call CloseBuffer()<CR>

" Copy copies to the system clipboard https://www.reddit.com/r/neovim/comments/3fricd/easiest_way_to_copy_from_neovim_to_system/
set clipboard+=unnamedplus

" Enable numberline and highlight current line number: https://vi.stackexchange.com/questions/27989/how-to-highlight-cursor-line-number-without-cursor-line
set number
set cursorline
hi CursorLineNr guifg=#af00af

" It seems that setting the shell to powershel breaks plughttps://www.reddit.com/r/neovim/comments/gbb2g3/wierd_vimplug_error_messages/
" if system("where powershell") != "" 
"	set shell=powershell
"endif
finish

if !has('nvim')
	finish
endif

