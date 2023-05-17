
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



return require 'neoconf'.get("nvim.map", map);
