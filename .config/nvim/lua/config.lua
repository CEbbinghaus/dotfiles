
-- Leader character used for key combinations
vim.g.mapleader = " "

vim.keymap.set('n', '<C-b>', '<Cmd>Neotree toggle<CR>')

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<Leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<Leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<Leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<Leader>fh', builtin.help_tags, {})
