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
	{
		"catppuccin/nvim",
		name = "catppuccin",
		lazy = false,
		priority = 1000
	},
	-- global dependencies
	{
		"folke/neoconf.nvim",
		lazy = false,
		priority = 999,
		config = function(_, opts)
			require 'neoconf'.setup(opts)
		end
	},
	{
		'nvim-lua/plenary.nvim',
		lazy = false
	},
	{
		'glepnir/dashboard-nvim',
		event = 'VimEnter',
		opts = function() return require 'plugins.config.dashboard' end,
		dependencies = { { 'nvim-tree/nvim-web-devicons' } }
	},
	-- Saves last location
	{
		"ethanholz/nvim-lastplace",
		event = "BufAdd"
	},
	-- Syntax Highlighting
	{
		'nvim-treesitter/nvim-treesitter',
		build = ':TSUpdate',
		config = function()
			return require 'nvim-treesitter.configs'.setup(require 'plugins.config.treesitter')
		end,
		cmd = {"TSUpdate", "TSInstall"},
		event = "BufAdd"
	},
	-- Mason is a automatic LSP,DAP,linter installer
	-- :MasonUpdate updates registry contents:
	{
		'williamboman/mason.nvim',
		build = ':MasonUpdate',
		cmd = "MasonUpdate"
	},
	{ import = "plugins" },

	-- Git blame per line
	'f-person/git-blame.nvim',

	{
		'Shatur/neovim-session-manager',
		cmd = "SessionManager"
	}
}, require 'plugins.config.lazy')

vim.cmd([[ let g:neo_tree_remove_legacy_commands = 1 ]])

-- Configure neoconf before anything else
require 'neoconf'.setup {}

vim.keymap.set('n', '<C-b>', '<Cmd>Neotree toggle<CR>')
vim.keymap.set('n', '<M-F>', '<cmd>LspZeroFormat<cr>')
vim.keymap.set('i', '<M-F>', '<cmd>LspZeroFormat<cr>')
vim.keymap.set('v', '<M-F>', '<cmd>LspZeroFormat<cr>')

vim.cmd.colorscheme('catppuccin-macchiato')

require 'neodev'.setup {}

local lsp = require('lsp-zero').preset({})

-- Setting up lspconfig with lua_ls https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/tutorial.md
local lspconfig = require('lspconfig')
lspconfig.lua_ls.setup(lsp.nvim_lua_ls())

local schemastore = require 'schemastore'
lspconfig.jsonls.setup {
	settings = {
		json = {
			schemas = schemastore.json.schemas(),
			validate = { enable = true },
		},
	},
}

lspconfig.yamlls.setup {
	settings = {
		yaml = {
			schemas = schemastore.yaml.schemas(),
		},
	},
}

lsp.on_attach(function(client, bufnr)
	lsp.default_keymaps({ buffer = bufnr })
end)

require('mason-lspconfig').setup_handlers({
	function(server)
		lspconfig[server].setup({ capabilities = require('cmp_nvim_lsp').default_capabilities() })
	end,
})

lsp.setup()
lsp.setup()
