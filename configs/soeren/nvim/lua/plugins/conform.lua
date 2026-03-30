-- In ~/.config/nvim/lua/plugins/conform.lua
return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "black" },
        javascript = { "prettier" },
        typescript = { "prettier" },
        json = { "prettier" },
        yaml = { "prettier" },
        markdown = { "prettier" },
        sh = { "shfmt" },
        clojure = { "zprint" },
        clojurescript = { "zprint" },
        cljc = { "zprint" },
        edn = { "zprint" },
        bb = { "zprint" },
        -- add your languages here
      },
    },
  },
}
