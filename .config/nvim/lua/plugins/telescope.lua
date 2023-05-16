return {

	{
		'nvim-telescope/telescope.nvim',
		tag = '0.1.1',
		opts = require 'plugins.config.telescope',
		config = function (_, opts)
			local telescope = require 'telescope';
			telescope.setup(opts);
			telescope.load_extension("ui-select");
		end,
		dependencies =
		{
			'nvim-telescope/telescope-ui-select.nvim'
		}
	}
}
