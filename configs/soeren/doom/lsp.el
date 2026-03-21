;;; lsp.el --- LSP-Bridge configuration -*- lexical-binding: t; -*-

;; LSP-Bridge setup
(use-package! lsp-bridge
  :init
  ;; Ensure PATH is set before lsp-bridge spawns Python
  (let ((home (getenv "HOME")))
    (setenv "PATH" (concat home "/lsp/bin:"
                           home "/.sdkman/candidates/java/current/bin:"
                           home "/.local/bin:"
                           (getenv "PATH"))))

  ;; Set all lsp-bridge variables before it loads
  (setq lsp-bridge-python-command (expand-file-name "~/.emacs-venv/bin/python")
        lsp-bridge-user-langserver-dir (expand-file-name "langserver" doom-user-dir)
        lsp-bridge-user-multiserver-dir (expand-file-name "multiserver" doom-user-dir)
        lsp-bridge-python-lsp-server "pyright"
        lsp-bridge-multi-lang-server-extension-list
        '((("ts" "tsx" "jsx") . "typescript_tailwindcss")
          (("svelte") . "svelte_tailwindcss")))

  :config
  (setq lsp-bridge-enable-completion-in-string t
        lsp-bridge-enable-diagnostics t
        lsp-bridge-enable-signature-help t
        lsp-bridge-enable-inlay-hint t
        lsp-bridge-enable-auto-format-code nil) ;; We use Doom's +format module

  ;; Enable globally
  (global-lsp-bridge-mode))

;; Formatter configuration (for Doom's +format module)
(after! format-all
  ;; Python — black
  (set-formatter! 'black "black -q -" :modes '(python-mode python-ts-mode))

  ;; Lua — stylua
  (set-formatter! 'stylua "stylua -" :modes '(lua-mode lua-ts-mode))

  ;; Shell — shfmt
  (set-formatter! 'shfmt "shfmt -i 2 -ci" :modes '(sh-mode bash-ts-mode))

  ;; JS/TS/JSON/YAML/Markdown/Svelte — prettier
  (set-formatter! 'prettier
    '("prettier" "--stdin-filepath" filepath)
    :modes '(js-mode js-ts-mode tsx-ts-mode typescript-ts-mode typescript-mode
             json-mode json-ts-mode
             yaml-mode yaml-ts-mode
             markdown-mode gfm-mode
             svelte-mode)))
