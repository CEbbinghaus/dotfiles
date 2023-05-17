return {
	defaults =
	{
		lazy = true,
	},
	performance = {
		rtp = {
			---@type string[] list any plugins you want to disable here
			disabled_plugins = {
				"netrwPlugin",
			},
		},
	},
}
