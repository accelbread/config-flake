;;; init.el --- emacs configuration file -*- lexical-binding: t; -*-

;;; Commentary:

;; Personal Emacs config file.

;;; Code:


;;; Default fonts

(set-face-attribute 'default nil :height 120 :family "DejaVu Sans Mono")
(set-face-attribute 'fixed-pitch nil :family "DejaVu Sans Mono")
(set-face-attribute 'variable-pitch nil :family "DejaVu Sans")


;;; Networking

(setq network-security-level 'high
      gnutls-verify-error t
      gnutls-min-prime-bits 3072
      gnutls-algorithm-priority "PFS:-VERS-TLS1.2:-VERS-TLS1.1:-VERS-TLS1.0")

(setq auth-sources '("~/.authinfo.gpg"))


;;; Configure packages

(with-eval-after-load 'package
  (add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t))

(setq package-selected-packages
      '( meow gcmh rainbow-delimiters jinx which-key rg editorconfig inheritenv
         corfu cape kind-icon vertico orderless marginalia consult vundo envrc
         magit magit-todos hl-todo magit-annex git-annex virtual-comment rmsbolt
         fish-completion eat coterm meow-term vterm meow-vterm yasnippet svg-lib
         rainbow-mode adaptive-wrap reformatter devdocs markdown-mode cmake-mode
         clang-format rust-mode cargo zig-mode nix-mode geiser-guile scad-mode
         haskell-mode toml-mode yaml-mode git-modes pdf-tools flymake-vale))

(setq package-native-compile t)


;;; Config utils

(eval-when-compile
  (require 'cl-lib))

(defun y-or-n-p-always-y-wrapper (orig-fun &rest args)
  "Call ORIG-FUN with ARGS, automatically using `y' for `y-or-n-p' questions."
  (cl-letf (((symbol-function #'y-or-n-p) #'always))
    (apply orig-fun args)))

(defun inhibit-redisplay-wrapper (orig-fun &rest args)
  "Call ORIG-FUN with ARGS with display inhibited."
  (let ((inhibit-redisplay t))
    (apply orig-fun args)))

(defmacro push-default (newelt var)
  "Add NEWELT to the list stored in the default value of VAR."
  `(setq-default ,var (cons ,newelt (default-value ,var))))

(defun command-var (var)
  "Return lambda for calling command in VAR."
  (lambda () (interactive) (call-interactively (symbol-value var))))

(defmacro completion-pred (&rest body)
  "Return completion-predicate with BODY in correct buffer."
  `(lambda (_sym buffer) (with-current-buffer buffer ,@body)))

(defun hide-minor-mode (mode &optional value)
  "Remove display for minor mode MODE from the mode line or set to VALUE."
  (setf (alist-get mode minor-mode-alist) (list value)))

(defun set-header-fixed-pitch ()
  "Set the header-line face to use fixed-pitch in the current buffer."
  (face-remap-add-relative 'header-line '(:inherit (fixed-pitch))))

(defvar after-frame-hook nil
  "Hook for execution after first frame in daemon mode.")

(defun run-after-frame-hook ()
  "Run and clean up `after-frame-hook'."
  (remove-hook 'server-after-make-frame-hook #'run-after-frame-hook)
  (run-hooks 'after-frame-hook)
  (setq after-frame-hook nil))

(add-hook 'server-after-make-frame-hook #'run-after-frame-hook)

(defmacro after-frame (&rest body)
  "Run BODY now if not daemon and after first frame if daemon."
  (if (daemonp)
      `(add-hook 'after-frame-hook (lambda () ,@body))
    `(progn ,@body)))

(defun load-face (face)
  "Recursively define FACE so its theme attributes can be queried."
  (unless (facep face)
    (eval `(defface ,face nil nil))
    (if-let* ((inherit (face-attribute face :inherit))
              (listp inherit))
        (mapc #'load-face inherit))))


;;; Hide welcome messages

(setq inhibit-startup-screen t
      initial-scratch-message nil
      server-client-instructions nil)


;;; Reduce confirmations

(setq use-short-answers t
      confirm-kill-processes nil
      kill-buffer-query-functions nil
      auth-source-save-behavior nil
      enable-local-variables :safe
      disabled-command-function nil)

(global-set-key (kbd "C-x k") 'kill-current-buffer)

(defun autosave-git-buffer ()
  "If current buffer is tracked by git, don't confirm when saving it."
  (if-let* ((file (buffer-file-name))
            ((vc-git-registered file)))
      (setq-local buffer-save-without-query t)))

(add-hook 'prog-mode-hook #'autosave-git-buffer)


;;; Disable use of dialog boxes

(setq use-dialog-box nil
      use-file-dialog nil)


;;; Prevent misc file creation

(setq auto-save-file-name-transforms
      `((".*" ,(file-name-concat user-emacs-directory "auto-save/") t))
      make-backup-files nil
      create-lockfiles nil
      custom-file null-device)

(unless (file-directory-p (file-name-concat user-emacs-directory "auto-save/"))
  (mkdir (file-name-concat user-emacs-directory "auto-save/")))


;;; Prevent input method from consuming keys

(setq pgtk-use-im-context-on-new-connection nil)
(setq pgtk-use-im-context nil)


;;; Prevent loop when printing recursive structures

(setq print-circle t)


;;; Disable overwriting of system clipboard with selection

(setq select-enable-clipboard nil)


;;; Prevent accidental closing

(global-unset-key (kbd "C-z"))
(global-unset-key (kbd "C-x C-z"))


;;; Save minibuffer history

(when (daemonp)
  (savehist-mode))


;;; Undo

(setq undo-limit (* 4 1024 1024)
      undo-strong-limit (* 6 1024 1024)
      kill-ring-max 512
      kill-do-not-save-duplicates t)

(with-eval-after-load 'vundo
  (setq vundo-glyph-alist vundo-unicode-symbols))


;;; Update files modified on disk

(setq global-auto-revert-non-file-buffers t)

(global-auto-revert-mode)


;;; Scrolling

(setq scroll-conservatively 101
      scroll-margin 0
      next-screen-context-lines 3)

(when (>= emacs-major-version 29)
  (setq pixel-scroll-precision-large-scroll-height 10.0
        pixel-scroll-precision-interpolate-page t)
  (pixel-scroll-precision-mode))


;;; Default to utf-8

(set-default-coding-systems 'utf-8)


;;; Formatting

(setq-default fill-column 80
              indent-tabs-mode nil
              tab-always-indent nil
              require-final-newline t)

(setq sentence-end-double-space nil)

(add-hook 'text-mode-hook #'auto-fill-mode)

(hide-minor-mode 'auto-fill-function " ↩️")

(setq editorconfig-mode-lighter "")

(editorconfig-mode)


;;; Misc UI

(setq whitespace-style '(face trailing tab-mark tabs missing-newline-at-eof)
      whitespace-global-modes '(prog-mode text-mode conf-mode)
      global-display-fill-column-indicator-modes '(prog-mode text-mode)
      resize-mini-windows t
      suggest-key-bindings nil
      truncate-partial-width-windows 83
      mouse-drag-and-drop-region t
      mouse-yank-at-point t
      isearch-lazy-count t)

(blink-cursor-mode -1)
(window-divider-mode)
(fringe-mode 9)
(global-whitespace-mode)
(global-display-fill-column-indicator-mode)
(global-prettify-symbols-mode)
(global-hl-todo-mode)
(context-menu-mode)

(add-hook 'prog-mode-hook #'rainbow-delimiters-mode)
(add-hook 'prog-mode-hook #'adaptive-wrap-prefix-mode)

(hide-minor-mode 'abbrev-mode)
(hide-minor-mode 'whitespace-mode)

(with-eval-after-load 'face-remap
  (hide-minor-mode 'buffer-face-mode))


;;; Window layout

(defun my-split-window-sensibly (&optional window)
  "Split WINDOW, preferring horizontal splits."
  (let ((window (or window (selected-window))))
    (or (and (window-splittable-p window t)
             (with-selected-window window (split-window-right)))
        (split-window-sensibly window))))

(setq split-window-preferred-function #'my-split-window-sensibly)


;;; Emoji

(after-frame
 (set-fontset-font t 'emoji "Noto Emoji")
 (set-fontset-font t 'emoji "Noto Color Emoji" nil 'append))

(create-fontset-from-fontset-spec
 (font-xlfd-name (font-spec :registry "fontset-coloremoji")))

(set-fontset-font "fontset-coloremoji" 'emoji "Noto Color Emoji")

(defface color-emoji nil
  "Face which uses the coloremoji fontset."
  :group 'custom)

(after-frame
 (set-face-attribute 'color-emoji nil :fontset "fontset-coloremoji"))

(defvar-local color-emoji-remapping nil
  "Holds cookie for color emoji face remapping entry.")

(define-minor-mode color-emoji-mode
  "Minor mode for color emoji."
  :lighter ""
  (when color-emoji-remapping
    (face-remap-remove-relative color-emoji-remapping))
  (setq color-emoji-remapping
        (and color-emoji-mode
             (face-remap-add-relative 'default 'color-emoji))))


;;; Mode line

(setq mode-line-compact 'long)

(defmacro window-font-dim-override (face &rest body)
  "Execute BODY with FACE as default for height/width calculation."
  (declare (indent 1))
  `(cl-letf* ((orig-window-font-width (symbol-function 'window-font-width))
              (orig-window-font-height (symbol-function 'window-font-height))
              ((symbol-function 'window-font-width)
               (lambda ()
                 (funcall orig-window-font-width nil ,face)))
              ((symbol-function 'window-font-height)
               (lambda ()
                 (funcall orig-window-font-height nil ,face))))
     ,@body))

(setq-default mode-line-format
              `("%e "
                (:eval (when (window-dedicated-p) "📌"))
                (:eval (cond ((meow-normal-mode-p) "😺")
                             ((meow-insert-mode-p) "😸")
                             ((meow-beacon-mode-p) "😻")
                             ((meow-keypad-mode-p) "😾")
                             ((meow-motion-mode-p) "😿")
                             (t "🙀")))
                (:eval (pcase (list buffer-read-only (buffer-modified-p))
                         ('(nil nil) "✨")
                         ('(nil t) "🖋️")
                         ('(t nil) "🔒")
                         ('(t t) "🔏")))
                (:eval (when (file-remote-p default-directory) "✈️"))
                (server-buffer-clients "🚨")
                (:eval (when (buffer-narrowed-p) "🔎"))
                (:eval (propertize
                        " %l " 'display
                        (window-font-dim-override 'mode-line
                          (svg-lib-progress-bar
                           (/ (float (point)) (point-max))
                           nil :width 3 :height 0.48 :stroke 1 :padding 2
                           :radius 1 :margin 1))))
                " " (:propertize "%12b" face mode-line-buffer-id)
                (:propertize
                 (:eval (unless (eq buffer-file-coding-system 'utf-8-unix)
                          (let ((base (coding-system-base
                                       buffer-file-coding-system))
                                (eol (coding-system-eol-type
                                      buffer-file-coding-system)))
                            (if (or (eq base 'utf-8)
                                    (eq base 'undecided))
                                (pcase eol (1 "  dos") (2 "  mac"))
                              `("  " ,(symbol-name
                                       (if (eq eol 0) base
                                         buffer-file-coding-system)))))))
                 face italic)
                (flymake-mode (:eval (when (length> (flymake-diagnostics) 0)
                                       (list "  "
                                             flymake-mode-line-error-counter
                                             flymake-mode-line-warning-counter
                                             flymake-mode-line-note-counter))))
                "  " mode-name mode-line-process
                (:eval (when (eq major-mode 'term-mode)
                         (list (term-line-ending-mode-line)
                               (when term-enable-local-echo " echo"))))
                " " minor-mode-alist
                "  " mode-line-misc-info))


;;; Flash active mode line for bell

(defface mode-line-flash nil
  "Face used for flashing mode line."
  :group 'custom)

(defvar mode-line-flash-state nil
  "If non-nil, contains buffer with active mode line flash.")

(defun mode-line-flash-end ()
  "End the mode line flash."
  (when mode-line-flash-state
    (with-current-buffer mode-line-flash-state
      (face-remap-reset-base 'mode-line-active)
      (setq mode-line-flash-state nil))))

(defun mode-line-flash ()
  "Flash the mode line."
  (unless mode-line-flash-state
    (setq mode-line-flash-state (current-buffer))
    (face-remap-set-base 'mode-line-active '(:inherit (mode-line-flash)))
    (run-with-timer 0.05 nil #'mode-line-flash-end)))

(setq-default ring-bell-function #'mode-line-flash)


;;; Display page breaks as lines

(defun display-page-breaks-as-lines ()
  "Configure font-lock to display lines with only a page break as a line."
  (if font-lock-defaults
      (font-lock-add-keywords
       nil
       '(("^\f$"
          0
          (prog1 'shadow
            (let ((line (make-overlay (match-beginning 0) (match-end 0))))
              (overlay-put line 'display (make-string fill-column ?─))
              (dolist (prop '(modification-hooks
                              insert-in-front-hooks
                              insert-behind-hooks))
                (overlay-put line prop
                             '((lambda (overlay &rest _)
                                 (delete-overlay overlay)))))))
          t)))))


;;; Inline annotations

(setq virtual-comment-default-file
      (file-name-concat user-emacs-directory "evc"))

(with-eval-after-load 'virtual-comment
  (hide-minor-mode 'virtual-comment-mode " 📝"))

(defun enable-evc-if-exists ()
  "Enable `evc' in project if its been used before."
  (when (and buffer-file-name
             (locate-dominating-file default-directory ".evc"))
    (virtual-comment-mode)))

(add-hook 'after-change-major-mode-hook #'enable-evc-if-exists)


;;; Performance

(setq-default bidi-paragraph-direction 'left-to-right)
(setq bidi-inhibit-bpa t
      auto-window-vscroll nil
      fast-but-imprecise-scrolling t
      redisplay-skip-fontification-on-input t
      auto-mode-case-fold nil
      pgtk-wait-for-event-timeout 0.001
      read-process-output-max (* 1024 1024)
      process-adaptive-read-buffering nil
      command-line-ns-option-alist nil
      remote-file-name-inhibit-cache 60)

(global-so-long-mode)


;;; Meow

(require 'meow)

(setq meow-cheatsheet-layout meow-cheatsheet-layout-qwerty
      meow-cursor-type-motion meow-cursor-type-insert
      meow-expand-hint-counts '((word . 10)
                                (line . 0)
                                (block . 0)
                                (find . 10)
                                (till . 10)))

(dolist (m '(meow-normal-mode
             meow-insert-mode
             meow-beacon-mode
             meow-keypad-mode
             meow-motion-mode))
  (hide-minor-mode m))

(defun meow-toggle-normal ()
  "Switch between normal and motion modes."
  (interactive)
  (if (meow-normal-mode-p)
      (meow-motion-mode)
    (meow-normal-mode)))

(defun meow-delete/kill ()
  "Kill if region active, else delete."
  (interactive)
  (if (use-region-p)
      (meow-kill)
    (meow-delete)))

(defun meow-backspace/clipboard-kill ()
  "Kill to clipboard if region active, else backwards delete."
  (interactive)
  (if (use-region-p)
      (meow-clipboard-kill)
    (meow-backspace)))

(defun meow-undo-only ()
  "Cancel current selection then call `undo-only'."
  (interactive)
  (when (region-active-p)
    (meow--cancel-selection))
  (undo-only))

(defvar window-traverse-map
  (let ((map (make-sparse-keymap)))
    (define-key map "h" #'windmove-left)
    (define-key map "j" #'windmove-down)
    (define-key map "k" #'windmove-up)
    (define-key map "l" #'windmove-right)
    (define-key map "s" #'other-window)
    map)
  "Keymap for moving between windows.")

(defun window-traverse ()
  "Activate window movement keymap."
  (interactive)
  (set-transient-map window-traverse-map t))

(defvar system-command-map
  (let ((map (make-sparse-keymap)))
    (define-key map "c" #'meow-clipboard-save)
    (define-key map "x" #'meow-clipboard-kill)
    (define-key map "v" #'meow-clipboard-yank)
    map)
  "Keymap for system clipboard access.")

(defvar-local meow-motion-next-function #'meow-next
  "Function to use for next in motion mode.")

(defvar-local meow-motion-prev-function #'meow-prev
  "Function to use for prev in motion mode.")

(meow-motion-overwrite-define-key
 `("j" . ,(command-var 'meow-motion-next-function))
 `("k" . ,(command-var 'meow-motion-prev-function))
 '("<escape>" . ignore))

(meow-leader-define-key
 '("j" . "H-j")
 '("k" . "H-k")
 '("1" . meow-digit-argument)
 '("2" . meow-digit-argument)
 '("3" . meow-digit-argument)
 '("4" . meow-digit-argument)
 '("5" . meow-digit-argument)
 '("6" . meow-digit-argument)
 '("7" . meow-digit-argument)
 '("8" . meow-digit-argument)
 '("9" . meow-digit-argument)
 '("0" . meow-digit-argument)
 '("-" . negative-argument)
 '("/" . meow-keypad-describe-key)
 '("?" . meow-cheatsheet)
 '("r" . rg-menu)
 '("n" . meow-toggle-normal)
 '("w" . window-traverse)
 '("i" . buffer-stats))

(meow-normal-define-key
 '("0" . meow-expand-0)
 '("1" . meow-expand-1)
 '("2" . meow-expand-2)
 '("3" . meow-expand-3)
 '("4" . meow-expand-4)
 '("5" . meow-expand-5)
 '("6" . meow-expand-6)
 '("7" . meow-expand-7)
 '("8" . meow-expand-8)
 '("9" . meow-expand-9)
 '("-" . negative-argument)
 '(";" . meow-reverse)
 '(":" . execute-extended-command)
 '("." . meow-bounds-of-thing)
 '("," . meow-inner-of-thing)
 '("<" . meow-beginning-of-thing)
 '(">" . meow-end-of-thing)
 '("[" . beginning-of-defun)
 '("]" . end-of-defun)
 '("?" . which-key-show-top-level)
 '("a" . meow-append)
 '("A" . meow-open-below)
 '("b" . meow-back-word)
 '("B" . meow-back-symbol)
 '("c" . meow-change)
 '("C" . meow-replace)
 '("d" . meow-delete/kill)
 '("D" . meow-backspace/clipboard-kill)
 '("e" . meow-next-word)
 '("E" . meow-next-symbol)
 '("f" . meow-find)
 '("g" . meow-cancel-selection)
 '("G" . meow-grab)
 '("h" . meow-left)
 '("H" . meow-left-expand)
 '("i" . meow-insert)
 '("I" . meow-open-above)
 '("j" . meow-next)
 '("J" . meow-next-expand)
 '("k" . meow-prev)
 '("K" . meow-prev-expand)
 '("l" . meow-right)
 '("L" . meow-right-expand)
 '("m" . meow-join)
 '("o" . meow-block)
 '("O" . meow-to-block)
 '("p" . meow-yank)
 '("P" . meow-clipboard-yank)
 '("q" . meow-quit)
 '("r" . query-replace-regexp)
 '("R" . replace-regexp)
 '("s" . meow-swap-grab)
 '("S" . meow-sync-grab)
 '("t" . meow-till)
 '("u" . meow-undo-only)
 '("U" . undo-redo)
 '("v" . meow-visit)
 '("V" . meow-search)
 '("w" . meow-mark-word)
 '("W" . meow-mark-symbol)
 '("x" . meow-line)
 '("X" . meow-goto-line)
 '("y" . meow-save)
 '("Y" . meow-clipboard-save)
 '("z" . meow-pop-selection)
 '("<escape>" . ignore))

(setq meow-char-thing-table '((?\( . round) (?\) . round)
                              (?\[ . square) (?\] . square)
                              (?\{ . curly) (?\} . curly)
                              (?x . line)
                              (?f . defun)
                              (?\" . string)
                              (?e . symbol)
                              (?w . window)
                              (?b . buffer)
                              (?p . paragraph)
                              (?. . sentence)))

(setq meow-thing-selection-directions '((inner . backward)
                                        (bounds . forward)
                                        (beginning . backward)
                                        (end . forward)))

(pcase-dolist (`(,k ,v) '((minibufferp meow--update-cursor-insert)
                          (meow--cursor-null-p ignore)))
  (setf (alist-get k meow-update-cursor-functions-alist) v))

(meow-global-mode)

(defvar meow-previous-selected-buffer nil
  "Last known selected buffer for deactivating insert mode.")

(defun meow-leave-insert-on-deselect (&rest _)
  "If active buffer has changed, deactivate insert mode in previous buffer."
  (unless (or (minibufferp)
              (eq meow-previous-selected-buffer (current-buffer)))
    (when (buffer-live-p meow-previous-selected-buffer)
      (with-current-buffer meow-previous-selected-buffer
        (meow-insert-exit)))
    (setq meow-previous-selected-buffer (current-buffer))))

(push #'meow-leave-insert-on-deselect window-state-change-functions)


;;; Completion

(require 'kind-icon)

(setq read-extended-command-predicate #'command-completion-default-include-p
      completion-styles '(orderless basic)
      completion-category-defaults nil
      completion-in-region-function #'consult-completion-in-region
      orderless-component-separator #'orderless-escapable-split-on-space
      completion-at-point-functions (list #'cape-file
                                          (cape-capf-super #'cape-dabbrev
                                                           #'cape-dict))
      cape-dabbrev-min-length 3
      cape-dict-file (lambda () (or (getenv "WORDLIST") "/usr/share/dict/words"))
      corfu-auto t
      corfu-auto-prefix 1
      corfu-popupinfo-delay '(0.5 . 0)
      corfu-popupinfo-hide nil
      corfu-margin-formatters '(kind-icon-margin-formatter)
      kind-icon-default-face 'corfu-default
      kind-icon-blend-background nil
      kind-icon-default-style (plist-put kind-icon-default-style ':height 0.75))

(vertico-mode)
(marginalia-mode)
(global-corfu-mode)
(corfu-popupinfo-mode)

(define-key corfu-map (kbd "RET") nil)
(define-key corfu-map (kbd "S-SPC") #'corfu-insert-separator)
(define-key corfu-map (kbd "M-p") #'corfu-popupinfo-scroll-down)
(define-key corfu-map (kbd "M-n") #'corfu-popupinfo-scroll-up)

(defun cleanup-corfu ()
  "Close corfu popup if it is active."
  (when corfu-mode (corfu-quit)))

(add-hook 'meow-insert-exit-hook #'cleanup-corfu)


;;; Spell checking

(setq jinx-camel-modes t)

(defvar-keymap my-jinx-overlay-map
  :doc "Custom keymap for spell checker errors."
  "TAB" #'jinx-correct)

(with-eval-after-load 'jinx
  (hide-minor-mode 'jinx-mode)
  (put 'jinx-overlay 'keymap my-jinx-overlay-map))

(global-jinx-mode)


;;; Tramp

(with-eval-after-load 'tramp
  (setq tramp-default-method-alist `((,tramp-local-host-regexp nil "sudo"))
        tramp-default-method "ssh")
  (add-to-list 'tramp-remote-path 'tramp-own-remote-path))


;;; Shell

(setq comint-terminfo-terminal "dumb-emacs-ansi"
      comint-prompt-read-only t
      comint-pager "cat"
      shell-highlight-undef-enable t)

(with-eval-after-load 'comint
  (define-key comint-mode-map
              [remap beginning-of-defun] #'comint-previous-prompt)
  (define-key comint-mode-map
              [remap end-of-defun] #'comint-next-prompt))

(defun set-ls-colors ()
  "Set LS_COLORS based off of eshell-ls colors."
  (let (ls-colors)
    (pcase-dolist (`(,entry ,face)
                   '(("di" eshell-ls-directory)   ; Directory
                     ("ex" eshell-ls-executable)  ; Executable
                     ("ln" eshell-ls-symlink)     ; Symlink
                     ("mi" eshell-ls-missing)     ; Missing file
                     ("pi" eshell-ls-special)     ; Named pipe
                     ("bd" eshell-ls-special)     ; Block device
                     ("cd" eshell-ls-special)     ; Char device
                     ("so" eshell-ls-special)))   ; Socket
      (load-face face)
      (let* ((face-color (face-attribute face :foreground nil t))
             (r (substring face-color 1 3))
             (g (substring face-color 3 5))
             (b (substring face-color 5 7)))
        ;; Convert to base 10
        (setq r (number-to-string (string-to-number r 16)))
        (setq g (number-to-string (string-to-number g 16)))
        (setq b (number-to-string (string-to-number b 16)))
        (setq ls-colors (concat ls-colors entry "=38;2;" r ";" g ";" b ":"))))
    (setenv "LS_COLORS" ls-colors)))

(set-ls-colors)

(advice-add #'pcomplete-completions-at-point :around #'cape-wrap-silent)
(advice-add #'pcomplete-completions-at-point :around #'cape-wrap-purify)

(coterm-mode)

(defvar-local meow-coterm-char-mode 'auto
  "Which mode coterm should use in meow insert mode.")

(defun meow-coterm-char-mode ()
  "Enable coterm char mode."
  (interactive)
  (setq meow-coterm-char-mode t)
  (when (meow-insert-mode-p)
    (coterm-auto-char-mode -1)
    (coterm-char-mode)
    (coterm-scroll-snap-mode))
  (force-mode-line-update))

(defun meow-coterm-line-mode ()
  "Enable coterm line mode."
  (interactive)
  (setq meow-coterm-char-mode nil)
  (when (meow-insert-mode-p)
    (coterm-auto-char-mode -1)
    (coterm-char-mode -1)
    (coterm-scroll-snap-mode -1))
  (force-mode-line-update))

(defun meow-coterm-auto-mode ()
  "Enable coterm auto mode."
  (interactive)
  (setq meow-coterm-char-mode 'auto)
  (when (meow-insert-mode-p)
    (coterm-auto-char-mode))
  (force-mode-line-update))

(defun meow-coterm-insert-enter ()
  "Switch keybinds to char mode if char mode set."
  (pcase meow-coterm-char-mode
    ('auto (coterm-auto-char-mode))
    ('t (coterm-char-mode)
        (coterm-scroll-snap-mode)))
  (force-mode-line-update))

(defun meow-coterm-insert-exit ()
  "Turn off coterm char mode in meow normal mode."
  (coterm-auto-char-mode -1)
  (coterm-char-mode -1)
  (coterm-scroll-snap-mode -1))

(defun meow-coterm-setup-hooks ()
  "Ensure non-char-mode keybindings outside of insert mode."
  (add-hook 'meow-insert-enter-hook #'meow-coterm-insert-enter nil t)
  (add-hook 'meow-insert-exit-hook #'meow-coterm-insert-exit nil t))

(add-hook 'comint-mode-hook #'meow-coterm-setup-hooks)

(advice-add #'coterm--init :around
            (lambda (orig-fun &rest args)
              "Advise `coterm--init' to use disable default auto mode."
              (cl-letf (((symbol-function #'coterm-auto-char-mode) #'ignore))
                (apply orig-fun args)))
            '((name . meow-coterm)))

(with-eval-after-load 'comint
  (define-key comint-mode-map (kbd "C-c ESC") #'term-send-raw)
  (define-key comint-mode-map (kbd "C-c C-j") #'meow-coterm-auto-mode)
  (define-key comint-mode-map (kbd "C-c C-S-j") #'meow-coterm-line-mode)
  (define-key comint-mode-map (kbd "C-c C-k") #'meow-coterm-char-mode))

(define-key coterm-char-mode-map [remap term-line-mode] #'meow-coterm-auto-mode)
(define-key coterm-char-mode-map [remap term-char-mode] #'meow-coterm-char-mode)

(put 'coterm-auto-char-lighter-mode-format 'risky-local-variable t)
(setq coterm-auto-char-lighter-mode-format
      '(:eval (pcase meow-coterm-char-mode
                ('auto (when coterm-char-mode " AChar"))
                ('t " Char")
                ('nil " Line"))))

(defun comint-disable-echo ()
  "Set `comint-process-echoes' to t in current buffer."
  (interactive)
  (setq comint-process-echoes t))


;;; Eshell

(setq eshell-modules-list '( eshell-basic eshell-cmpl eshell-dirs eshell-glob
                             eshell-hist eshell-ls eshell-pred eshell-prompt
                             eshell-term)
      eshell-error-if-no-glob t
      eshell-glob-include-dot-dot nil
      eshell-glob-chars-list '(?\] ?\[ ?*)
      eshell-ask-to-save-last-dir nil
      eshell-buffer-maximum-lines 5000
      eshell-history-size 2048
      eshell-hist-ignoredups t
      eshell-hist-move-to-end nil
      eshell-save-history-on-exit nil
      eshell-input-filter #'eshell-input-filter-initial-space
      eshell-cd-on-directory nil
      eshell-plain-echo-behavior t
      eshell-glob-show-progress t
      eshell-ls-archive-regexp "\\`\\'"
      eshell-ls-backup-regexp "\\`\\'"
      eshell-ls-clutter-regexp "\\`\\'"
      eshell-ls-product-regexp "\\`\\'")

(with-eval-after-load 'esh-cmd
  (dolist (v '(eshell-last-commmand-name
               eshell-last-command-status
               eshell-last-command-result))
    (make-variable-buffer-local v))
  (push #'always eshell-complex-commands))

(with-eval-after-load 'em-term
  (setq eshell-visual-commands nil))

(with-eval-after-load 'em-tramp
  (require 'tramp))

(with-eval-after-load 'esh-mode
  (push #'eshell-truncate-buffer eshell-output-filter-functions)
  (define-key eshell-mode-map
              [remap beginning-of-defun] #'eshell-previous-prompt)
  (define-key eshell-mode-map
              [remap end-of-defun] #'eshell-next-prompt))

(with-eval-after-load 'esh-var
  (nconc eshell-variable-aliases-list
         `(("/" ,(lambda () (concat (file-remote-p default-directory) "/"))
            nil t)
           ("TERM" ,(lambda () "dumb-emacs-ansi") t t))))

(add-hook 'eshell-before-prompt-hook #'eshell-begin-on-new-line)

(defun my-eshell-init ()
  "Function to run in new eshell buffers."
  (remove-hook 'eshell-exit-hook #'eshell-write-history t)
  (eat-eshell-mode)
  (fish-completion-mode)
  (setq completion-at-point-functions '(cape-file
                                        pcomplete-completions-at-point
                                        cape-dabbrev)
        mode-line-process
        '(" " (:eval (abbreviate-file-name default-directory))))
  (abbrev-mode)
  (face-remap-set-base 'nobreak-space nil)
  (buffer-disable-undo))

(add-hook 'eshell-mode-hook #'my-eshell-init)

(defun my-eshell-prompt ()
  "Eshell prompt with last error code and `#' to indicate remote directory."
  (concat (unless (eshell-exit-success-p)
            (propertize
             (number-to-string eshell-last-command-status) 'face 'error))
          (if (file-remote-p default-directory) "# " "$ ")))

(setq eshell-prompt-function #'my-eshell-prompt
      eshell-prompt-regexp "^[0-9]*[$#] ")

(defun my-eshell-save-history (input)
  "Write INPUT to eshell history file."
  (let ((inhibit-message t)
        (message-log-max nil))
    (write-region (concat input "\n") nil eshell-history-file-name t)))

(advice-add #'eshell-put-history :after #'my-eshell-save-history)

(defface eshell-input nil
  "Face used for eshell input commands."
  :group 'custom)

(defun my-eshell-highlight-last-input ()
  "Highlight last eshell command."
  (let ((ov (make-overlay eshell-last-input-start (1- eshell-last-input-end))))
    (overlay-put ov 'face 'eshell-input)))

(add-hook 'eshell-pre-command-hook #'my-eshell-highlight-last-input)

(defun eshell/e (&rest args)
  "Open files in ARGS."
  (dolist (file (reverse
                 (mapcar #'expand-file-name
                         (flatten-tree
                          (mapcar (lambda (s)
                                    (if (stringp s) (split-string s "\n") s))
                                  args)))))
    (find-file file)))

(put #'eshell/e 'eshell-no-numeric-conversions t)
(put #'eshell/e 'eshell-filename-arguments t)

(defalias #'eshell/v #'eshell-exec-visual)

(put #'eshell/v 'eshell-no-numeric-conversions t)

(with-eval-after-load 'abbrev
  (define-abbrev-table 'eshell-mode-abbrev-table
    '(("gitcl" "git clone --filter=blob:none")
      ("gitsub" "git submodule update --init --recursive --depth 1"))))

(advice-add 'eat-eshell-mode :after
            (lambda (&rest _)
              "Remove eat-eshell's terminfo path override."
              (setq eshell-variable-aliases-list
                    (delete '("TERMINFO" eat-term-terminfo-directory t)
                            eshell-variable-aliases-list)))
            '((name . eat-eshell-remove-terminfo-override)))

(advice-add 'eat-eshell-emacs-mode :around
            (lambda (orig-fun &rest args)
              "Only run if eat terminal is active."
              (when eat--terminal
                (apply orig-fun args)))
            '((name . eat-eshell-only-when-active)))

(with-eval-after-load 'eat
  (setq eat-eshell-char-mode-map
        (let ((map (eat-term-make-keymap
                    #'eat-self-input
                    '(:ascii :arrow :navigation :function)
                    '([?\C-c]))))
          (define-key map [?\C-c ?\C-c] #'eat-self-input)
          (define-key map [?\C-c ?\e] #'eat-self-input)
          map)))

(defun meow-eat-eshell-setup-hooks ()
  "Ensure non-char-mode keybindings outside of insert mode."
  (add-hook 'meow-insert-enter-hook #'eat-eshell-char-mode nil t)
  (add-hook 'meow-insert-exit-hook #'eat-eshell-emacs-mode nil t))

(add-hook 'eat-eshell-mode-hook #'meow-eat-eshell-setup-hooks)


;;; Direnv

(setq envrc-none-lighter nil
      envrc-on-lighter '(:propertize " envrc" face warning)
      envrc-error-lighter '(:propertize " envrc" face error))

(push `(,(rx bos "*envrc*" eos) always) display-buffer-alist)

(add-hook 'after-init-hook #'envrc-global-mode)

(defun eshell-update-direnv ()
  "Update direnv state when switching eshell directory."
  (when envrc-mode (envrc-mode -1))
  (and (not (file-remote-p default-directory))
       (locate-dominating-file default-directory ".envrc")
       (envrc-mode)))

(add-hook 'eshell-directory-change-hook #'eshell-update-direnv)


;;; Term

(with-eval-after-load 'term
  (set-keymap-parent term-raw-escape-map nil))

(meow-term-enable)

(defvar-local term-enable-local-echo nil
  "Whether to emulate echo for inferiors without built-in echo.")

(defun term-toggle-local-echo ()
  "Toggle emulating echo for inferiors without built-in echo."
  (declare (modes term-mode))
  (interactive)
  (setq-local term-enable-local-echo (not term-enable-local-echo)))

(defvar-local term-line-ending "\n"
  "Line ending to use for sending to process in `term-mode'.")

(defun term-line-ending-sender (proc string)
  "Function to send PROC input STRING and line ending."
  (when term-enable-local-echo
    (term-emulate-terminal proc (concat string "\r\n")))
  (term-send-string proc (concat string term-line-ending)))

(setq term-input-sender #'term-line-ending-sender)

(with-eval-after-load 'term
  (define-key term-raw-map (kbd "RET")
              (lambda ()
                "Send line ending to the buffer's current process."
                (interactive)
                (term-send-raw-string term-line-ending))))

(defun term-line-ending-send-lf ()
  "Send `\\n' as line termination."
  (declare (modes term-mode))
  (interactive)
  (setq term-line-ending "\n"))

(defun term-line-ending-send-cr ()
  "Send `\\r' as line termination."
  (declare (modes term-mode))
  (interactive)
  (setq term-line-ending "\r"))

(defun term-line-ending-send-crlf ()
  "Send `\\r\\n' as line termination."
  (declare (modes term-mode))
  (interactive)
  (setq term-line-ending "\r\n"))

(defun term-line-ending-mode-line ()
  "Get mode line string for term line ending."
  (pcase term-line-ending
    ("\n" " LF")
    ("\r" " CR")
    ("\r\n" " CRLF")))

(put 'serial-term 'interactive-form
     '(interactive
       (list (read-file-name
              "Serial port: " "/dev/" "" t nil
              (lambda (file)
                (let* ((attr (file-attributes file 'string))
                       (type (string-to-char (file-attribute-modes attr)))
                       (group (file-attribute-group-id attr)))
                  (and (= type ?c)
                       (string= group "dialout")))))
             (let ((speed (completing-read
                           "Speed: "
                           '("nil" "115200" "9600" "1200" "2400" "4800" "19200"
                             "38400" "57600"))))
               (if (string= speed "nil") nil (string-to-number speed)))
             (not current-prefix-arg))))


;;; Vterm

(setq vterm-max-scrollback 5000
      vterm-timer-delay 0.01
      vterm-kill-buffer-on-exit nil
      vterm-clear-scrollback-when-clearing t
      vterm-exit-functions '(set-mode-line-process-killed)
      vterm-keymap-exceptions '("C-c"))

(meow-vterm-enable)

(advice-add #'vterm--set-title :override
            (lambda (title)
              "Have `vterm' set `mode-line-process' to TITLE."
              (setq mode-line-process `("  " ,title)))
            '((name . vterm-set-mode-line-process)))

(defun set-mode-line-process-killed (buffer desc)
  "Indicate process killed in buffer BUFFER with reason DESC."
  (with-current-buffer buffer
    (setq mode-line-process `(:propertize ("  " ,(string-trim desc))
                                          face error))))


;;; Compilation

(defun set-term-ansi-color ()
  "Set term env variable to enable color output."
  (setenv "TERM" "dumb-emacs-ansi"))

(add-hook 'compilation-mode-hook #'set-term-ansi-color)

(add-hook 'compilation-filter-hook #'ansi-color-compilation-filter)

(setq ansi-osc-for-compilation-buffer t)

(when (>= emacs-major-version 29)
  (add-hook 'compilation-filter-hook #'ansi-osc-compilation-filter))


;;; Project

(setq project-file-history-behavior 'relativize)

(defun project-nix-store (dir)
  "Return transient project if DIR is in the nix store."
  (when (string-prefix-p "/nix/store/" dir)
    (let ((store-path (string-remove-suffix
                       (string-trim-left dir "/nix/store/[^/]+")
                       dir)))
      (cons 'transient store-path))))

(with-eval-after-load 'project
  (require 'vc-git) ; project-find-file fails if vc-git is not loaded
  (add-hook 'project-find-functions #'project-nix-store 95)
  (let ((inhibit-message t))
    (project-forget-projects-under "/nix/store/")
    (project-forget-zombie-projects)))


;;; Eglot

(setq eglot-stay-out-of '(eldoc-documentation-strategy
                          flymake-diagnostic-functions)
      eglot-ignored-server-capabilities '(:inlayHintProvider)
      eglot-autoshutdown t
      eglot-extend-to-xref t)

(advice-add #'eglot-completion-at-point :around #'cape-wrap-nonexclusive)

(with-eval-after-load 'yasnippet
  (hide-minor-mode 'yas-minor-mode)
  (setq yas-minor-mode-map (make-sparse-keymap)))

(setq yas-keymap-disable-hook (lambda () completion-in-region-mode))

(defun setup-eglot ()
  "Enable eglot and its dependencies."
  (yas-minor-mode)
  (require 'eglot)
  (add-hook 'flymake-diagnostic-functions #'eglot-flymake-backend)
  (add-hook 'hack-local-variables-hook #'eglot-ensure nil t))


;;; Vale

(setq flymake-vale-modes '( text-mode markdown-mode org-mode latex-mode
                            message-mode))

(add-hook 'find-file-hook 'flymake-vale-maybe-load)


;;; Formatting

(defvar-local format-region-function #'indent-region
  "Function to use for formatting region.")

(defvar-local format-buffer-function nil
  "Function to use for formatting buffer.")

(defun format-region ()
  "Format the current region using the configured formatter."
  (interactive)
  (if (region-active-p)
      (if format-region-function
          (funcall format-region-function
                   (region-beginning) (region-end))
        (user-error "Region formatting not supported!"))
    (format-buffer)))

(defun format-buffer ()
  "Format the current buffer using the configured formatter."
  (interactive)
  (cond (format-buffer-function
         (funcall format-buffer-function))
        (format-region-function
         (funcall format-region-function (point-min) (point-max)))))

(dolist (sym '(format-region format-buffer))
  (put sym 'completion-predicate (completion-pred (not buffer-read-only))))

(define-minor-mode format-on-save-mode
  "Minor mode for automatically formatting before saving."
  :lighter " 🧹"
  (if format-on-save-mode
      (add-hook 'before-save-hook #'format-buffer nil t)
    (remove-hook 'before-save-hook #'format-buffer t)))


;;; Transient

(setq transient-default-level 7)


;;; Magit

(setq magit-diff-refine-hunk 'all
      magit-view-git-manual-method 'man
      transient-save-history nil
      magit-save-repository-buffers 'dontask
      magit-delete-by-moving-to-trash nil
      magit-process-finish-apply-ansi-colors t
      git-commit-summary-max-length 50
      magit-no-message '("Turning on "))

(with-eval-after-load 'magit
  (remove-hook 'server-switch-hook #'magit-commit-diff)
  (magit-todos-mode))

(with-eval-after-load 'magit-commit
  (transient-replace-suffix 'magit-commit 'magit-commit-autofixup
    '("x" "Absorb changes" magit-commit-absorb)))

(defun meow-magit-movement-configure ()
  "Set j/k in motion mode for `magit'."
  (setq meow-motion-next-function #'magit-section-forward
        meow-motion-prev-function #'magit-section-backward))

(add-hook 'magit-mode-hook #'meow-magit-movement-configure)

(defun configure-git-commit-mode ()
  "Set buffer-local configurations for `git-commit-mode'."
  (setq fill-column 72))

(add-hook 'git-commit-mode-hook #'configure-git-commit-mode)

(with-eval-after-load 'project
  (require 'magit-extras))


;;; Ediff

(setq ediff-window-setup-function #'ediff-setup-windows-plain
      ediff-split-window-function #'split-window-horizontally)

(advice-add #'ediff-quit :around #'y-or-n-p-always-y-wrapper)


;;; Git-annex

(with-eval-after-load 'dired
  (require 'git-annex))


;;; Which-key

(setq which-key-idle-delay 0.5
      which-key-show-early-on-C-h t
      which-key-compute-remaps t
      which-key-sort-order 'which-key-local-then-key-order
      which-key-sort-uppercase-first nil
      which-key-unicode-correction 0
      which-key-side-window-max-height 0.5)

(which-key-mode)

(hide-minor-mode 'which-key-mode)


;;; Dired

(setq wdired-allow-to-change-permissions t)


;;; Proced

(setq proced-auto-update-interval 3)

(setq-default proced-auto-update-flag t
              proced-tree-flag t
              proced-format 'custom
              proced-filter 'non-kernel)

(with-eval-after-load 'proced
  (add-to-list 'proced-format-alist
               '(custom pid user nice pcpu pmem tree (args comm)))
  (add-to-list 'proced-filter-alist
               '(non-kernel
                 (args . (lambda (arg)
                           (not (string-match "\\`\\[.*]\\'" arg)))))))

(add-hook 'proced-mode-hook #'set-header-fixed-pitch)


;;; Eldoc

(setq eldoc-documentation-strategy #'eldoc-documentation-compose
      eldoc-echo-area-prefer-doc-buffer t
      eldoc-minor-mode-string " 📜")


;;; Flymake

(setq flymake-mode-line-format nil
      flymake-suppress-zero-counters t)

(defun enable-flymake-after-locals ()
  "Hook function for `hack-local-variables-hook' to enable `flymake'."
  (unless buffer-read-only
    (flymake-mode)))

(defun enable-flymake ()
  "Enable `flymake-mode' if buffer is modifiable."
  (add-hook 'hack-local-variables-hook
            #'enable-flymake-after-locals
            nil t))


;;; Help

(advice-add 'help-buffer :override
            (lambda ()
              "Return new buffer. Ignores `help-xref-following'."
              (get-buffer-create "*Help*"))
            '((name . help-xref-dont-reuse-buffer)))

(add-hook 'help-fns-describe-function-functions
          #'shortdoc-help-fns-examples-function)


;;; Info

(setq Info-additional-directory-list load-path)

(add-hook 'Info-mode-hook #'variable-pitch-mode)

(defun meow-info-movement-configure ()
  "Set j/k in motion mode for `Info-mode'."
  (setq meow-motion-next-function #'Info-scroll-up
        meow-motion-prev-function #'Info-scroll-down))

(add-hook 'Info-mode-hook #'meow-info-movement-configure)

(font-lock-add-keywords
 'Info-mode
 '(("^[ -]*" 0 'fixed-pitch append)
   ("^        .*" 0 'fixed-pitch append)))


;;; Man

(setq Man-width-max nil)

(add-hook 'Man-mode-hook #'variable-pitch-mode)

;; Use monospace for lines with box-drawing characters
(font-lock-add-keywords
 'Man-mode
 '(("^.*[\u2500-\u257F].*" 0 'fixed-pitch append)))


;;; Shortdoc

(add-hook 'shortdoc-mode-hook #'variable-pitch-mode)

(font-lock-add-keywords
 'shortdoc-mode
 '(("^ *" 0 'fixed-pitch append)
   (" ?[(⇒→].*" 0 'fixed-pitch append)
   ("^[a-zA-Z].*" 0 'info-title-3 append)))

(setf (alist-get 'shortdoc-mode meow-mode-state-list) 'normal)


;;; Elisp

(setq elisp-flymake-byte-compile-load-path
      (append elisp-flymake-byte-compile-load-path load-path))

(add-hook 'emacs-lisp-mode-hook #'display-page-breaks-as-lines)
(add-hook 'emacs-lisp-mode-hook #'enable-flymake)
(add-hook 'emacs-lisp-mode-hook #'format-on-save-mode)

(advice-add 'elisp--company-doc-buffer :around
            (lambda (orig-fun &rest args)
              "Use different help buffer for completion docs."
              (cl-letf (((symbol-function #'help-buffer)
                         (lambda ()
                           (get-buffer-create " *help-company-doc-buffer*"))))
                (apply orig-fun args)))
            '((name . custom-help-buffer)))

(defun theme-enable-rainbow-mode ()
  "Enable `rainbow-mode' in Emacs themes."
  (when (and buffer-file-name
             (string-match-p "-theme\\.el$" buffer-file-name))
    (rainbow-mode)))

(add-hook 'emacs-lisp-mode-hook #'theme-enable-rainbow-mode)

(dir-locals-set-class-variables
 'elpa-src '((nil . ((buffer-read-only . t)))))

(dir-locals-set-directory-class
 (file-name-concat user-emacs-directory "elpa") 'elpa-src)


;;; Org

(setq org-elipsis " ▼"
      org-babel-load-languages '((emacs-lisp . t)
                                 (C . t)
                                 (shell . t)))

(defun org-babel-apply-ansi-color ()
  "Hook function to apply ansi colors to `org-babel' result."
  (defvar ansi-color-context-region)
  (let ((ansi-color-context-region nil))
    (save-excursion
      (goto-char (org-babel-where-is-src-block-result))
      (ansi-color-apply-on-region (point) (org-babel-result-end)))))

(add-hook 'org-babel-after-execute-hook #'org-babel-apply-ansi-color)

(add-hook 'org-mode-hook #'flymake-mode)


;;; Markdown

(setq markdown-asymmetric-header t
      markdown-fontify-code-blocks-natively t
      markdown-ordered-list-enumeration nil
      markdown-unordered-list-item-prefix nil
      markdown-disable-tooltip-prompt t
      markdown-command '("pandoc" "--from=markdown" "--to=html5"))

(advice-add 'markdown-fontify-hrs :around
            (lambda (orig-fun &rest args)
              "Use `fill-column' for hr width."
              (cl-letf (((symbol-function #'window-body-width)
                         (lambda (&rest _) (1+ fill-column))))
                (apply orig-fun args)))
            '((name . fixed-hr-length)))

(defun markdown-set-page-delimiter ()
  "Set `page-delimiter' to a markdown thematic break."
  (setq page-delimiter markdown-regex-hr))

(add-hook 'markdown-mode-hook #'markdown-set-page-delimiter)
(add-hook 'markdown-mode-hook #'flymake-mode)


;;; Nix

(reformatter-define nix-fmt-format
  :program "nix"
  :args `("fmt" ,input-file)
  :stdin nil
  :stdout nil
  :input-file (reformatter-temp-file-in-current-directory ".nix")
  :mode nil)

(defun nix-formatter-configure ()
  "Configure formatters for Nix files."
  (when (zerop (process-file-shell-command
                "nix eval .#formatter --apply 'x: assert x != {}; true'"))
    (setq format-region-function #'indent-region
          format-buffer-function #'nix-fmt-format-buffer)
    (format-on-save-mode)))

(add-hook 'nix-mode-hook #'setup-eglot)
(add-hook 'nix-mode-hook #'nix-formatter-configure)

(dolist (sym '(nix-mode-format nix-format-buffer))
  (put sym 'completion-predicate #'ignore))

(defun nix-shebang-set-shell-type ()
  "Set `sh-mode' shell type to `nix-shell' interpreter."
  (when (save-excursion (goto-char (point-min))
                        (looking-at "#! */usr/bin/env nix-shell"))
    (sh-set-shell (nix-shebang-get-interpreter))
    (add-hook 'hack-local-variables-hook #'nix-shebang-set-shell-type nil t)))

(add-hook 'sh-mode-hook #'nix-shebang-set-shell-type)

(autoload 'nix-shebang-mode "nix-shebang" nil t)
(add-to-list 'interpreter-mode-alist '("nix-shell" . nix-shebang-mode))

(add-hook 'nix-repl-mode-hook #'comint-disable-echo)


;;; Scheme

(setq geiser-repl-per-project-p t
      geiser-mode-start-repl-p t)


;;; Rust

(setq rust-format-on-save nil
      rust-prettify-symbols-alist '(("<=" . ?≤)  (">=" . ?≥) ("!=" . ?≠)
                                    ("->" . ?→) ("=>" . ?⇒)))

(with-eval-after-load 'eglot
  (push-default '(rust-analyzer (checkOnSave (command . "clippy")))
                eglot-workspace-configuration))

(defun rust-formatter-configure ()
  "Configure formatters for Rust files."
  (setq format-region-function #'indent-region
        format-buffer-function #'rust-format-buffer)
  (format-on-save-mode))

(add-hook 'rust-mode-hook #'setup-eglot)
(add-hook 'rust-mode-hook #'rust-formatter-configure)
(add-hook 'rust-mode-hook #'cargo-minor-mode)

(add-hook 'toml-mode-hook #'cargo-minor-mode)

(with-eval-after-load 'cargo
  (hide-minor-mode 'cargo-minor-mode))

(dolist (sym '(rust-enable-format-on-save rust-disable-format-on-save))
  (put sym 'completion-predicate #'ignore))


;;; C/C++

(defvar-local clang-format-enabled nil
  "Whether `clang-format' commands should be available in buffer.")

(defun c-formatter-configure ()
  "Configure formatters for C and C++ files."
  (when (locate-dominating-file default-directory ".clang-format")
    (setq clang-format-enabled t
          format-region-function #'clang-format-region
          format-buffer-function #'clang-format-buffer)
    (format-on-save-mode)))

(dolist (sym '(clang-format-region clang-format-buffer))
  (put sym 'completion-predicate (completion-pred clang-format-enabled)))

(put 'clang-format 'completion-predicate #'ignore)

(with-eval-after-load 'cc-mode
  (setf (alist-get 'other c-default-style) "stroustrup"))

(defun c-set-extern-offset-0 ()
  "Set the indentation for extern blocks to 0."
  (setf (alist-get 'inextern-lang c-offsets-alist) [0]))

;; Hook is used to ensure highlighting is applied after rainbow delimiters.
(defun set-c-mode-font-overrides ()
  "Enable custom `c-mode' highlighting in the current buffer."
  (font-lock-add-keywords
   nil
   '(("#include \\(.*\\)" 1 'font-lock-constant-face t))
   'append))

(defun c-prettify-configure ()
  "Configure `pretty-symbols-alist' for `c-mode'."
  (setq prettify-symbols-alist '(("<=" . ?≤) (">=" . ?≥) ("!=" . ?≠))))

(add-hook 'c-mode-hook #'set-c-mode-font-overrides)
(add-hook 'c-mode-hook #'setup-eglot)
(add-hook 'c-mode-hook #'c-formatter-configure)
(add-hook 'c-mode-hook #'c-prettify-configure)
(add-hook 'c-mode-hook #'c-set-extern-offset-0)

(add-hook 'c++-mode-hook #'set-c-mode-font-overrides)
(add-hook 'c++-mode-hook #'setup-eglot)
(add-hook 'c++-mode-hook #'c-formatter-configure)


;;; Python

(add-hook 'python-mode-hook #'setup-eglot)

(defun ipython ()
  "Run ipython in vterm."
  (interactive)
  (defvar vterm-shell)
  (let ((vterm-shell "ipython"))
    (vterm-other-window)))


;;; Zig

(setq zig-format-on-save nil)

(defun zig-formatter-configure ()
  "Configure formatters for Zig files."
  (setq format-region-function #'indent-region
        format-buffer-function #'zig-format-buffer)
  (format-on-save-mode))

(add-hook 'zig-mode-hook #'setup-eglot)
(add-hook 'zig-mode-hook #'zig-formatter-configure)

(put 'zig-toggle-format-on-save 'completion-predicate #'ignore)


;;; Haskell

(setq haskell-process-suggest-remove-import-lines t
      haskell-process-auto-import-loaded-modules t
      haskell-process-log t)

(defun haskell-formatter-configure ()
  "Configure formatters for Haskell files."
  (setq format-region-function nil
        format-buffer-function #'haskell-mode-stylish-buffer)
  (format-on-save-mode))

(add-hook 'haskell-mode-hook #'interactive-haskell-mode)
(add-hook 'haskell-mode-hook #'setup-eglot)
(add-hook 'haskell-mode-hook #'haskell-formatter-configure)


;;; Sh

(add-hook 'sh-mode-hook #'flymake-mode)


;;; PDF

(pdf-loader-install)

(with-eval-after-load 'pdf-view
  (hide-minor-mode 'pdf-view-midnight-minor-mode))


;;; Present

(defun narrow-prior-page ()
  "Widen then narrow to the previous page."
  (interactive)
  (let ((inhibit-redisplay t))
    (widen)
    (backward-page 2)
    (narrow-to-page)))

(defun narrow-next-page ()
  "Widen then narrow to the next page."
  (interactive)
  (let ((inhibit-redisplay t))
    (widen)
    (forward-page)
    (narrow-to-page)))

(defvar presentation-mode--exit-hook nil
  "Hook run when exiting `presentation-mode'.")

(define-minor-mode presentation-mode
  "Present a buffer as a slideshow, delimiting with page breaks."
  :lighter " Present"
  :keymap (let ((map (make-sparse-keymap)))
            (define-key map (kbd "<prior>") #'narrow-prior-page)
            (define-key map (kbd "<next>") #'narrow-next-page)
            map)
  (if presentation-mode
      (let ((inhibit-redisplay t))
        (text-scale-set 5)
        (when display-fill-column-indicator-mode
          (display-fill-column-indicator-mode -1)
          (add-hook 'presentation-mode--exit-hook
                    #'display-fill-column-indicator-mode nil t))
        (when flyspell-mode
          (flyspell-mode -1)
          (add-hook 'presentation-mode--exit-hook
                    #'flyspell-mode nil t))
        (when (eq major-mode 'markdown-mode)
          (unless markdown-hide-markup
            (markdown-toggle-markup-hiding 1)
            (add-hook 'presentation-mode--exit-hook
                      (lambda () (markdown-toggle-markup-hiding -1)) nil t))
          (unless markdown-header-scaling
            (markdown-update-header-faces t)
            (add-hook 'presentation-mode--exit-hook
                      #'markdown-update-header-faces nil t))
          (markdown-display-inline-images))
        (when (eq major-mode 'org-mode)
          (unless (and (boundp 'org-indent-mode)
                       org-indent-mode)
            (org-indent-mode)
            (add-hook 'presentation-mode--exit-hook
                      (lambda () (org-indent-mode -1)) nil t))
          (org-display-inline-images))
        (narrow-to-page))
    (let ((inhibit-redisplay t))
      (widen)
      (text-scale-set 0)
      (run-hooks 'presentation-mode--exit-hook)
      (setq presentation-mode--exit-hook nil))))


;;; Commands

(defun reload-buffer ()
  "Kill current buffer and reopen its visited file."
  (interactive)
  (let ((file buffer-file-name)
        (prev-point (point))
        (prev-window-start (window-start))
        (inhibit-redisplay t))
    (kill-buffer)
    (find-file file)
    (goto-char prev-point)
    (set-window-start nil prev-window-start)))

(defun pin-buffer ()
  "Toggle whether current window is dedicated to its buffer."
  (interactive)
  (set-window-dedicated-p (selected-window) (not (window-dedicated-p))))

(defun buffer-stats ()
  "Message info about buffer/point/region size/position/etc."
  (interactive)
  (message
   (concat "Point: line %d, col %d, pos %d\n"
           "Buffer: %d chars, %d lines"
           (when (region-active-p)
             (let* ((region-lines (count-lines (region-beginning) (region-end)))
                    (start-line (count-lines (point-min) (region-beginning)))
                    (end-line (1- (+ region-lines start-line)))
                    (start-col (save-excursion
                                 (set-window-point nil (region-beginning))
                                 (current-column)))
                    (end-col (save-excursion
                               (set-window-point nil (region-end))
                               (current-column))))
               (format "\nRegion: %d chars, %d lines, %d cols [%d:%d - %d:%d]"
                       (- (region-end) (region-beginning))
                       region-lines (- end-col start-col)
                       start-line start-col
                       end-line end-col))))
   (1+ (array-current-line)) (current-column) (point)
   (buffer-size) (count-lines (point-min) (point-max))))

(defun apply-ansi-colors-on-buffer ()
  "Apply ansi color sequences in the current buffer."
  (interactive)
  (ansi-color-apply-on-region (point-min) (point-max)))


;;; Local configuration

(let ((file (file-name-concat user-emacs-directory "local-init.el")))
  (if (file-exists-p file)
      (load-file file)))


;;; Server

(require 'server)

(unless (daemonp)
  (setq server-name (concat server-name (number-to-string (emacs-pid))))
  (server-start))

(setenv "EMACS_SOCKET_NAME" (expand-file-name server-name server-socket-dir))
(setenv "EDITOR" "emacsclient")
(setenv "VISUAL" "emacsclient")


;;; Garbage collect when idle

(setq gcmh-idle-delay 'auto
      gcmh-auto-idle-delay-factor 10
      gcmh-high-cons-threshold (* 32 1024 1024))

(gcmh-mode)

(hide-minor-mode 'gcmh-mode)


;; Local Variables:
;; byte-compile-warnings: (not free-vars unresolved)
;; End:

(provide 'init)
;;; init.el ends here
