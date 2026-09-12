;;; config-trust.el --- Project trust config -*- lexical-binding: t; -*-

;; Copyright (C) Archit Gupta <archit@accelbread.com>
;; SPDX-License-Identifier: GPL-3.0-or-later
;; Version: 0
;; Package-Requires: ((emacs "31.1"))

;;; Commentary:

;; Configuration for managing and using `trusted-content'.

;;; Code:

(eval-when-compile
  (require 'cl-lib)
  (require 'project)
  (require 'savehist))

(defvar ag--recorded-trust-alist nil)

(defun ag--update-trusted-content (dir &optional remove)
  "Add or remove DIR from `trusted-content' based on REMOVE."
  (if remove
      (setq-default trusted-content
                    (delete dir (default-value 'trusted-content)))
    (add-to-list 'trusted-content dir)))

(defun ag--record-trust (dir trust)
  "Record value of TRUST for DIR."
  (setf (alist-get dir ag--recorded-trust-alist nil nil #'equal) trust)
  (ag--update-trusted-content dir (not trust)))

(defun ag--restore-recorded-trust ()
  "Add recorded trusted directories to `trusted-content'."
  (let ((projects (project-known-project-roots)))
    (setq ag--recorded-trust-alist
          (seq-filter (lambda (entry) (member (car entry) projects))
                      ag--recorded-trust-alist)))
  (dolist (entry ag--recorded-trust-alist)
    (ag--update-trusted-content (car entry) (not (cdr entry)))))

(with-eval-after-load 'savehist
  (add-to-list 'savehist-additional-variables 'ag--recorded-trust-alist)
  (add-hook 'savehist-mode-hook #'ag--restore-recorded-trust))

(defun ag--forget-trust (dir &rest _)
  "Remove trust record for DIR."
  (when (assoc dir ag--recorded-trust-alist)
    (setq ag--recorded-trust-alist
          (assoc-delete-all dir ag--recorded-trust-alist))
    (ag--update-trusted-content dir t)))

(advice-add 'project--remove-from-project-list :after #'ag--forget-trust)

(defun ag-trust-project (project trust)
  "Trust or untrust PROJECT according to TRUST.
When called interactively, sets current project to trusted. With prefix
argument, sets project as untrusted."
  (interactive
   (let* ((trust (not current-prefix-arg))
          (project (project-current t)))
     (if (or (not trust)
             (y-or-n-p (format "Trust project %s?"
                               (project-root project))))
         (list project trust)
       (user-error "Trusting project not approved"))))
  (ag--record-trust (project-root project) trust))

(defun ag--project-dir-trusted-p (dir)
  "Returns whether project DIR is trusted."
  (any (lambda (p) (and (string-suffix-p "/" p) (string-prefix-p p dir)))
       trusted-content))

(defun ag--buffer-get-trust ()
  "Get trust state for buffer."
  (if (trusted-content-p) t
    (when-let* ((_ buffer-file-name)
                (project (project-current))
                (dir (project-root project))
                (_ (not (assoc dir ag--recorded-trust-alist)))
                (_ (not (any (lambda (r) (if (functionp r) (funcall r project)
                                      (string-match-p r dir)))
                             project-list-exclude))))
      (let ((user-response (yes-or-no-p (format "Trust project %s?" dir))))
        (ag--record-trust dir user-response)
        user-response))))

(defun ag--buffer-init-trust ()
  "Initialize trust state for buffer."
  (when (ag--buffer-get-trust)
    (setq-local enable-local-variables :all)))

;;;###autoload
(define-minor-mode ag-trust-mode
  "Ask for project trust decisions and enable local vars in trusted buffers."
  :global t :group 'convenience
  (if ag-trust-mode
      (progn
        (add-hook 'change-major-mode-after-body-hook #'ag--buffer-init-trust)
        (advice-add
         'normal-mode :around
         (lambda (orig-fn &rest args)
           "Use local variables for trusted files."
           (if (ag--buffer-get-trust)
               (let ((enable-local-variables :all))
                 (apply orig-fn args))
             (apply orig-fn args)))
         '((name . use-locals-when-trusted))))
    (remove-hook 'change-major-mode-after-body-hook #'ag--buffer-init-trust)
    (advice-remove 'normal-mode 'use-locals-when-trusted)))

;; trusted-content-p is slow as it performs file-equal-p on every
;; trusted-content entry
(advice-add
 'trusted-content-p :override
 (lambda ()
   "Return non-nil when the current buffer has a canonically trusted path."
   (and (not untrusted-content)
        (or (eq trusted-content :all)
            (when-let* ((file buffer-file-truename))
              (any (lambda (trusted-file)
                     (if (string-suffix-p "/" trusted-file)
                         (string-prefix-p trusted-file file)
                       (equal trusted-file file)))
                   trusted-content)))))
 '((name . optimize-trusted-content-p)))

(provide 'config-trust)
