return {
	'nvim-tree/nvim-web-devicons',
	'MunifTanjim/nui.nvim',
	{
		'nvim-neo-tree/neo-tree.nvim',
		opts = function() return require 'plugins.config.neotree' end,
		event = "VimEnter",
	},
}
