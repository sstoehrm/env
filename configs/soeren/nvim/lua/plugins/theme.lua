-- Named theme.lua on purpose.
--
-- Omarchy ships ~/.config/nvim/lua/plugins/theme.lua as a symlink to
-- ~/.local/state/omarchy/current/theme/neovim.lua, which omarchy-theme-set
-- regenerates on every theme switch and which pins colorscheme = "aether".
-- lazy.nvim merges specs for the same plugin in filename order, so a file
-- named colorscheme.lua would always lose to theme.lua and this pin would
-- silently never apply.
--
-- Deploying a real file at this path replaces that symlink: Omarchy keeps
-- writing neovim.lua under ~/.local/state, nothing reads it any more, and
-- carbonfox wins both at startup and through omarchy-theme-hotreload.lua,
-- which re-reads this same plugins.theme module on LazyReload.
--
-- omarchy-nvim-refresh and omarchy-reinstall-configs recreate the symlink
-- (ln -snf), so re-run the configs tag after either of those.
return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "carbonfox",
    },
  },
}
