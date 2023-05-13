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

require("lazy").setup({
	-- Theme
	{ "catppuccin/nvim",                 name = "catppuccin" },
	-- Saves last location
	"ethanholz/nvim-lastplace",
	-- Syntax Highlighting
	{ 'nvim-treesitter/nvim-treesitter', build = ':TSUpdate' },
	-- Mason is a automatic LSP,DAP,linter installer
	-- :MasonUpdate updates registry contents:
	{ 'williamboman/mason.nvim',         build = ':MasonUpdate' },
	-- LSP config
	{
		'VonHeikemen/lsp-zero.nvim',
		branch = 'v2.x',
		dependencies = {
			-- LSP Support
			{ 'neovim/nvim-lspconfig' }, -- Required
			{
				-- Optional
				'williamboman/mason.nvim',
				build = function()
					pcall(vim.cmd, 'MasonUpdate')
				end,
			},
			{ 'williamboman/mason-lspconfig.nvim' }, -- Optional

			-- Autocompletion
			{ 'hrsh7th/nvim-cmp' }, -- Required
			{ 'hrsh7th/cmp-nvim-lsp' }, -- Required
			{ 'L3MON4D3/LuaSnip' }, -- Required
		}
	},

	-- File Browser
	'nvim-lua/plenary.nvim',
	'nvim-tree/nvim-web-devicons',
	'MunifTanjim/nui.nvim',
	'nvim-neo-tree/neo-tree.nvim',

	-- Git blame per line
	'f-person/git-blame.nvim',

	-- Telescope fzf
	{ 'nvim-telescope/telescope.nvim', tag = '0.1.1' }
})

vim.keymap.set('n', '<C-b>', '<Cmd>Neotree toggle<CR>')

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<Leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<Leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<Leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<Leader>fh', builtin.help_tags, {})

vim.cmd.colorscheme('catppuccin-macchiato')

local lsp = require('lsp-zero').preset({})

-- Setting up lspconfig with lua_ls https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/tutorial.md
require('lspconfig').lua_ls.setup(lsp.nvim_lua_ls())

lsp.on_attach(function(client, bufnr)
	lsp.default_keymaps({ buffer = bufnr })
end)

lsp.setup()
