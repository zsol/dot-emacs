;; -*- mode: lisp -*-

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

(defun mapcar-head (fn-head fn-rest list)
  "Like MAPCAR, but applies a different function to the first element."
  (if list
      (cons (funcall fn-head (car list)) (mapcar fn-rest (cdr list)))))
(defun split-name (s)
  (split-string
   (let ((case-fold-search nil))
	 (downcase
	  (replace-regexp-in-string "\\([a-z]\\)\\([A-Z]\\)" "\\1 \\2" s)))
   "[^A-Za-z0-9]+"))
(defun camelcase  (s) (mapconcat 'identity (mapcar-head 'downcase 'capitalize (split-name s)) ""))
(defun underscore (s) (mapconcat 'downcase   (split-name s) "_"))
(defun dasherize  (s) (mapconcat 'downcase   (split-name s) "-"))
(defun camelscore (s)
  (cond ((string-match-p "\\(?:[a-z]+_\\)+[a-z]+" s)	(dasherize  s))
	    ((string-match-p "\\(?:[a-z]+-\\)+[a-z]+" s)	(camelcase  s))
	    (t						(underscore s)) ))
(defun camelscore-word-at-point ()
  (interactive)
  (let* ((case-fold-search nil)
	     (beg (and (skip-chars-backward "[:alnum:]:_-") (point)))
	     (end (and (skip-chars-forward  "[:alnum:]:_-") (point)))
	     (txt (buffer-substring beg end))
	     (cml (camelscore txt)) )
	(if cml (progn (delete-region beg end) (insert cml))) ))

(global-set-key (kbd "C-c m") 'camelscore-word-at-point)

(package-initialize)
(require 'diminish)

(setq-default tab-width 4)
(defun set-indent-tabs-mode ()
  (set-variable 'indent-tabs-mode t))

(defconst prezi-cc-style
  '("stroustrup"
    (c-offsets-alist . ((innamespace . [0])))))
(c-add-style "prezi-cc-style" prezi-cc-style)


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

(require 'ag)
(require 'wgrep-ag)
(require 'unfill)
(require 'whole-line-or-region)
(whole-line-or-region-mode t)
(require 'undo-tree)
(global-undo-tree-mode)
(diminish 'undo-tree-mode)
(require 'mic-paren)
(paren-activate)
(require 'expand-region)
(global-set-key (kbd "C-=") 'er/expand-region)

(require 'move-text)
(move-text-default-bindings)
(global-set-key [M-S-up] 'move-text-up)
(global-set-key [M-S-down] 'move-text-down)

(require 'visual-regexp)
(global-set-key [remap query-replace-regexp] 'vr/query-replace)
(global-set-key [remap replace-regexp] 'vr/replace)

(setq-default
 ag-highlight-search t
 delete-selection-mode t
 ediff-split-window-function 'split-window-horizontally
 ediff-window-setup-function 'ediff-setup-windows-plain
 make-backup-files nil
 scroll-preserve-screen-position 'always
 show-trailing-whitespace t)

(global-auto-revert-mode)
(diminish 'auto-revert-mode)
(setq global-auto-revert-non-file-buffers t
      auto-revert-verbose nil)

(transient-mark-mode t)
(require 'volatile-highlights)
(volatile-highlights-mode t)


(icomplete-mode +1)

;; (load-file (concat user-emacs-directory (convert-standard-filename "site-lisp/cedet/common/cedet.el")))
(global-ede-mode 1)
(semantic-mode 1)

(require 'uniquify)
(require 'ido)
(require 'ido-ubiquitous)
(ido-mode 1)
(ido-everywhere 1)
(ido-ubiquitous-mode 1)
(setq-default
 ido-auto-merge-work-directories-length 0
 ido-default-buffer-method 'selected-window
 ido-default-file-method 'selected-window
 ido-enable-flex-matching t
 ido-use-filename-at-point nil
 ido-use-virtual-buffers t)

(require 'smex)
(global-set-key (kbd "M-x") 'smex)

(require 'yaml-mode)
(require 'json-mode)
(add-to-list 'auto-mode-alist '("\\.json" . json-mode))
(require 'powerline)
(setq powerline-arrow-shape 'arrow14)

(autoload 'haxe-mode "haxe-mode")
(add-to-list 'auto-mode-alist '("\\.hx" . haxe-mode))

(require 'hsenv)


(autoload 'ghc-init "ghc" nil t)
(add-hook 'haskell-mode-hook (lambda () (ghc-init) (flymake-mode)))
(eval-after-load 'haskell-mode
  '(progn
     (define-key haskell-mode-map (kbd "C-c i") 'ghc-check-insert-from-warning)))


(define-key isearch-mode-map (kbd "C-o") 'isearch-occur)
(defun isearch-exit-other-end (rbeg rend)
  "Exit isearch, but at the other end of the search string.
This is useful when followed by an immediate kill."
  (interactive "r")
  (isearch-exit)
  (goto-char isearch-other-end))

(define-key isearch-mode-map [(control return)] 'isearch-exit-other-end)

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
;(flymake-cursor-mode 1)

(setq jsonlint "jsonlint")
(when (load "flymake" t)
  (defun flymake-jsonlint-init ()
    (let* ((temp-file (flymake-init-create-temp-buffer-copy
                       'flymake-create-temp-intemp))
           (arglist (list "-c" temp-file)))
      (if (not (string-match-p tramp-file-name-regexp buffer-file-name))
          (list jsonlint arglist))))
  (add-to-list 'flymake-allowed-file-name-masks
               '("\\.json\\'" flymake-jsonlint-init)))
(add-hook 'json-mode-hook
          (lambda () (flymake-mode 1)))

(setq pycodechecker "/Users/zsol/.dotfiles/bin/lintrunner")
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
(menu-bar-mode 0)
(tool-bar-mode 0)
(show-paren-mode 1)
(electric-pair-mode 1)

(require 'find-things-fast)
(setq ftf-grep-command "ag -S --nogroup --column")
(global-set-key (kbd "C-x C-d") 'find-name-dired)
(global-set-key (kbd "C-c f") 'ftf-find-file)
(global-set-key (kbd "C-c d") 'ftf-find-file-in-parent)
(global-set-key (kbd "C-c s") 'ftf-grepsource)

(global-whitespace-mode 1)
(diminish 'whitespace-mode)

(define-coding-system-alias 'UTF-8 'utf-8)
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

(defun func-region (start end func)
  "run a function over the region between START and END in current buffer."
  (save-excursion
    (let ((text (delete-and-extract-region start end)))
      (insert (funcall func text)))))

(defun hex-region (start end)
  "urlencode the region between START and END in current buffer."
  (interactive "r")
  (func-region start end #'url-hexify-string))

(defun unhex-region (start end)
  "de-urlencode the region between START and END in current buffer."
  (interactive "r")
  (func-region start end #'url-unhex-string))

(autoload 'markdown-mode "markdown-mode"
  "Major mode for editing Markdown files" t)
(setq auto-mode-alist
      (cons '("\\.md" . markdown-mode) auto-mode-alist))

(setq org-timer-default-timer 25)
(add-hook 'org-clock-in-hook '(lambda () 
      (if (not org-timer-current-timer) 
      (org-timer-set-timer '(16)))))

(defmacro after-load (feature &rest body)
  "After FEATURE is loaded, evaluate BODY."
  (declare (indent defun))
  `(eval-after-load ,feature
     '(progn ,@body)))

;; git

(require 'magit)
(require 'git-gutter-fringe+)
(require 'git-blame)
(require 'git-commit-mode)
(require 'git-rebase-mode)
(require 'gitignore-mode)
(require 'gitconfig-mode)

(setq-default
 magit-save-some-buffers nil
 magit-process-popup-time 10
 magit-diff-refine-hunk t
 magit-completing-read-function 'magit-ido-completing-read)

(global-set-key [f12] 'magit-status)

(after-load 'magit
  ;; Don't let magit-status mess up window configurations
  ;; http://whattheemacsd.com/setup-magit.el-01.html
  (defadvice magit-status (around magit-fullscreen activate)
    (window-configuration-to-register :magit-fullscreen)
    ad-do-it
    (delete-other-windows))

  (defun magit-quit-session ()
    "Restores the previous window configuration and kills the magit buffer"
    (interactive)
    (kill-buffer)
    (when (get-register :magit-fullscreen)
      (ignore-errors
        (jump-to-register :magit-fullscreen))))

  (define-key magit-status-mode-map (kbd "q") 'magit-quit-session))


;;; When we start working on git-backed files, use git-wip if available

(after-load 'vc-git
  (global-magit-wip-save-mode)
  (diminish 'magit-wip-save-mode))


;;; Use the fringe version of git-gutter

(after-load 'git-gutter
  (require 'git-gutter-fringe))


;; Convenient binding for vc-git-grep
(global-set-key (kbd "C-x v f") 'vc-git-grep)


(require 'git-messenger)
(global-set-key (kbd "C-x v p") #'git-messenger:popup-message)


;;; github

(require 'yagist)
(require 'github-browse-file)
;(require 'bug-reference-github)
;(add-hook 'prog-mode-hook 'bug-reference-prog-mode)


(require 'server)
(unless (server-running-p)
  (server-start))

(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(when (file-exists-p custom-file)
  (load custom-file))


(put 'upcase-region 'disabled nil)
