;;; early-init.el --- early init configuration -*- lexical-binding: t; -*-

;;; Commentary:

;; Personal config early-init file.

;;; Code:


;;; Temporarily disable GC

(setq gc-cons-threshold most-positive-fixnum)


;;; Hide UI elements

(push '(menu-bar-lines . 0)   default-frame-alist)
(push '(tool-bar-lines . 0)   default-frame-alist)
(push '(vertical-scroll-bars) default-frame-alist)


;; Don't use X resources

(advice-add #'x-apply-session-resources :override #'ignore)


;;; Resizing

(setq frame-inhibit-implied-resize t
      frame-resize-pixelwise t
      window-resize-pixelwise t)


;;; Theme

(load-theme 'my-purple t)


(provide 'early-init)
;;; early-init.el ends here
