
return {
	'b0o/schemastore.nvim',
	"folke/neodev.nvim",
	"b0o/schemastore.nvim",
	{
		'VonHeikemen/lsp-zero.nvim',
		branch = 'v2.x',
		dependencies = {
			'neovim/nvim-lspconfig',

			{
				"williamboman/mason-lspconfig.nvim",
				cmd = { "LspInstall", "LspUninstall" },
			},

			-- Autocompletion
			{ 
				'hrsh7th/nvim-cmp',
				config = function()
					local cmp = require 'cmp'

					cmp.setup(require 'plugins.config.cmp'(cmp))
				end
			}, -- Required
			{ 'hrsh7th/cmp-nvim-lsp' }, -- Required
			{ 'L3MON4D3/LuaSnip' }, -- Required
		}
	}

}
