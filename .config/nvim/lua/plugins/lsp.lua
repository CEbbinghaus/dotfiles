vim.o.foldcolumn = '1' -- '0' is not bad
vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
vim.o.foldlevelstart = 99
vim.o.foldenable = true

return {
	{
		'neovim/nvim-lspconfig',
		config = function()
			require 'neoconf'.setup()
			require 'plugins.config.lspconfig'
		end,
		event = "BufAdd",
		dependencies =
		{
			-- { "folke/neoconf.nvim", cmd = "Neoconf", config = true },
			'folke/neodev.nvim',
			'b0o/schemastore.nvim',
			{
				"williamboman/mason-lspconfig.nvim",
				cmd = { "LspInstall", "LspUninstall" },
				config = true,
				dependencies =
				{
					{
						'williamboman/mason.nvim',
						build = ':MasonUpdate',
						config = true,
					}
				}
			},
			{
				'hrsh7th/nvim-cmp',
				event = { 'InsertEnter', 'BufAdd' },
				opts = function()
					return require 'plugins.config.cmp'
				end,
				dependencies =
				{
					"hrsh7th/cmp-buffer",
					"hrsh7th/cmp-nvim-lsp",
					"saadparwaiz1/cmp_luasnip",
					"L3MON4D3/LuaSnip",
				}
			},
			{
				'kevinhwang91/nvim-ufo',
				dependencies =
				{
					'kevinhwang91/promise-async'
				}
			}
		}
	}
}
