;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `with-eval-after-load' block, otherwise Doom's defaults may override your
;; settings. E.g.
;;
;;   (with-eval-after-load 'PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look them up).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

;; Ensure ~/lsp/bin and SDKMAN are on PATH (for desktop-launched Emacs)
(let ((home (getenv "HOME")))
  (setenv "PATH" (concat home "/lsp/bin:"
                         home "/.sdkman/candidates/java/current/bin:"
                         home "/.local/bin:"
                         (getenv "PATH")))
  (dolist (dir (list (concat home "/lsp/bin")
                     (concat home "/.sdkman/candidates/java/current/bin")
                     (concat home "/.local/bin")))
    (add-to-list 'exec-path dir))
  (setenv "JAVA_HOME" (concat home "/.sdkman/candidates/java/current")))

;; Tree-sitter grammar sources and auto-install
(setq treesit-language-source-alist
      '((typescript "https://github.com/tree-sitter/tree-sitter-typescript" "master" "typescript/src")
        (tsx        "https://github.com/tree-sitter/tree-sitter-typescript" "master" "tsx/src")
        (javascript "https://github.com/tree-sitter/tree-sitter-javascript")
        (python     "https://github.com/tree-sitter/tree-sitter-python")
        (json       "https://github.com/tree-sitter/tree-sitter-json")
        (yaml       "https://github.com/tree-sitter/tree-sitter-yaml")
        (bash       "https://github.com/tree-sitter/tree-sitter-bash" "v0.23.3")
        (lua        "https://github.com/tree-sitter-grammars/tree-sitter-lua")
        (java       "https://github.com/tree-sitter/tree-sitter-java")
        (kotlin     "https://github.com/fwcd/tree-sitter-kotlin")
        (clojure    "https://github.com/sogaiu/tree-sitter-clojure")
        (markdown   "https://github.com/tree-sitter-grammars/tree-sitter-markdown" "v0.4.1" "tree-sitter-markdown/src")
        (markdown-inline "https://github.com/tree-sitter-grammars/tree-sitter-markdown" "v0.4.1" "tree-sitter-markdown-inline/src")))

(defun +treesit/install-all-grammars ()
  "Install any missing or incompatible tree-sitter grammars."
  (dolist (grammar treesit-language-source-alist)
    (let ((lang (car grammar)))
      (unless (ignore-errors (treesit-language-available-p lang t))
        (message "Installing tree-sitter grammar: %s" lang)
        (treesit-install-language-grammar lang)))))

;; Auto-install missing grammars on startup
(add-hook 'doom-after-init-hook #'+treesit/install-all-grammars)

;; Load LSP configuration
(load! "lsp")
