return {
	'b0o/schemastore.nvim',
	"folke/neodev.nvim",
	"b0o/schemastore.nvim",
	"L3MON4D3/LuaSnip",
	{
		'VonHeikemen/lsp-zero.nvim',
		branch = 'v2.x',
		cmd = "LspZeroFormat",
		dependencies = {
			'neovim/nvim-lspconfig',

			{
				"williamboman/mason-lspconfig.nvim",
				cmd = { "LspInstall", "LspUninstall" },
			},
			-- Autocompletion
			{
				'hrsh7th/nvim-cmp',
				event = 'InsertEnter',
				opts = function()
					return require 'plugins.config.cmp'
				end,
				dependencies =
				{
					"hrsh7th/cmp-nvim-lsp",
					"saadparwaiz1/cmp_luasnip",
					"hrsh7th/cmp-buffer"
				}
			},
		}
	}

}
