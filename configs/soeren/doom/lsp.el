;;; lsp.el --- Eglot LSP configuration -*- lexical-binding: t; -*-

;; Configure eglot server programs for languages not handled by Doom's +lsp
(with-eval-after-load 'eglot

  ;; Kotlin — JetBrains kotlin-lsp (not the community kotlin-language-server)
  (add-to-list 'eglot-server-programs
               '((kotlin-mode kotlin-ts-mode) . ("kotlin-lsp" "--stdio")))

  ;; Svelte — svelte-language-server
  (add-to-list 'eglot-server-programs
               '((svelte-ts-mode :language-id "svelte") .
                 ("svelteserver" "--stdio"))))

  ;; Odin — ols (built into eglot on Emacs 30+)
  ;; No custom entry needed: eglot already has ((odin-mode odin-ts-mode) . ("ols"))

;; Auto-start eglot for modes without built-in Doom +lsp hooks
(add-hook 'kotlin-mode-local-vars-hook #'lsp!)
(add-hook 'kotlin-ts-mode-local-vars-hook #'lsp!)
(add-hook 'svelte-ts-mode-hook #'eglot-ensure)
(add-hook 'odin-mode-hook #'eglot-ensure)

;; Formatter configuration — use apheleia directly
(after! apheleia
  ;; Svelte — map svelte-ts-mode to apheleia's built-in prettier-svelte
  (setf (alist-get 'svelte-ts-mode apheleia-mode-alist) '(prettier-svelte))

  ;; Odin — odinfmt (reads stdin, writes stdout)
  (setf (alist-get 'odinfmt apheleia-formatters)
        '("odinfmt" "-stdin"))
  (setf (alist-get 'odin-mode apheleia-mode-alist) '(odinfmt))

  ;; Python — black
  (setf (alist-get 'python-mode apheleia-mode-alist) '(black))
  (setf (alist-get 'python-ts-mode apheleia-mode-alist) '(black))

  ;; Lua — stylua
  (setf (alist-get 'stylua apheleia-formatters)
        '("stylua" "-"))
  (setf (alist-get 'lua-mode apheleia-mode-alist) '(stylua))
  (setf (alist-get 'lua-ts-mode apheleia-mode-alist) '(stylua))

  ;; Shell — shfmt with custom args
  (setf (alist-get 'shfmt apheleia-formatters)
        '("shfmt" "-i" "2" "-ci"))
  (setf (alist-get 'sh-mode apheleia-mode-alist) '(shfmt))
  (setf (alist-get 'bash-ts-mode apheleia-mode-alist) '(shfmt))

  ;; JS/TS/JSON/YAML/Markdown — prettier (apheleia has built-in mappings,
  ;; but ensure ts-modes are covered)
  (setf (alist-get 'js-ts-mode apheleia-mode-alist) '(prettier-javascript))
  (setf (alist-get 'tsx-ts-mode apheleia-mode-alist) '(prettier-typescript))
  (setf (alist-get 'typescript-ts-mode apheleia-mode-alist) '(prettier-typescript))
  (setf (alist-get 'json-ts-mode apheleia-mode-alist) '(prettier-json))
  (setf (alist-get 'yaml-ts-mode apheleia-mode-alist) '(prettier-yaml)))
