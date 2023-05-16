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
	-- global dependencies
	'nvim-lua/plenary.nvim',
	-- Theme
	{ "catppuccin/nvim",                 name = "catppuccin" },
	-- configuration manager for both global & local configurations
	"folke/neoconf.nvim",
	-- Saves last location
	"ethanholz/nvim-lastplace",
	-- Syntax Highlighting
	{ 'nvim-treesitter/nvim-treesitter', build = ':TSUpdate', opts = require 'plugins.config.treesitter' },
	-- Mason is a automatic LSP,DAP,linter installer
	-- :MasonUpdate updates registry contents:
	{ 'williamboman/mason.nvim',         build = ':MasonUpdate' },

	{ import = "plugins" },

	-- Git blame per line
	'f-person/git-blame.nvim',

})

vim.cmd([[ let g:neo_tree_remove_legacy_commands = 1 ]])

-- Configure neoconf before anything else
require 'neoconf'.setup{}

vim.keymap.set('n', '<C-b>', '<Cmd>Neotree toggle<CR>')

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<Leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<Leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<Leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<Leader>fh', builtin.help_tags, {})

vim.cmd.colorscheme('catppuccin-macchiato')

require 'neodev'.setup{}

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
		lspconfig[server].setup({})
	end,
})

lsp.setup()
