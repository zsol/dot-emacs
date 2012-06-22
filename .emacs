(setq exec-path (append exec-path '("$HOME/bin" "/usr/local/bin" "/usr/local/sbin")))
(defun chomp (str)
      "Chomp leading and tailing whitespace from STR."
      (while (string-match "\\`\n+\\|^\\s-+\\|\\s-+$\\|\n+\\'"
                           str)
        (setq str (replace-match "" t t str)))
      str)

(let ((path-string (chomp (shell-command-to-string "bash -c 'source ~/.bashrc; echo $PATH'"))))
  (setenv "PATH" path-string)
  (setq exec-path (parse-colon-path path-string)))

(let ((default-directory (concat user-emacs-directory
				 (convert-standard-filename "site-lisp/"))))
  (normal-top-level-add-subdirs-to-load-path))

(package-initialize)

(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)

(setq savehist-additional-variables
      ;; search entries
      '(search ring regexp-search-ring)
      ;; save every minute
      savehist-autosave-interval 60
      ;; keep the home clean
      savehist-file (concat user-emacs-directory "savehist"))
(savehist-mode t)

(setq recentf-save-file (concat user-emacs-directory "recentf")
      recentf-max-saved-items 200
      recentf-max-menu-items 15)
(recentf-mode t)

(global-hl-line-mode +1)

(require 'volatile-highlights)
(volatile-highlights-mode t)

(icomplete-mode +1)

;; (load-file (concat user-emacs-directory (convert-standard-filename "site-lisp/cedet/common/cedet.el")))
(global-ede-mode 1)
(semantic-mode 1)

(require 'uniquify)
(require 'ido)
(require 'yaml-mode)
(require 'json-mode)
(add-to-list 'auto-mode-alist '("\\.json" . json-mode))

(autoload 'haxe-mode "haxe-mode")
(add-to-list 'auto-mode-alist '("\\.hx" . haxe-mode))

(load (concat user-emacs-directory (convert-standard-filename "site-lisp/haskell-mode/haskell-site-file")))
(add-hook 'haskell-mode-hook 'turn-on-haskell-doc-mode)
(add-hook 'haskell-mode-hook 'turn-on-haskell-indentation)
(autoload 'ghc-init (concat user-emacs-directory (convert-standard-filename "site-lisp/ghc-mod/ghc.el")) nil t)
;; (add-hook 'haskell-mode-hook (lambda () (ghc-init) (flymake-mode)))

(define-key isearch-mode-map (kbd "C-o")
  (lambda ()
    (interactive)
    (let ((case-fold-search isearch-case-fold-search))
      (occur (if isearch-regexp isearch-string
               (regexp-quote isearch-string))))))

(add-hook 'after-save-hook
          'executable-make-buffer-file-executable-if-script-p)
(setq
 ediff-window-setup-function 'ediff-setup-windows-plain
 save-place-file (concat user-emacs-directory "places")
 backup-directory-alist `(("." . ,(concat user-emacs-directory "backups")))
 diff-switches "-u"
 whitespace-style '(face trailing lines-tail tabs))

(setq auto-save-file-name-transforms
      `((".*" ,temporary-file-directory t)))

(setq-default save-place t)
(require 'saveplace)
(require 'tramp)
(progn
  (eval-after-load 'ruby-mode
    '(progn
       ;; work around possible elpa bug
       (ignore-errors (require 'ruby-compilation))
       (setq ruby-use-encoding-map nil)
       (define-key ruby-mode-map (kbd "RET") 'reindent-then-newline-and-indent)
       (define-key ruby-mode-map (kbd "C-M-h") 'backward-kill-word)))
  (add-to-list 'auto-mode-alist '("\\.rake$" . ruby-mode))
  (add-to-list 'auto-mode-alist '("\\.thor$" . ruby-mode))
  (add-to-list 'auto-mode-alist '("\\.gemspec$" . ruby-mode))
  (add-to-list 'auto-mode-alist '("\\.ru$" . ruby-mode))
  (add-to-list 'auto-mode-alist '("Rakefile$" . ruby-mode))
  (add-to-list 'auto-mode-alist '("Thorfile$" . ruby-mode))
  (add-to-list 'auto-mode-alist '("Gemfile$" . ruby-mode))
  (add-to-list 'auto-mode-alist '("Capfile$" . ruby-mode))
  (add-to-list 'auto-mode-alist '("Vagrantfile$" . ruby-mode))

  (add-to-list 'completion-ignored-extensions ".rbc")
  (add-to-list 'completion-ignored-extensions ".rbo"))

;; (require 'flymake)
;; (defun flymake-create-temp-intemp (file-name prefix)
;;   "Return file name in temporary directory for checking FILE-NAME.
;; This is a replacement for `flymake-create-temp-inplace'. The
;; difference is that it gives a file name in
;; `temporary-file-directory' instead of the same directory as
;; FILE-NAME.

;; For the use of PREFIX see that function.

;; Note that not making the temporary file in another directory
;; \(like here) will not if the file you are checking depends on
;; relative paths to other files \(for the type of checks flymake
;; makes)."
;;   (unless (stringp file-name)
;;     (error "Invalid file-name"))
;;   (or prefix
;;       (setq prefix "flymake"))
;;   (let* ((name (concat
;;                 (file-name-nondirectory
;;                  (file-name-sans-extension file-name))
;;                 "_" prefix))
;;          (ext  (concat "." (file-name-extension file-name)))
;;          (temp-name (make-temp-file name nil ext))
;;          )
;;     (flymake-log 3 "create-temp-intemp: file=%s temp=%s" file-name temp-name)
;;     temp-name))

;; ;; Invoke ruby with '-c' to get syntax checking
;; (defun flymake-ruby-init ()
;;   (let* ((temp-file   (flymake-init-create-temp-buffer-copy
;;                        'flymake-create-temp-intemp))
;; 	 (local-file  (file-relative-name
;;                        temp-file
;;                        (file-name-directory buffer-file-name))))
;;     (list "ruby" (list "-c" local-file))))

;; (push '(".+\\.rb$" flymake-ruby-init) flymake-allowed-file-name-masks)
;; (push '("Rakefile$" flymake-ruby-init) flymake-allowed-file-name-masks)

;; (push '("^\\(.*\\):\\([0-9]+\\): \\(.*\\)$" 1 2 nil 3) flymake-err-line-patterns)

;; (add-hook 'ruby-mode-hook
;;           '(lambda ()

;; 	     ;; Don't want flymake mode for ruby regions in rhtml files and also on read only files
;; 	     (if (and (not (null buffer-file-name)) (file-writable-p buffer-file-name))
;; 		 (flymake-mode))
;; 	     ))
(flymake-cursor-mode 1)

(setq pycodechecker "lintrunner")
(when (load "flymake" t)
  (defun dss/flymake-pycodecheck-init ()
    (let* ((temp-file (flymake-init-create-temp-buffer-copy
                       'flymake-create-temp-inplace))
           (local-file (file-relative-name
                        temp-file
                        (file-name-directory buffer-file-name))))
      (if (not (string-match-p tramp-file-name-regexp buffer-file-name))
	  (list pycodechecker (list local-file)))))
  (add-to-list 'flymake-allowed-file-name-masks
               '("\\.py\\'" dss/flymake-pycodecheck-init)))
(add-hook 'python-mode-hook
	  (lambda () (flymake-mode 1)))
(add-hook 'ruby-mode-hook
	  (lambda () (flymake-ruby-load)))
(add-hook 'sh-mode-hook
	  (lambda () (flymake-shell-load)))
(add-hook 'haskell-mode-hook
	  (lambda () (flymake-haskell-load)))

(eval-after-load 'haskell-mode
  '(progn
     (defun prelude-haskell-mode-defaults ()
       ;; run manually since haskell-mode is not derived from prog-mode
       (run-hooks 'prelude-prog-mode-hook)
       (subword-mode +1)
       (turn-on-haskell-doc-mode)
       (turn-on-haskell-indentation))

     (setq prelude-haskell-mode-hook 'prelude-haskell-mode-defaults)

     (add-hook 'haskell-mode-hook (lambda ()
                                    (run-hooks 'prelude-haskell-mode-hook)))))

;; (helm-mode 1)
(ido-mode 1)
(menu-bar-mode 0)
(tool-bar-mode 0)
(show-paren-mode 1)
(electric-pair-mode 1)

(load "~/find-things-fast/find-things-fast.el")
(global-set-key (kbd "C-x C-d") 'find-name-dired)
(global-set-key (kbd "C-c f") 'ftf-find-file)
(global-set-key (kbd "C-c d") 'ftf-find-file-in-parent)
(global-set-key (kbd "C-c s") 'ftf-grepsource)
(load (concat user-emacs-directory (convert-standard-filename "site-lisp/cdargs.el")))

(defun cv-buffer ()
  "Change the current buffer's working directory to the visited file's
  location"
  (interactive)
  (cd (file-name-directory buffer-file-name))
  (run-hooks 'cdargs-warped-hook))


;; (require 'comint)
;; (define-key comint-mode-map [(meta p)]
;;    'comint-previous-matching-input-from-input)
;; (define-key comint-mode-map [(meta n)]
;;    'comint-next-matching-input-from-input)
;; (define-key comint-mode-map [(control meta n)]
;;     'comint-next-input)
;; (define-key comint-mode-map [(control meta p)]
;;     'comint-previous-input)

;; (setq comint-completion-autolist t	;list possibilities on partial
;; 					;completion
;;        comint-completion-recexact nil	;use shortest compl. if
;; 					;characters cannot be added
;;        ;; how many history items are stored in comint-buffers (e.g. py-shell)
;;        ;; use the HISTSIZE environment variable that shells use (if avail.)
;;        ;; (default is 32)
;;        comint-input-ring-size (string-to-number (or (getenv  
;; "HISTSIZE") "100")))

;; (add-to-list 'interpreter-mode-alist '("python" . python-mode))
;; (require 'ipython)
;; (setq py-python-command-args '("-pylab" "-colors" "Linux"))

;; (autoload 'pymacs-apply "pymacs")
;; (autoload 'pymacs-call "pymacs")
;; (autoload 'pymacs-eval "pymacs" nil t)
;; (autoload 'pymacs-exec "pymacs" nil t)
;; (autoload 'pymacs-load "pymacs" nil t)
;; (autoload 'pymacs-autoload "pymacs")
;; (defun load-ropemacs ()
;;   "Load ropemacs and pymacs"
;;   (interactive)
;;   (require 'pymacs)
;;   (pymacs-load "ropemacs" "rope-")
;; )

(autoload 'markdown-mode "markdown-mode"
  "Major mode for editing Markdown files" t)
(setq auto-mode-alist
      (cons '("\\.md" . markdown-mode) auto-mode-alist))
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-enabled-themes (quote (zsol)))
 '(custom-safe-themes (quote ("e9143042f8b9a18cb44042e61c8c0d9da0e033b01d26f2a176c7fe9204476a4d" default)))
 '(ede-project-directories (quote ("/Users/zsol/Workspace/prezi-repo/prezi.dev" "/Users/zsol/Workspace/prezi-repo/prezi.dev/server" "/Users/zsol/Workspace/prezi-repo/prezi.dev/server/django/zuisite")))
 '(helm-c-default-external-file-browser "open")
 '(helm-c-use-adaptative-sorting t)
 '(helm-command-prefix-key "C-<return>")
 '(ido-default-file-method (quote maybe-frame))
 '(ido-enable-flex-matching t)
 '(ido-everywhere t)
 '(ido-use-virtual-buffers t)
 '(inhibit-startup-screen t)
 '(js-indent-level 2)
 '(package-archives (quote (("gnu" . "http://elpa.gnu.org/packages/") ("marmalade" . "http://marmalade-repo.org/packages/"))))
 '(python-pep8-command "/usr/local/bin/pep8")
 '(python-pep8-options (quote ("--ignore=E501" "--repeat")))
 '(python-pylint-command "~/Workspace/prezi-repo/prezi.dev/server/env-prezi.dev/bin/pylint")
 '(ruby-deep-arglist nil)
 '(ruby-deep-indent-paren nil)
 '(safe-local-variable-values (quote ((virtualenv-default-directory . "/Users/zsol/Workspace/prezi-repo/prezi.dev/server/missioncontrol") (virtualenv-workon . "env-prezi.dev") (encoding . utf-8))))
 '(uniquify-buffer-name-style (quote forward) nil (uniquify)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(diff-file-header ((((class color) (min-colors 88) (background dark)) (:background "#222" :weight bold))) t)
 '(diff-header ((((class color) (min-colors 88) (background dark)) (:background "#222"))) t)
 '(helm-grep-match ((t (:inherit match :background "darkblue"))) t)
 '(helm-selection ((t (:background "ForestGreen" :foreground "black" :underline t))) t)
 '(helm-selection-line ((t (:background "darkred" :underline t))) t))

