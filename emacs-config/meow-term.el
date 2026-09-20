;;; meow-term.el --- Integrate meow and term modes -*- lexical-binding: t; -*-

;; Copyright (C) 2022 Archit Gupta

;; Version: 1.0.0
;; Author: Archit Gupta <archit@accelbread.com>
;; Maintainer: Archit Gupta <archit@accelbread.com>
;; URL: https://github.com/accelbread/meow-term.el
;; Keywords: meow, term
;; Package-Requires: ((emacs "28.1") (meow "1.4.0"))

;; This file is not part of GNU Emacs

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

;; This package integrates meow's input modes with term's input modes.
;;
;; Term's char mode consumes all inputs, making it not integrate well with meow.
;; This package solves this by setting term to line mode while in meow normal
;; mode, and setting term to the actual desired of line/char mode while in meow
;; insert mode.
;;
;; To use this package add `(meow-term-enable)' to your init.el.

;;; Code:

(require 'meow)
(require 'term)

(defvar-local meow-term-char-mode-desired t
  "Whether the current term buffer should be in char mode.")

(defun meow-term-insert-enter ()
  "Switch keybinds to char mode if char mode set."
  (when meow-term-char-mode-desired (term-char-mode)))

(defun meow-term-insert-exit ()
  "Switch to line keybinds if in char mode."
  (when meow-term-char-mode-desired
    (term-line-mode)
    (setq meow-term-char-mode-desired t)
    (term-update-mode-line)))

(defun meow-term-setup-hooks ()
  "Ensure line keybindings outside of insert mode."
  (add-hook 'meow-insert-enter-hook #'meow-term-insert-enter nil t)
  (add-hook 'meow-insert-exit-hook #'meow-term-insert-exit nil t))

;;;###autoload
(defun meow-term-enable ()
  "Enable syncing term input mode with current meow mode."
  (advice-add #'term-update-mode-line :around
              (lambda (oldfun)
                "Show intended term input mode in mode line."
                (if meow-term-char-mode-desired
                    (let ((real-map (current-local-map)))
                      (use-local-map term-raw-map)
                      (funcall oldfun)
                      (use-local-map real-map))
                  (funcall oldfun)))
              '((name . meow-term)))
  (advice-add #'term-char-mode :before-while
              (lambda ()
                "Set intended input mode to char and switch if in insert mode."
                (setq meow-term-char-mode-desired t)
                (term-update-mode-line)
                (meow-insert-mode-p))
              '((name . meow-term)))
  (advice-add #'term-line-mode :before
              (lambda ()
                "Set intended input mode to line and switch."
                (setq meow-term-char-mode-desired nil)
                (term-update-mode-line))
              '((name . meow-term)))
  (add-hook 'term-mode-hook #'meow-term-setup-hooks)
  ;; Make escape usable, since it now changes mode.
  (define-key term-raw-escape-map (kbd "ESC") #'term-send-raw)
  (define-key term-mode-map (kbd "C-c ESC") #'term-send-raw))

(provide 'meow-term)
;;; meow-term.el ends here
