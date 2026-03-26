;;; lsp.el --- LSP-Bridge configuration -*- lexical-binding: t; -*-

;; LSP-Bridge setup
(use-package! lsp-bridge
  :init
  ;; Ensure PATH and JAVA_HOME are set before lsp-bridge spawns Python
  (let ((home (getenv "HOME")))
    (setenv "PATH" (concat home "/lsp/bin:"
                           home "/.sdkman/candidates/java/current/bin:"
                           home "/.local/bin:"
                           (getenv "PATH")))
    (setenv "JAVA_HOME" (concat home "/.sdkman/candidates/java/current")))

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

  ;; Project root detection for monorepos
  ;;
  ;; Hard-configure roots per language by placing a .lsp-roots file
  ;; in your project (or any parent directory). Format:
  ;;
  ;;   java=/path/to/java/root
  ;;   ts=./relative/to/this/file
  ;;   svelte=./frontend
  ;;   *=/path/to/default/root
  ;;
  ;; Paths starting with ./ are relative to the .lsp-roots file location.
  ;; Use * as a catch-all for any language not explicitly listed.

  (defun +lsp-bridge/read-roots-file (roots-file)
    "Parse a .lsp-roots file into an alist of (lang . path)."
    (let ((roots-dir (file-name-directory roots-file))
          result)
      (with-temp-buffer
        (insert-file-contents roots-file)
        (goto-char (point-min))
        (while (not (eobp))
          (let ((line (string-trim (buffer-substring-no-properties
                                    (line-beginning-position) (line-end-position)))))
            (when (and (not (string-empty-p line))
                       (not (string-prefix-p "#" line))
                       (string-match "\\`\\([^=]+\\)=\\(.+\\)\\'" line))
              (let ((lang (match-string 1 line))
                    (path (match-string 2 line)))
                (when (string-prefix-p "./" path)
                  (setq path (expand-file-name path roots-dir)))
                (push (cons lang (directory-file-name (expand-file-name path))) result))))
          (forward-line 1)))
      (nreverse result)))

  (defun +lsp-bridge/find-roots-file (dir)
    "Find the nearest .lsp-roots file starting from DIR."
    (cl-loop for d = dir then (file-name-directory (directory-file-name d))
             while (and d (not (string= d "/")))
             for f = (expand-file-name ".lsp-roots" d)
             when (file-exists-p f) return f))

  (defun +lsp-bridge/ext-to-lang (ext)
    "Map file extension to language key for .lsp-roots lookup."
    (cond
     ((member ext '("java")) "java")
     ((member ext '("kt" "kts")) "kotlin")
     ((member ext '("ts" "tsx")) "ts")
     ((member ext '("js" "jsx")) "js")
     ((member ext '("svelte")) "svelte")
     ((member ext '("clj" "cljs" "cljc" "edn")) "clojure")
     ((member ext '("py")) "python")
     ((member ext '("lua")) "lua")
     ((member ext '("sh" "bash")) "sh")
     ((member ext '("zig")) "zig")
     ((member ext '("odin")) "odin")
     ((member ext '("json")) "json")
     ((member ext '("yaml" "yml")) "yaml")
     (t ext)))

  (setq lsp-bridge-get-project-path-by-user
        (lambda (filename)
          (let* ((dir (file-name-directory filename))
                 (ext (file-name-extension filename))
                 (lang (+lsp-bridge/ext-to-lang ext))
                 ;; 1. Check for .lsp-roots hard config
                 (roots-file (+lsp-bridge/find-roots-file dir))
                 (roots (when roots-file (+lsp-bridge/read-roots-file roots-file)))
                 (hard-root (or (cdr (assoc lang roots))
                                (cdr (assoc "*" roots)))))
            (if hard-root
                hard-root
              ;; 2. Fall back to nearest marker file detection
              (let ((markers (cond
                               ((member ext '("java" "kt" "kts"))
                                '("pom.xml" "build.gradle" "build.gradle.kts"))
                               ((member ext '("ts" "tsx" "js" "jsx" "svelte"))
                                '("package.json"))
                               ((member ext '("clj" "cljs" "cljc" "edn"))
                                '("deps.edn" "project.clj"))
                               (t nil))))
                (when markers
                  (cl-loop for d = dir then (file-name-directory (directory-file-name d))
                           while (and d (not (string= d "/")))
                           when (cl-some (lambda (m) (file-exists-p (expand-file-name m d))) markers)
                           return (directory-file-name d))))))))

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
