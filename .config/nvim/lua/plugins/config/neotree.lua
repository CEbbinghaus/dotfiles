-- Retrieves the fileName, Extension and wether its a dotfile/folder
local function GetFileNameAndExtension(path)
	local fileName = path:match("^.*[/\\](.+)$") or ""

	if fileName == nil then
		print("FileName was nil. Path was: " .. path)
		return
	end

	local dotIndex = fileName:find(".", 1, true)

	-- There is no dot. There is only a file name
	if dotIndex == nil then
		return fileName, nil, false
	end

	local name, ext = fileName:match("(.*)%.(.*)$")

	-- There is a dot in the beginning. its a dotfile
	return name, ext, dotIndex == 1
end

-- Sort the files in the editor
-- This should be in the order of:
-- -d- .dirname
-- -d- dirname
-- f-- .filename
-- f-- filename
-- f-- filename.ext
local function SortFiles(a, b)
	-- directories should be listed first
	if a.type ~= b.type then
		return a.type < b.type
	end

	local fileNameA, fileExtensionA, isDotFileA = GetFileNameAndExtension(a.path:lower())
	local fileNameB, fileExtensionB, isDotFileB = GetFileNameAndExtension(b.path:lower())

	-- dotfiles/folders should be listed first alphhabetically
	if isDotFileA ~= isDotFileB then
		assert(type(isDotFileA) == "boolean", "isDotFileA should be a bool")
		assert(type(isDotFileB) == "boolean", "isDotFileB should be a bool")
		-- little shorthand since if its not A its B
		return isDotFileA
	end

	-- sort any dotfiles alphabetically
	if isDotFileA or isDotFileB then
		return a.path > b.path
	end

	-- We want to move files without extensions to the top above the rest.
	if fileExtensionA == nil or fileExtensionB == nil then
		-- we still have to sort files/folders without extensions alphabetically
		if fileExtensionA == fileExtensionB then
			return fileNameA < fileNameB
		end
		-- Another shorthand since if A isn't nil then its B
		return fileExtensionA == nil
	end

	-- If the extensions don't match we want to sort by extension
	if fileExtensionA ~= fileExtensionB then
		return fileExtensionA < fileExtensionB
	end

	-- Lastly we sort by the path
	return a.path > b.path
end

