-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Ships with omarchy-nvim; this file replaces Omarchy's own options.lua, which
-- is where the call normally lives. Without it, yank stops leaving the machine
-- over SSH and inside herdr panes (OSC52).
pcall(function()
  require("config.remote_clipboard").setup()
end)

vim.g.maplocalleader = ";"
vim.env.PATH = vim.fn.stdpath("data") .. "/mason/bin:" .. vim.env.PATH
