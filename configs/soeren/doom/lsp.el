;;; lsp.el --- Eglot multi-LSP configuration -*- lexical-binding: t; -*-

;; JavaScript/TypeScript — typescript-language-server
(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs
               '((js-mode js-ts-mode tsx-ts-mode typescript-ts-mode typescript-mode)
                 . ("typescript-language-server" "--stdio")))

  ;; Python — pyright
  (add-to-list 'eglot-server-programs
               '((python-mode python-ts-mode)
                 . ("pyright-langserver" "--stdio")))

  ;; Shell — bash-language-server
  (add-to-list 'eglot-server-programs
               '((sh-mode bash-ts-mode)
                 . ("bash-language-server" "start")))

  ;; Zig — zls
  (add-to-list 'eglot-server-programs
               '((zig-mode zig-ts-mode)
                 . ("zls")))

  ;; Clojure — clojure-lsp
  (add-to-list 'eglot-server-programs
               '((clojure-mode clojurescript-mode clojurec-mode)
                 . ("clojure-lsp")))

  ;; Lua — lua-language-server
  (add-to-list 'eglot-server-programs
               '((lua-mode lua-ts-mode)
                 . ("lua-language-server"))))
