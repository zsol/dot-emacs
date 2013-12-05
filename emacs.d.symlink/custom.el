(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(compilation-scroll-output (quote first-error))
 '(custom-enabled-themes (quote (solarized-dark)))
 '(custom-safe-themes (quote ("1e7e097ec8cb1f8c3a912d7e1e0331caeed49fef6cff220be63bd2a6ba4cc365" "fc5fcb6f1f1c1bc01305694c59a1a861b008c534cae8d0e48e4d5e81ad718bc6" "e9143042f8b9a18cb44042e61c8c0d9da0e033b01d26f2a176c7fe9204476a4d" default)))
 '(custom-theme-load-path (quote ("~/.emacs.d/emacs-color-theme-solarized" custom-theme-directory t)))
 '(flymake-log-level 0)
 '(flymake-no-changes-timeout 1)
 '(global-whitespace-mode t)
 '(grep-command "ag --nogroup --column -S ")
 '(haskell-check-command "hlint")
 '(haskell-mode-hook (quote (turn-on-haskell-indent turn-on-font-lock turn-on-haskell-doc-mode (lambda nil (run-hooks (quote prelude-haskell-mode-hook))) (lambda nil (ghc-init) (flymake-mode)))))
 '(helm-c-default-external-file-browser "open")
 '(helm-c-use-adaptative-sorting t)
 '(helm-command-prefix-key "C-<return>")
 '(inferior-lisp-program "sbcl")
 '(inhibit-startup-screen t)
 '(js-indent-level 2)
 '(org-agenda-files (quote ("~/Dropbox/todo.org")))
 '(package-archives (quote (("marmalade" . "http://marmalade-repo.org/packages/") ("melpa" . "http://melpa.milkbox.net/packages/"))))
 '(python-pep8-command "/usr/local/bin/pep8")
 '(python-pep8-options (quote ("--ignore=E501" "--repeat")))
 '(python-pylint-command "~/.virtualenvs/env-prezi.dev/bin/pylint")
 '(ruby-deep-arglist nil)
 '(ruby-deep-indent-paren nil)
 '(safe-local-variable-values (quote ((ftf-filetypes "*") (ftf-filetypes quote ("*")) (ftf-filetypes ((quote "**"))) (ftf-filetypes ("**")) (ftf-filetypes (quote ("**"))) (ftf-filetypes ("*")) (ftf-filetypes (quote ("*"))) (virtualenv-workon . "env-prezi.dev") (encoding . utf-8))))
 '(server-auth-dir "~/.emacs.d/serverauth/")
 '(tramp-auto-save-directory "/tmp/tramp.autosave")
 '(uniquify-buffer-name-style (quote forward) nil (uniquify))
 '(vc-follow-symlinks t)
 '(whitespace-action (quote (cleanup warn-if-read-only)))
 '(whitespace-style (quote (face trailing tabs))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:inherit nil :stipple nil :background nil :foreground nil :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 100 :width normal :foundry "apple" :family "Monaco"))))
 '(diff-file-header ((((class color) (min-colors 88) (background dark)) (:background "#222" :weight bold))))
 '(diff-header ((((class color) (min-colors 88) (background dark)) (:background "#222"))))
 '(helm-grep-match ((t (:inherit match :background "darkblue"))) t)
 '(helm-selection ((t (:background "ForestGreen" :foreground "black" :underline t))) t)
 '(helm-selection-line ((t (:background "darkred" :underline t))) t)
 '(mumamo-background-chunk-major ((t (:background "controlDarkShadowColor"))) t)
 '(mumamo-background-chunk-submode1 ((t nil)) t)
 '(secondary-selection ((t (:background "dark red")))))
