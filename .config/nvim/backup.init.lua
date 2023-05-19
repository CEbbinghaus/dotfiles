-- Ensure Lazy is installed and avaliable
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

-- Do the rest

require("lazy").setup {
	'neovim/nvim-lspconfig',
	'hrsh7th/nvim-cmp',
	"hrsh7th/cmp-nvim-lsp",
}

local cmp = require 'cmp'

cmp.setup {
	enabled = function()
		return true
	end,
	view = {
		entries = { name = 'custom', selection_order = 'near_cursor' }
	},
	window = {
		completion = cmp.config.window.bordered(),
	},
	sources = {
		{name = "nvim_lsp"}
	},
	formatting = {
		format = function(entry, vim_item)
			
			vim_item.kind = "TEST"
			return vim_item
		end
	}
}

local lspconfig = require 'lspconfig'

local capabilities = require('cmp_nvim_lsp').default_capabilities()

lspconfig.lua_ls.setup {
	capabilities = capabilities
}
