return {
	{
		"folke/which-key.nvim",
		config = function(plugin, table)
			vim.o.timeout = true
			vim.o.timeoutlen = 300
			local whichkey = require 'which-key'
			whichkey.setup(table)

			local mappings = require 'core.mappings'

			for mode, keys in pairs(mappings) do
				whichkey.register(keys, {mode = mode})
			end
		end,
		event = "VimEnter",
	},
}
