local vimrc = vim.fn.stdpath("config") .. "/.vimrc"
vim.cmd.source(vimrc)

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)
-- Leader character used for key combinations
vim.g.mapleader = " "
vim.o.guifont = "FiraCode Nerd Font:h14"

-- Initialize Plugins
require("lazy").setup({
	-- Theme
	{
		"catppuccin/nvim",
		name = "catppuccin",
		lazy = false,
		priority = 1000
	},
	-- global dependencies
	{
		'nvim-lua/plenary.nvim',
		lazy = false
	},
	{
		'glepnir/dashboard-nvim',
		event = 'VimEnter',
		opts = function() return require 'plugins.config.dashboard' end,
		dependencies = { 'nvim-tree/nvim-web-devicons' }
	},
	{
		"folke/neoconf.nvim",
		lazy = false,
		priority = 999,
		config = false
	},
	-- Saves last location
	{
		"ethanholz/nvim-lastplace",
		event = "BufAdd"
	},
	{
		'numToStr/Comment.nvim',
		event = "BufAdd",
		config = function()
			return require 'Comment'.setup{}
		end
	},
	-- Syntax Highlighting
	{
		'nvim-treesitter/nvim-treesitter',
		build = ':TSUpdate',
		config = function()
			return require 'nvim-treesitter.configs'.setup(require 'plugins.config.treesitter')
		end,
		cmd = { "TSUpdate", "TSInstall" },
		event = "BufAdd"
	},
	{ import = "plugins" },

	{
		'simrat39/symbols-outline.nvim',
		config = true,
		event = "LspAttach"
	},

	-- Git blame per line
	'f-person/git-blame.nvim',

	{
		'Shatur/neovim-session-manager',
		cmd = "SessionManager"
	}
}, require 'plugins.config.lazy')

vim.g.neo_tree_remove_legacy_commands = 1

vim.keymap.set('n', '<C-b>', '<Cmd>Neotree toggle<CR>')
vim.keymap.set('n', '<M-F>', function() vim.lsp.buf.format() end)
vim.keymap.set('i', '<M-F>', function() vim.lsp.buf.format() end)
vim.keymap.set('v', '<M-F>', function() vim.lsp.buf.format() end)

vim.cmd.colorscheme('catppuccin-macchiato')
