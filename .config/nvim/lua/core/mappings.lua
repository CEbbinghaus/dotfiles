
local map = {n = {}, i = {}, v = {}, t = {}}
-- WhichKey keybinds https://github.com/folke/which-key.nvim


-- Neotree Keybinds to open & close neotree
map.n["<leader>b"] = { "<cmd>Neotree toggle<cr>", "Toggle File Explorer" } 
map.n["<leader>o"] = {
	function()
      if vim.bo.filetype == "neo-tree" then
        vim.cmd.wincmd "p"
      else
        vim.cmd.Neotree "focus"
      end
    end, "Focus File Explorer" } 


local builtin = require('telescope.builtin')
map.n['<leader>f'] = { desc = "󰍉 Fuzzy Finder" }
map.n['<leader>ff'] = { builtin.find_files, "Find Files" }
map.n['<leader>fg'] = { builtin.live_grep, "Live Grep" }
map.n['<leader>fb'] = { builtin.buffers, "Find Buffer" }
map.n['<leader>fh'] = { builtin.help_tags, "Help Tags" }
map.n['<leader>fo'] = { builtin.oldfiles, "Recent Files" }


map.n['<leader>s'] = { desc = "  Session" }
map.n['<leader>so'] = { "<cmd>SessionManager load_session<cr>", "Load Session" }
map.n['<leader>ss'] = { "<cmd>SessionManager save_current_session<cr>", "Save Session" }

return require 'neoconf'.get("nvim.map", map);
