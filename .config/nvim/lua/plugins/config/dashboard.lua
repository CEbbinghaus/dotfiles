return require 'neoconf'.get(
	"plugins.dashboard",
	{
		theme = "doom",
		config = {
			header = {
				"",
				"",
				"           ▄ ▄                   ",
				"       ▄   ▄▄▄     ▄ ▄▄▄ ▄ ▄     ",
				"       █ ▄ █▄█ ▄▄▄ █ █▄█ █ █     ",
				"    ▄▄ █▄█▄▄▄█ █▄█▄█▄▄█▄▄█ █     ",
				"  ▄ █▄▄█ ▄ ▄▄ ▄█ ▄▄▄▄▄▄▄▄▄▄▄▄▄▄  ",
				"  █▄▄▄▄ ▄▄▄ █ ▄ ▄▄▄ ▄ ▄▄▄ ▄ ▄ █ ▄",
				"▄ █ █▄█ █▄█ █ █ █▄█ █ █▄█ ▄▄▄ █ █",
				"█▄█ ▄ █▄▄█▄▄█ █ ▄▄█ █ ▄ █ █▄█▄█ █",
				"    █▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█ █▄█▄▄▄█    ",
				"",
				"",
			},
			center = {
				{
					icon = ' ',
					icon_hl = 'Title',
					desc = ' Find File  ',
					desc_hl = 'String',
					key = 'f',
					keymap = 'SPC f f',
					key_hl = 'Number',
					action = require('telescope.builtin').find_files
				},
				{
					icon = ' ',
					icon_hl = 'Title',
					desc = ' Open Session  ',
					desc_hl = 'String',
					key = 's',
					keymap = 'SPC s o',
					key_hl = 'Number',
					action = 'SessionManager load_session'
				},
				{
					icon = ' ',
					icon_hl = 'Title',
					desc = ' Bookmarks  ',
					desc_hl = 'String',
					key = 'b',
					keymap = 'SPC f b',
					key_hl = 'Number',
					action = require('telescope.builtin').marks
				},
			}
		}
	}
);
