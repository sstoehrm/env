return {
  "gpanders/nvim-parinfer",
  ft = {
    "clojure",
    "clojurescript",
    "cljc",
    "scheme",
    "lisp",
    "racket",
    "hy",
    "fennel",
    "janet",
    "carp",
    "wast",
    "yuck",
    "dune",
    "edn",
    "bb",
  },
  config = function()
    -- Optional configuration
    -- vim.g.parinfer_mode = "paren" -- default mode (smart, indent, or paren)
    -- vim.g.parinfer_enabled = true -- enable by default
  end,
}
