;;; git-messenger.el --- Pop up last commit information of current line

;; Copyright (C) 2014 by Syohei YOSHIDA

;; Author: Syohei YOSHIDA <syohex@gmail.com>
;; URL: https://github.com/syohex/emacs-git-messenger
;; Version: 20140402.758
;; X-Original-Version: 0.11
;; Package-Requires: ((popup "0.5.0"))

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; This package provides a function called git-messenger:popup-message
;; that when called will pop-up the last git commit message for the
;; current line. This uses the git-blame tool internally.
;;
;; Example usage:
;;   (require 'git-messenger)
;;   (global-set-key (kbd "C-x v p") 'git-messenger:popup-message)
;;

;;; Code:

(require 'popup)
(require 'tramp)

(defgroup git-messenger nil
  "git messenger"
  :group 'vc)

(defcustom git-messenger:show-detail nil
  "Pop up commit ID and author name too"
  :type 'bool
  :group 'git-messenger)

(defcustom git-messenger:before-popup-hook nil
  "hook run before popup commit message. This hook is taken popup-ed message"
  :type 'hook
  :group 'git-messenger)

(defcustom git-messenger:after-popup-hook nil
  "hook run after popup commit message. This hook is taken popup-ed message"
  :type 'hook
  :group 'git-messenger)

(defvar git-messenger:last-message nil
  "Last message displayed by git-messenger.

This is set before the pop-up is displayed so accessible in the hooks
and menus.")

(defvar git-messenger:last-commit-id nil
  "Last commit id for the last message displayed.

This is set before the pop-up is displayed so accessible in the hooks
and menus.")

(defun git-messenger:real-file-name (file)
  (if (not (file-remote-p file))
      file
    (aref (tramp-dissect-file-name file) 3)))

(defun git-messenger:blame-command (file line)
  (let ((real-file (git-messenger:real-file-name file)))
    (format "git --no-pager blame -w -L %d,+1 --porcelain %s"
            line (shell-quote-argument real-file))))

(defsubst git-messenger:cat-file-command (commit-id)
  (format "git --no-pager cat-file commit %s" commit-id))

(defun git-messenger:execute-command (cmd remote)
  (if (not remote)
      (call-process-shell-command cmd nil t)
    (process-file-shell-command cmd nil t)))

(defun git-messenger:commit-info-at-line (file line remote-p)
  (with-temp-buffer
    (let ((cmd (git-messenger:blame-command file line)))
      (unless (zerop (git-messenger:execute-command cmd remote-p))
        (error "Failed: %s" cmd))
      (goto-char (point-min))
      (let* ((id-line (buffer-substring-no-properties
                       (line-beginning-position) (line-end-position)))
             (commit-id (car (split-string id-line)))
             (author (if (re-search-forward "^author \\(.+\\)$" nil t)
                         (match-string-no-properties 1)
                       "unknown")))
        (cons commit-id author)))))

(defsubst git-messenger:not-committed-id-p (commit-id)
  (string-match-p "\\`0+\\'" commit-id))

(defun git-messenger:commit-message (commit-id remote-p)
  (with-temp-buffer
    (if (git-messenger:not-committed-id-p commit-id)
        "* not yet committed *"
      (let ((cmd (git-messenger:cat-file-command commit-id)))
        (unless (zerop (git-messenger:execute-command cmd remote-p))
          (error "Failed: %s" cmd))
        (goto-char (point-min))
        (forward-paragraph)
        (buffer-substring-no-properties (point) (point-max))))))

(defun git-messenger:commit-date (commit-id remote-p)
  (let ((cmd (format "git --no-pager show --pretty=%%cd %s" commit-id)))
    (with-temp-buffer
      (unless (zerop (git-messenger:execute-command cmd remote-p))
        (error "Failed %s" cmd))
      (goto-char (point-min))
      (buffer-substring-no-properties
       (line-beginning-position) (line-end-position)))))

(defun git-messenger:format-detail (commit-id author message remote-p)
  (let ((date (git-messenger:commit-date commit-id remote-p)))
    (format "commit : %s \nAuthor : %s\nDate   : %s \n%s"
            (substring commit-id 0 8) author date message)))

(defun git-messenger:show-detail-p (commit-id)
  (and (or git-messenger:show-detail current-prefix-arg)
       (not (git-messenger:not-committed-id-p commit-id))))

(defun git-messenger:copy-message ()
  "Copy current displayed commit message to kill-ring."
  (interactive)
  (when git-messenger:last-message
    (kill-new git-messenger:last-message))
  (keyboard-quit))

(defun git-messenger:copy-commit-id ()
  "Copy current displayed commit id to kill-ring."
  (interactive)
  (when git-messenger:last-commit-id
    (kill-new git-messenger:last-commit-id))
  (keyboard-quit))

(defun git-messenger:popup-common (cmd &optional mode)
  (with-current-buffer (get-buffer-create "*git-messenger*")
    (setq buffer-read-only nil)
    (fundamental-mode)
    (erase-buffer)
    (unless (zerop (call-process-shell-command cmd nil t))
      (error "Failed: '%s'" cmd))
    (pop-to-buffer (current-buffer))
    (when mode
      (funcall mode))
    (setq buffer-read-only t)
    (goto-char (point-min)))
  (keyboard-quit))

(defun git-messenger:popup-diff ()
  (interactive)
  (let ((cmd (format "git --no-pager diff --no-ext-diff %s^!"
                     git-messenger:last-commit-id)))
    (git-messenger:popup-common cmd 'diff-mode)))

(defun git-messenger:popup-show ()
  (interactive)
  (let ((cmd (concat "git --no-pager show --no-ext-diff --stat "
                     git-messenger:last-commit-id)))
    (git-messenger:popup-common cmd)))

(defun git-messenger:popup-show-verbose ()
  (interactive)
  (let ((cmd (concat "git --no-pager show --no-ext-diff --stat -p "
                     git-messenger:last-commit-id)))
    (git-messenger:popup-common cmd)))

(defvar git-messenger-map
  (let ((map (make-sparse-keymap)))
    ;; key bindings
    (define-key map (kbd "q") 'keyboard-quit)
    (define-key map (kbd "c") 'git-messenger:copy-commit-id)
    (define-key map (kbd "d") 'git-messenger:popup-diff)
    (define-key map (kbd "s") 'git-messenger:popup-show)
    (define-key map (kbd "S") 'git-messenger:popup-show-verbose)
    (define-key map (kbd "M-w") 'git-messenger:copy-message)
    map)
  "Key mappings of git-messenger. This is enabled when commit message is popup-ed.")

;;;###autoload
(defun git-messenger:popup-message ()
  (interactive)
  (let* ((file (buffer-file-name (buffer-base-buffer)))
         (remote-p (file-remote-p file))
         (line (line-number-at-pos))
         (commit-info (git-messenger:commit-info-at-line file line remote-p))
         (commit-id (car commit-info))
         (author (cdr commit-info))
         (msg (git-messenger:commit-message commit-id remote-p))
         (popuped-message (if (git-messenger:show-detail-p commit-id)
                              (git-messenger:format-detail commit-id author msg remote-p)
                            msg)))
    (setq git-messenger:last-message popuped-message
          git-messenger:last-commit-id commit-id)
    (run-hook-with-args 'git-messenger:before-popup-hook popuped-message)
    (let ((menu (popup-tip popuped-message :nowait t)))
      (unwind-protect
          (popup-menu-event-loop menu git-messenger-map 'popup-menu-fallback)
        (popup-delete menu)))
    (run-hook-with-args 'git-messenger:after-popup-hook popuped-message)))

(provide 'git-messenger)

;; Local Variables:
;; coding: utf-8
;; indent-tabs-mode: nil
;; End:

;;; git-messenger.el ends here