-- return require 'neoconf'.get(
--	"plugins.neotree",
return {
	close_if_last_window = true, -- Close Neo-tree if it is the last window left in the tab
	popup_border_style = "rounded",
	enable_git_status = true,
	enable_diagnostics = false,
	open_files_do_not_replace_types = { "terminal", "trouble", "qf" }, -- when opening files, do not use windows containing these filetypes or buftypes

	-- For the tabs at the top of the file picker
	source_selector = {
		winbar = true,
		content_layout = "center",
		tabs_layout = "equal", -- active
		show_scrolled_off_parent_node = true
	},
	sort_function = SortFiles, -- Custom sorting function
	default_component_configs = {
		container = {
			enable_character_fade = true
		},
		indent = {
			indent_size = 2,
			padding = 1, -- extra padding on left hand side
			-- indent guides
			with_markers = true,
			indent_marker = "│",
			last_indent_marker = "└",
			highlight = "NeoTreeIndentMarker",
			-- expander config, needed for nesting files
			with_expanders = nil, -- if nil and file nesting is enabled, will enable expanders
			expander_collapsed = "",
			expander_expanded = "",
			expander_highlight = "NeoTreeExpander",
		},
		icon = {
			-- folder_closed = "",
			-- folder_closed = "",
			folder_closed = "",
			-- folder_open = "",
			-- folder_open = "",
			folder_open = "",
			-- folder_empty = "ﰊ",
			-- folder_empty = "",
			folder_empty = "",
			default = "",
			highlight = "NeoTreeFileIcon"
		},
		modified = {
			symbol = "",
			highlight = "NeoTreeModified",
		},
		name = {
			trailing_slash = true,
			use_git_status_colors = true,
			highlight = "NeoTreeFileName",
		},
		git_status = {
			symbols = {
				-- Change type
				added     = "", -- or "✚", but this is redundant info if you use git_status_colors on the name
				modified  = "", -- or "", but this is redundant info if you use git_status_colors on the name
				deleted   = "✖", -- this can only be used in the git_status source
				renamed   = "", -- this can only be used in the git_status source
				-- Status type
				untracked = "",
				ignored   = "",
				unstaged  = "",
				staged    = "",
				conflict  = "",
			}
		},
	},
	-- A list of functions, each representing a global custom command
	-- that will be available in all sources (if not overridden in `opts[source_name].commands`)
	-- see `:h neo-tree-global-custom-commands`
	commands = {},
	window = {
		-- when set to "float" it will hover over the text buffer when its open
		position = "left",
		popup = {
			size = {
				height = "100%",
				width = "25%"
			},
			position = "0%",
			border = "shadow"
		},
		width = 40,
		mapping_options = {
			noremap = true,
			nowait = true,
		},
		mappings = {
			["<space>"] = {
				"toggle_node",
				nowait = false, -- disable `nowait` if you have existing combos starting with this char that you want to use
			},
			["<2-LeftMouse>"] = "open",
			["<cr>"] = "open",
			["<esc>"] = "revert_preview",
			["P"] = { "toggle_preview", config = { use_float = true } },
			["l"] = "focus_preview",
			["S"] = "open_split",
			["s"] = "open_vsplit",
			-- ["S"] = "split_with_window_picker",
			-- ["s"] = "vsplit_with_window_picker",
			["t"] = "open_tabnew",
			-- ["<cr>"] = "open_drop",
			-- ["t"] = "open_tab_drop",
			["w"] = "open_with_window_picker",
			--["P"] = "toggle_preview", -- enter preview mode, which shows the current node without focusing
			["C"] = "close_node",
			-- ['C'] = 'close_all_subnodes',
			["z"] = "close_all_nodes",
			--["Z"] = "expand_all_nodes",
			["n"] = {
				"add",
				-- this command supports BASH style brace expansion ("x{a,b,c}" -> xa,xb,xc). see `:h neo-tree-file-actions` for details
				-- some commands may take optional config options, see `:h neo-tree-mappings` for details
				config = {
					show_path = "none" -- "none", "relative", "absolute"
				}
			},
			["N"] = "add_directory", -- also accepts the optional config.show_path option like "add". this also supports BASH style brace expansion.
			["d"] = "delete",
			["r"] = "rename",
			["y"] = "copy_to_clipboard",
			["x"] = "cut_to_clipboard",
			["p"] = "paste_from_clipboard",
			["c"] = "copy", -- takes text input for destination, also accepts the optional config.show_path option like "add":
			-- ["c"] = {
			--  "copy",
			--  config = {
			--    show_path = "none" -- "none", "relative", "absolute"
			--  }
			--}
			["m"] = "move", -- takes text input for destination, also accepts the optional config.show_path option like "add".
			["q"] = "close_window",
			["R"] = "refresh",
			["?"] = "show_help",
			["<"] = "prev_source",
			[">"] = "next_source",
		}
	},
	nesting_rules = {},
	filesystem = {
		filtered_items = {
			visible = false, -- when true, they will just be displayed differently than normal items
			hide_dotfiles = true,
			hide_gitignored = true,
			hide_hidden = true, -- only works on Windows for hidden files/directories
			hide_by_name = {
				-- "node_modules"
			},
			hide_by_pattern = { -- uses glob style patterns
				--"*.meta",
				--"*/src/*/tsconfig.json",
			},
			always_show = { -- remains visible even if other settings would normally hide it
				--".gitignored",
			},
			never_show = { -- remains hidden even if visible is toggled to true, this overrides always_show
				".DS_Store",
				"thumbs.db",
				"node_modules",
				".git"
			},
			never_show_by_pattern = { -- uses glob style patterns
				--".null-ls_*",
			},
		},
		follow_current_file = true,        -- This will find and focus the file in the active buffer every
		-- time the current file is changed while the tree is open.
		group_empty_dirs = false,          -- when true, empty folders will be grouped together
		hijack_netrw_behavior = "open_default", -- netrw disabled, opening a directory opens neo-tree
		-- in whatever position is specified in window.position
		-- "open_current",  -- netrw disabled, opening a directory opens within the
		-- window like netrw would, regardless of window.position
		-- "disabled",    -- netrw left alone, neo-tree does not handle opening dirs
		use_libuv_file_watcher = false, -- This will use the OS level file watchers to detect changes
		-- instead of relying on nvim autocmd events.
		window = {
			mappings = {
				["<bs>"] = "navigate_up",
				["."] = "set_root",
				["H"] = "toggle_hidden",
				["/"] = "fuzzy_finder",
				["D"] = "fuzzy_finder_directory",
				["#"] = "fuzzy_sorter", -- fuzzy sorting using the fzy algorithm
				-- ["D"] = "fuzzy_sorter_directory",
				["f"] = "filter_on_submit",
				["<c-x>"] = "clear_filter",
				["[g"] = "prev_git_modified",
				["]g"] = "next_git_modified",
			},
			fuzzy_finder_mappings = {
				-- define keymaps for filter popup window in fuzzy_finder_mode
				["<down>"] = "move_cursor_down",
				["<C-n>"] = "move_cursor_down",
				["<up>"] = "move_cursor_up",
				["<C-p>"] = "move_cursor_up",
			},
		},

		commands = {} -- Add a custom command or override a global one using the same function name
	},
	buffers = {
		follow_current_file = true, -- This will find and focus the file in the active buffer every
		-- time the current file is changed while the tree is open.
		group_empty_dirs = true, -- when true, empty folders will be grouped together
		show_unloaded = true,
		window = {
			mappings = {
				["bd"] = "buffer_delete",
				["<bs>"] = "navigate_up",
				["."] = "set_root",
			}
		},
	},
	git_status = {
		window = {
			position = "float",
			mappings = {
				["A"]  = "git_add_all",
				["gu"] = "git_unstage_file",
				["ga"] = "git_add_file",
				["gr"] = "git_revert_file",
				["gc"] = "git_commit",
				["gp"] = "git_push",
				["gg"] = "git_commit_and_push",
			}
		}
	}
}
--);
