;;; config-rg-fixes.el --- Fixes for rg-mode -*- lexical-binding: t; -*-

;; Copyright (C) Archit Gupta <archit@accelbread.com>
;; SPDX-License-Identifier: GPL-3.0-or-later
;; Version: 0
;; Package-Requires: ((emacs "31.1") rg)

;;; Commentary:

;; Fixes for issues in `rg-mode'.

;;; Code:

;;;###autoload (with-eval-after-load 'rg (require 'config-rg-fixes))

(eval-when-compile (require 'cl-lib))

(require 'rg)

(advice-add
 #'rg-header-mouse-action :filter-return
 (lambda (header)
   "Bind both primary mouse events in an rg HEADER action."
   (when-let* ((map (plist-get (cddr header) 'keymap))
               (command (or (lookup-key map [header-line mouse-1])
                            (lookup-key map [header-line mouse-2]))))
     (define-key map [header-line mouse-1] command)
     (define-key map [header-line mouse-2] command))
   header)
 '((name . bind-both-mouse-1-and-2)))

(advice-add
 #'rg-header-render-label :filter-return
 (lambda (header)
   "Let HEADER inherit the active or inactive header-line face."
   (cl-labels ((remove-header-line-face (tree)
                 (cond ((not (consp tree)) tree)
                       ((eq (car tree) 'header-line)
                        (remove-header-line-face (cdr tree)))
                       (t (cons (remove-header-line-face (car tree))
                                (remove-header-line-face (cdr tree)))))))
     (remove-header-line-face header)))
 '((name . header-inherit-window-face)))

(provide 'config-rg-fixes)
