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
                 . ("lua-language-server")))

  ;; Kotlin — kotlin-lsp
  (add-to-list 'eglot-server-programs
               '((kotlin-mode kotlin-ts-mode)
                 . ("kotlin-lsp" "--stdio")))

  ;; Svelte — svelte-language-server
  (add-to-list 'eglot-server-programs
               '(svelte-mode . ("svelteserver" "--stdio")))

  ;; Odin — ols
  (add-to-list 'eglot-server-programs
               '(odin-mode . ("ols")))

  ;; Java — jdtls (use our installed version)
  (add-to-list 'eglot-server-programs
               `((java-mode java-ts-mode) . ("jdtls"
                                              "-data" ,(expand-file-name "java-workspace" doom-profile-data-dir)))))

;; Configure jdtls to use Eclipse formatter config from project .vscode/ directory
(defun +java/jdtls-settings ()
  "Return jdtls workspace settings, using formatter config from .vscode/ if found."
  (let* ((root (project-root (project-current)))
         (formatter-config (expand-file-name ".vscode/java-formatter.xml" root)))
    (if (file-exists-p formatter-config)
        `(:java (:format (:settings (:url ,formatter-config)
                          :enabled t)))
      `(:java (:format (:enabled t))))))

(setq-default eglot-workspace-configuration #'+java/jdtls-settings)

;; Auto-start eglot for Java (Doom's java module only does this for lsp-mode)
(add-hook 'java-mode-local-vars-hook #'eglot-ensure)
(add-hook 'java-ts-mode-local-vars-hook #'eglot-ensure)

;; Formatter configuration (for Doom's +format module)
(after! format-all
  ;; Languages where the LSP provides formatting (eglot handles it):
  ;; Java (jdtls), Zig (zls), Clojure (clojure-lsp), Kotlin (kotlin-lsp)

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
             svelte-mode))

  ;; Java — use eglot/jdtls formatting (reads Eclipse formatter config from .vscode/)
  (set-formatter! 'eglot-java
    '(eglot-format-buffer)
    :modes '(java-mode java-ts-mode)))
