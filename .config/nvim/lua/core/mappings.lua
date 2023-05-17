
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


return require 'neoconf'.get("nvim.map", map);
