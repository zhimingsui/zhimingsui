(load (expand-file-name "~/.quicklisp/slime-helper.el"))
(setq inferior-lisp-program "sbcl")

;; cmd to meta
(setq mac-option-key-is-meta nil)
(setq mac-command-key-is-meta t)
(setq mac-command-modifier 'meta)
(setq mac-option-modifier nil)

(add-to-list 'custom-theme-load-path (concat (getenv "XDG_CONFIG_HOME") "/emacs/themes"))
(load-theme 'catppuccin t)








