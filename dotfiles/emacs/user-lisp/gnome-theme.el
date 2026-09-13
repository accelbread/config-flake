;;; gnome-theme.el --- Emacs Gnome theme -*- lexical-binding: t; -*-

;; Copyright (C) Archit Gupta <archit@accelbread.com>
;; SPDX-License-Identifier: GPL-3.0-or-later
;; Version: 0
;; Package-Requires: ((emacs "31.1"))

;;; Commentary:

;; Emacs theme based off of Gnome's Adwaita theme.
;; Also borrows from GtkSourceView and Gnome Console.

;;; Code:

(require 'cl-lib)
(require 'color)

(defgroup gnome-theme nil
  "Gnome theme settings."
  :group 'faces)

(defconst gt--diff-keywords
  '(("^diff .*\n" (0 'diff-file-header t))
    ("^--- .*\n" (0 'diff-file-header t))
    ("^\\+\\+\\+ .*\n" (0 'diff-file-header t))
    ("^index .*\n" (0 'diff-index t))
    ("^\\(?:new\\|deleted\\) file mode .*\n" (0 'diff-index t))
    ("^@@.*\n" (0 'diff-header t))))

(defun gt--diff-set-face-overrides (&optional remove)
  "Match diff syntax highlighting to GtkSourceView.
REMOVE non-nil removes the customizations instead."
  (font-lock-remove-keywords nil gt--diff-keywords)
  (unless remove
    (font-lock-add-keywords nil gt--diff-keywords 'append)))

(define-minor-mode gnome-theme-mode
  "Minor mode for gnome-theme customizations."
  :global t :group 'gnome-theme
  (cl-letf (((symbol-function 'gnome-theme-mode) #'ignore))
    (if gnome-theme-mode
        (enable-theme 'gnome)
      (disable-theme 'gnome)))
  (if gnome-theme-mode
      (add-hook 'diff-mode-hook #'gt--diff-set-face-overrides)
    (remove-hook 'diff-mode-hook #'gt--diff-set-face-overrides))
  (dolist (buffer (buffer-list))
    (with-current-buffer buffer
      (when (derived-mode-p 'diff-mode)
        (gt--diff-set-face-overrides (not gnome-theme-mode))
        (when font-lock-mode (font-lock-flush))))))

(deftheme gnome
  "Theme matching Gnome styling."
  :background-mode 'dark
  :kind 'color-scheme)

(defun gt--rgb (color)
  "Convert COLOR to normalized sRGB triple."
  (mapcar (lambda (component) (/ component 65535.0))
          (color-values-from-color-spec color)))

(defun gt--hex (rgb)
  "Convert normalized sRGB tripple RGB to hex string."
  (apply #'format "#%02x%02x%02x"
         (mapcar (lambda (component)
                   (min 255 (max 0 (floor (+ (* component 255) 0.5)))))
                 rgb)))

(defun gnome-theme-mix (foreground background alpha)
  "Blend FOREGROUND into BACKGROUND at ALPHA ratio."
  (gt--hex (color-blend (gt--rgb foreground)
                        (gt--rgb background)
                        alpha)))

(defun gnome-theme-standalone (color)
  "Convert COLOR to Adwaita standalone variant."
  (let ((oklab (apply #'color-srgb-to-oklab
                      (gt--rgb color))))
    (gt--hex (apply #'color-oklab-to-srgb
                    (cons (max 0.85 (car oklab)) (cdr oklab))))))

;; Colors from libadwaita
(defconst gt-accent-blue "#3584e4")
(defconst gt-accent-teal "#2190a4")
(defconst gt-accent-green "#3a944a")
(defconst gt-accent-yellow "#c88800")
(defconst gt-accent-orange "#ed5b00")
(defconst gt-accent-red "#e62d42")
(defconst gt-accent-pink "#d56199")
(defconst gt-accent-purple "#9141ac")
(defconst gt-accent-slate "#6f8396")
(defvar gt-accent-bg-color nil)
(defconst gt-accent-fg-color "#ffffff")
(defvar gt-accent-color nil)
(defconst gt-destructive-bg-color "#c01c28")
(defconst gt-destructive-fg-color "#ffffff")
(defconst gt-destructive-color (gt-standalone gt-destructive-bg-color)) ; #ff938b
(defconst gt-success-bg-color "#26a269")
(defconst gt-success-fg-color "#ffffff")
(defconst gt-success-color (gt-standalone gt-success-bg-color)) ; #78e9ab
(defconst gt-warning-bg-color "#cd9309")
(defconst gt-warning-fg-color "#291d02")
(defconst gt-warning-color (gt-standalone gt-warning-bg-color)) ; #ffc252
(defconst gt-error-bg-color "#c01c28")
(defconst gt-error-fg-color "#ffffff")
(defconst gt-error-color (gt-standalone gt-error-bg-color)) ; #ff938b
(defconst gt-window-bg-color "#222226")
(defconst gt-window-fg-color "#ffffff")
(defconst gt-view-bg-color "#1d1d20")
(defconst gt-view-fg-color "#ffffff")
(defconst gt-headerbar-bg-color "#2e2e32")
(defconst gt-headerbar-fg-color "#ffffff")
(defconst gt-headerbar-backdrop-color gt-window-bg-color) ; #222226
(defconst gt-sidebar-bg-color "#2e2e32")
(defconst gt-sidebar-fg-color "#ffffff")
(defconst gt-secondary-sidebar-bg-color "#28282c")
(defconst gt-secondary-sidebar-fg-color "#ffffff")
(defconst gt-button-color (gt-mix gt-view-fg-color gt-view-bg-color 0.1)) ; #343436
(defconst gt-button-hover-color (gt-mix gt-view-fg-color gt-view-bg-color 0.15)) ; #3f3f41
(defconst gt-button-active-color (gt-mix gt-view-fg-color gt-view-bg-color 0.3)) ; #616163
(defconst gt-selected-hover-color (gt-mix gt-view-fg-color gt-view-bg-color 0.13)) ; #3a3a3d
(defvar gt-link-visited-color nil)
(defconst gt-disabled-color (gt-mix gt-view-fg-color gt-view-bg-color 0.5)) ; #8e8e90
(defvar gt-view-selected-color nil)
(defconst gt-blue-1 "#99c1f1")
(defconst gt-blue-2 "#62a0ea")
(defconst gt-blue-3 "#3584e4")
(defconst gt-blue-4 "#1c71d8")
(defconst gt-blue-5 "#1a5fb4")
(defconst gt-green-1 "#8ff0a4")
(defconst gt-green-2 "#57e389")
(defconst gt-green-3 "#33d17a")
(defconst gt-green-4 "#2ec27e")
(defconst gt-green-5 "#26a269")
(defconst gt-yellow-1 "#f9f06b")
(defconst gt-yellow-2 "#f8e45c")
(defconst gt-yellow-3 "#f6d32d")
(defconst gt-yellow-4 "#f5c211")
(defconst gt-yellow-5 "#e5a50a")
(defconst gt-orange-1 "#ffbe6f")
(defconst gt-orange-2 "#ffa348")
(defconst gt-orange-3 "#ff7800")
(defconst gt-orange-4 "#e66100")
(defconst gt-orange-5 "#c64600")
(defconst gt-red-1 "#f66151")
(defconst gt-red-2 "#ed333b")
(defconst gt-red-3 "#e01b24")
(defconst gt-red-4 "#c01c28")
(defconst gt-red-5 "#a51d2d")
(defconst gt-purple-1 "#dc8add")
(defconst gt-purple-2 "#c061cb")
(defconst gt-purple-3 "#9141ac")
(defconst gt-purple-4 "#813d9c")
(defconst gt-purple-5 "#613583")
(defconst gt-brown-1 "#cdab8f")
(defconst gt-brown-2 "#b5835a")
(defconst gt-brown-3 "#986a44")
(defconst gt-brown-4 "#865e3c")
(defconst gt-brown-5 "#63452c")
(defconst gt-light-1 "#ffffff")
(defconst gt-light-2 "#f6f5f4")
(defconst gt-light-3 "#deddda")
(defconst gt-light-4 "#c0bfbc")
(defconst gt-light-5 "#9a9996")
(defconst gt-dark-1 "#77767b")
(defconst gt-dark-2 "#5e5c64")
(defconst gt-dark-3 "#3d3846")
(defconst gt-dark-4 "#241f31")
(defconst gt-dark-5 "#000000")
;; Colors from GtkSourceView's Adwaita style scheme.
(defconst gt-teal-1 "#93ddc2")
(defconst gt-teal-2 "#5bc8af")
(defconst gt-teal-3 "#33b2a4")
(defconst gt-teal-4 "#26a1a2")
(defconst gt-teal-5 "#218787")
(defconst gt-violet-2 "#7d8ac7")
(defconst gt-violet-3 "#6362c8")
(defconst gt-violet-4 "#4e57ba")
(defconst gt-source-text-fg-color "#c0bfbc")
(defconst gt-source-search-fg-color "#242424")
(defconst gt-search-match-color (gt-mix gt-yellow-3 gt-view-bg-color 0.5)) ; #8a7827
(defconst gt-source-current-line-bg-color "#242428")
(defconst gt-source-diff-added-line-fg-color gt-teal-3)
(defconst gt-source-diff-changed-line-fg-color gt-orange-3)
(defconst gt-source-diff-file-fg-color gt-violet-2)
(defconst gt-source-diff-location-fg-color gt-yellow-4)
(defconst gt-source-diff-removed-line-fg-color gt-red-1)

(defun gt--update-accent-colors (color)
  "Update accent-derived color variables to COLOR."
  (setq gt-accent-bg-color (pcase color
                             ('blue gt-accent-blue)
                             ('teal gt-accent-teal)
                             ('green gt-accent-green)
                             ('yellow gt-accent-yellow)
                             ('orange gt-accent-orange)
                             ('red gt-accent-red)
                             ('pink gt-accent-pink)
                             ('purple gt-accent-purple)
                             ('slate gt-accent-slate))
        gt-accent-color (gt-standalone gt-accent-bg-color)
        gt-link-visited-color (gt-mix gt-accent-color gt-view-fg-color 0.8)
        gt-view-selected-color (gt-mix gt-accent-bg-color gt-view-bg-color 0.25)))

(defun gt--set-faces ()
  "Update face configuration for Gnome theme."
  (custom-theme-set-faces
   'gnome
   `(default ((t ( :background ,gt-view-bg-color
                   :foreground ,gt-view-fg-color
                   :family "Adwaita Mono"))))
   '(fixed-pitch ((t (:family "Adwaita Mono"))))
   '(fixed-pitch-serif ((t (:inherit (fixed-pitch)))))
   '(variable-pitch ((t (:family "Adwaita Sans"))))
   '(variable-pitch-text ((t (:inherit (variable-pitch)))))
   `(cursor ((t (:background ,gt-view-fg-color))))
   `(homoglyph ((t (:foreground ,gt-warning-color :inherit (bold)))))
   '(escape-glyph ((t (:inherit (homoglyph)))))
   `(minibuffer-prompt ((t (:foreground ,gt-accent-color))))
   `(highlight ((t (:background ,gt-selected-hover-color))))
   `(hl-line ((t (:extend t :background ,gt-source-current-line-bg-color))))
   `(widget-field ((t ( :foreground ,gt-view-fg-color
                        :background ,gt-button-color
                        :box (:line-width (4 . 2) :color ,gt-button-color)
                        :extend t))))
   `(custom-button ((t ( :weight bold
                         :foreground ,gt-view-fg-color
                         :background ,gt-button-color
                         :underline (:color ,gt-view-bg-color :position t)
                         :box (:line-width (4 . 2) :style flat-button)))))
   `(custom-button-mouse ((t ( :inherit (custom-button)
                               :background ,gt-button-hover-color))))
   `(custom-button-pressed ((t ( :inherit (custom-button)
                                 :background ,gt-button-active-color))))
   '(custom-comment ((t (:extend nil :inherit (widget-field)))))
   '(custom-comment-tag ((t (:inherit (default)))))
   `(custom-state ((t (:foreground ,gt-success-color))))
   `(custom-variable-tag ((t ( :weight bold
                               :foreground ,gt-accent-color))))
   `(custom-variable-obsolete ((t (:foreground ,gt-disabled-color))))
   `(custom-group-tag ((t ( :weight bold
                            :height 1.2
                            :foreground ,gt-accent-color
                            :inherit (variable-pitch)))))
   `(region ((t ( :extend nil
                  :background ,(gt-mix gt-accent-bg-color gt-view-bg-color 0.3)))))
   `(shadow ((t (:foreground ,gt-disabled-color))))
   `(warning ((t (:weight bold :foreground ,gt-warning-color))))
   `(success ((t (:weight bold :foreground ,gt-success-color))))
   `(error ((t (:weight bold :foreground ,gt-error-color))))
   `(secondary-selection
     ((t ( :extend nil
           :background ,(gt-mix gt-view-fg-color gt-view-bg-color 0.1))))) ; #343436
   `(trailing-whitespace ((t (:background ,gt-dark-3))))
   `(font-lock-builtin-face ((t (:foreground ,gt-yellow-1))))
   '(font-lock-comment-delimiter-face ((default (:inherit (font-lock-comment-face)))))
   `(font-lock-comment-face ((t (:foreground ,gt-light-5 :extend t))))
   `(font-lock-constant-face ((t (:foreground ,gt-orange-1))))
   `(font-lock-doc-face ((t (:foreground ,gt-blue-1 :extend t))))
   `(font-lock-doc-markup-face ((t (:inherit (font-lock-constant-face)))))
   `(font-lock-function-name-face ((t (:foreground ,gt-blue-2))))
   `(font-lock-keyword-face ((t (:foreground ,gt-purple-1))))
   '(font-lock-negation-char-face ((t (:inherit (homoglyph)))))
   `(font-lock-preprocessor-face ((t (:foreground ,gt-brown-2 :inherit (bold)))))
   `(font-lock-regexp-grouping-backslash ((t (:foreground ,gt-orange-1))))
   `(font-lock-regexp-grouping-construct ((t (:foreground ,gt-orange-1))))
   `(font-lock-string-face ((t (:foreground ,gt-green-2))))
   `(font-lock-type-face ((t (:foreground ,gt-teal-2))))
   `(font-lock-variable-name-face ((t (:foreground ,gt-brown-1))))
   '(font-lock-warning-face ((t (:inherit (warning)))))
   `(elisp-free-variable ((t (:underline (:color ,gt-light-4 :style line)))))
   `(elisp-shadowed-variable ((t ( :inherit (elisp-bound-variable)
                                   :underline (:color ,gt-light-4 :style line)))))
   `(link ((t ( :weight bold
                :underline (:color foreground-color :style line)
                :foreground ,gt-accent-color))))
   `(link-visited ((t (:foreground ,gt-link-visited-color))))
   `(fringe ((t (:foreground ,gt-accent-color))))
   '(header-line ((t (:inherit (mode-line)))))
   '(header-line-inactive ((t (:inherit (mode-line-inactive)))))
   `(mode-line ((t ( :box ( :line-width (-1 . 4)
                            :color ,gt-headerbar-bg-color
                            :style nil)
                     :background ,gt-headerbar-bg-color
                     :foreground ,gt-headerbar-fg-color
                     :inherit (variable-pitch)))))
   `(mode-line-inactive ((t ( :box ( :line-width (-1 . 4)
                                     :color ,gt-headerbar-backdrop-color
                                     :style nil)
                              :background ,gt-headerbar-backdrop-color
                              :foreground ,(gt-mix gt-headerbar-fg-color
                                                   gt-headerbar-backdrop-color
                                                   0.5) ; #919193
                              :inherit (mode-line)))))
   '(mode-line-buffer-id ((t (:weight bold))))
   `(mode-line-emphasis ((t (:foreground ,gt-accent-color))))
   `(mode-line-highlight
     ((t (:background ,(gt-mix gt-headerbar-fg-color gt-headerbar-bg-color 0.15))))) ; #4d4d50
   '(eglot-mode-line ((t (:inherit (fringe)))))
   '(tab-bar ((t (:inherit (mode-line)))))
   '(tab-bar-tab ((t (:inherit (mode-line)))))
   '(tab-bar-tab-inactive ((t (:inherit (mode-line-inactive)))))
   `(window-divider ((t (:foreground ,gt-headerbar-backdrop-color))))
   '(window-divider-first-pixel ((t (:inherit (window-divider)))))
   '(window-divider-last-pixel ((t (:inherit (window-divider)))))
   '(transient-key-exit ((t (:inherit (font-lock-function-name-face)))))
   '(transient-key-stay ((t (:inherit (font-lock-variable-name-face)))))
   '(transient-key-return ((t (:inherit (font-lock-warning-face)))))
   '(isearch ((t (:weight bold :inherit (lazy-highlight)))))
   `(isearch-fail ((t ( :weight bold
                        :foreground ,gt-error-fg-color
                        :background ,gt-error-bg-color))))
   `(lazy-highlight ((t ( :foreground ,gt-source-search-fg-color
                          :background ,gt-search-match-color))))
   '(next-error ((t (:inherit (region)))))
   '(query-replace ((t (:inherit (isearch)))))
   '(whitespace-tab ((t (:inherit (shadow)))))
   '(whitespace-trailing ((t (:inherit (secondary-selection)))))
   '(whitespace-missing-newline-at-eof ((t (:inherit (isearch-fail)))))
   '(page-break-lines ((t (:inherit (shadow)))))
   `(flyspell-incorrect
     ((t (:underline (:style wave :color ,gt-error-bg-color)))))
   `(flyspell-duplicate
     ((t (:underline (:style wave :color ,gt-warning-bg-color)))))
   `(Man-overstrike
     ((t (:foreground ,gt-accent-color :inherit (bold fixed-pitch)))))
   `(Man-underline
     ((t (:foreground ,gt-accent-color :inherit (italic fixed-pitch)))))
   '(woman-bold ((t (:inherit (Man-overstrike)))))
   '(woman-italic ((t (:inherit (Man-underline)))))
   '(dired-broken-symlink ((t (:inherit (error)))))
   `(dired-directory ((t (:foreground ,gt-blue-2))))
   '(dired-flagged ((t (:strike-through t :inherit (error)))))
   `(dired-header ((t (:weight bold :foreground ,gt-accent-color))))
   `(dired-mark ((t (:foreground ,gt-accent-color))))
   `(dired-marked ((t ( :foreground ,gt-view-fg-color
                        :background ,gt-view-selected-color))))
   '(dired-perm-write ((t (:inherit (font-lock-function-name-face)))))
   '(dired-special ((t (:inherit (font-lock-keyword-face)))))
   '(dired-symlink ((t (:inherit (font-lock-variable-name-face)))))
   `(diff-header ((t ( :extend t
                       :foreground ,gt-source-diff-location-fg-color
                       :background ,gt-button-color))))
   `(diff-file-header ((t ( :extend t
                            :weight bold
                            :foreground ,gt-source-diff-file-fg-color))))
   `(diff-index ((t (:extend t :foreground ,gt-dark-1))))
   `(diff-context ((t ( :extend t
                        :foreground ,gt-source-text-fg-color
                        :background ,gt-view-bg-color))))
   `(diff-removed ((t ( :extend t
                        :foreground ,gt-source-diff-removed-line-fg-color
                        :background ,gt-view-bg-color))))
   `(diff-added ((t ( :extend t
                      :foreground ,gt-source-diff-added-line-fg-color
                      :background ,gt-view-bg-color))))
   `(diff-changed ((t ( :extend t
                        :foreground ,gt-source-diff-changed-line-fg-color
                        :background ,gt-view-bg-color))))
   `(diff-changed-unspecified
     ((t ( :extend t
           :foreground ,gt-source-diff-changed-line-fg-color
           :background ,gt-view-bg-color))))
   `(diff-indicator-removed
     ((t (:foreground ,gt-source-diff-removed-line-fg-color))))
   `(diff-indicator-added
     ((t (:foreground ,gt-source-diff-added-line-fg-color))))
   `(diff-indicator-changed
     ((t (:foreground ,gt-source-diff-changed-line-fg-color))))
   '(diff-error ((t (:inherit (error)))))
   `(ediff-current-diff-A
     ((t (:extend t :background ,(gt-mix gt-red-5 gt-view-bg-color 0.25)))))
   `(ediff-current-diff-B
     ((t (:extend t :background ,(gt-mix gt-teal-5 gt-view-bg-color 0.25)))))
   `(ediff-current-diff-C
     ((t (:extend t :background ,(gt-mix gt-orange-5 gt-view-bg-color 0.25)))))
   `(ediff-current-diff-Ancestor
     ((t (:extend t :background ,(gt-mix gt-blue-5 gt-view-bg-color 0.25)))))
   `(ediff-fine-diff-A
     ((t (:background ,(gt-mix gt-source-diff-removed-line-fg-color
                               gt-source-current-line-bg-color
                               0.25)))))
   `(ediff-fine-diff-B
     ((t (:background ,(gt-mix gt-source-diff-added-line-fg-color
                               gt-source-current-line-bg-color
                               0.25)))))
   `(ediff-fine-diff-C
     ((t (:background ,(gt-mix gt-source-diff-changed-line-fg-color
                               gt-source-current-line-bg-color
                               0.25)))))
   `(ediff-even-diff-A
     ((t (:extend t :background ,gt-source-current-line-bg-color))))
   `(ediff-even-diff-B
     ((t (:extend t :background ,gt-source-current-line-bg-color))))
   `(ediff-even-diff-C
     ((t (:extend t :background ,gt-source-current-line-bg-color))))
   `(ediff-even-diff-Ancestor
     ((t (:extend t :background ,gt-source-current-line-bg-color))))
   `(ediff-odd-diff-A
     ((t (:extend t :background ,gt-secondary-sidebar-bg-color))))
   `(ediff-odd-diff-B
     ((t (:extend t :background ,gt-secondary-sidebar-bg-color))))
   `(ediff-odd-diff-C
     ((t (:extend t :background ,gt-secondary-sidebar-bg-color))))
   `(ediff-odd-diff-Ancestor
     ((t (:extend t :background ,gt-secondary-sidebar-bg-color))))
   '(git-commit-summary ((t (:inherit (magit-section-heading)))))
   '(git-commit-keyword ((t (:inherit (font-lock-type-face)))))
   '(git-commit-trailer-value ((t (:inherit (font-lock-doc-face)))))
   `(git-commit-comment-file ((t (:foreground ,gt-source-diff-file-fg-color))))
   `(magit-section-highlight
     ((t (:extend t :background ,gt-source-current-line-bg-color))))
   `(magit-section-heading
     ((t (:extend t :weight bold :foreground ,gt-accent-color))))
   `(magit-section-heading-selection
     ((t (:extend t :foreground ,gt-warning-color))))
   '(magit-dimmed ((t (:inherit (shadow)))))
   `(magit-hash ((t (:foreground ,gt-dark-1))))
   `(magit-tag ((t (:foreground ,gt-yellow-1))))
   `(magit-branch-local ((t (:foreground ,gt-blue-2))))
   `(magit-branch-current
     ((t ( :inherit (magit-branch-local)
           :underline (:color ,gt-blue-2 :style line :position t)))))
   `(magit-branch-remote ((t (:foreground ,gt-green-2))))
   `(magit-branch-remote-head
     ((t ( :inherit (magit-branch-remote)
           :underline (:color ,gt-green-2 :style line :position t)))))
   `(magit-refname ((t (:foreground ,gt-light-4))))
   '(magit-signature-good ((t (:inherit (success)))))
   '(magit-signature-bad ((t (:inherit (error)))))
   `(magit-signature-untrusted ((t (:foreground ,gt-teal-2))))
   '(magit-signature-expired ((t (:inherit (warning)))))
   '(magit-signature-revoked ((t (:inherit (error)))))
   `(magit-signature-error ((t (:foreground ,gt-blue-1))))
   `(magit-cherry-unmatched ((t (:foreground ,gt-blue-2))))
   `(magit-cherry-equivalent ((t (:foreground ,gt-purple-2))))
   `(magit-log-graph ((t (:foreground ,gt-light-5))))
   `(magit-log-author ((t (:foreground ,gt-brown-1))))
   '(magit-log-date ((t (:inherit (shadow)))))
   '(magit-diff-file-heading ((t (:inherit (diff-file-header)))))
   `(magit-diff-file-heading-selection
     ((t (:extend t :inherit (region magit-diff-file-heading-highlight)))))
   '(magit-diff-hunk-heading ((t (:inherit (diff-hunk-header)))))
   `(magit-diff-hunk-heading-highlight
     ((t ( :background ,gt-button-hover-color
           :inherit (magit-diff-hunk-heading)))))
   `(magit-diff-hunk-heading-selection
     ((t (:extend t :inherit (region magit-diff-hunk-heading-highlight)))))
   `(magit-diff-lines-heading
     ((t (:extend t :inherit (region magit-diff-hunk-heading-highlight)))))
   '(magit-diff-hunk-region ((t (:extend t :inherit (region bold)))))
   `(magit-diff-our-heading
     ((t ( :extend t
           :foreground ,gt-red-1
           :background ,(gt-mix gt-red-5 gt-view-bg-color 0.25)))))
   `(magit-diff-base-heading
     ((t ( :extend t
           :foreground ,gt-yellow-1
           :background ,(gt-mix gt-yellow-5 gt-view-bg-color 0.25)))))
   `(magit-diff-their-heading
     ((t ( :extend t
           :foreground ,gt-green-1
           :background ,(gt-mix gt-green-5 gt-view-bg-color 0.25)))))
   '(magit-diff-context ((t (:inherit (diff-context)))))
   '(magit-diff-removed ((t (:inherit (diff-removed)))))
   '(magit-diff-added ((t (:inherit (diff-added)))))
   '(magit-diff-base ((t (:inherit (diff-changed)))))
   `(magit-diff-context-highlight
     ((t ( :background ,gt-source-current-line-bg-color
           :inherit (magit-diff-context)))))
   `(magit-diff-removed-highlight
     ((t ( :background ,gt-source-current-line-bg-color
           :inherit (magit-diff-removed)))))
   `(magit-diff-added-highlight
     ((t ( :background ,gt-source-current-line-bg-color
           :inherit (magit-diff-added)))))
   `(magit-diff-base-highlight
     ((t ( :background ,gt-source-current-line-bg-color
           :inherit (magit-diff-base)))))
   '(magit-diff-removed-indicator ((t (:inherit (diff-indicator-removed)))))
   '(magit-diff-added-indicator ((t (:inherit (diff-indicator-added)))))
   '(magit-diff-base-indicator ((t (:inherit (diff-indicator-changed)))))
   '(magit-diffstat-removed ((t (:inherit (diff-indicator-removed)))))
   '(magit-diffstat-added ((t (:inherit (diff-indicator-added)))))
   `(diff-refine-added
     ((t ( :foreground ,gt-source-diff-added-line-fg-color
           :background ,(gt-mix gt-source-diff-added-line-fg-color
                                gt-source-current-line-bg-color
                                0.25)))))
   `(diff-refine-removed
     ((t ( :foreground ,gt-source-diff-removed-line-fg-color
           :background ,(gt-mix gt-source-diff-removed-line-fg-color
                                gt-source-current-line-bg-color
                                0.25)))))
   `(diff-refine-changed
     ((t ( :foreground ,gt-source-diff-changed-line-fg-color
           :background ,(gt-mix gt-source-diff-changed-line-fg-color
                                gt-source-current-line-bg-color
                                0.25)))))
   `(magit-blame-highlight
     ((t ( :extend t
           :foreground ,gt-view-fg-color
           :background ,gt-headerbar-bg-color))))
   `(magit-process-ok
     ((t (:foreground ,gt-success-color :inherit (magit-section-heading)))))
   `(magit-process-ng
     ((t (:foreground ,gt-error-color :inherit (magit-section-heading)))))
   `(magit-bisect-good ((t (:foreground ,gt-success-color))))
   `(magit-bisect-skip ((t (:foreground ,gt-warning-color))))
   `(magit-bisect-bad ((t (:foreground ,gt-error-color))))
   `(magit-sequence-stop ((t (:foreground ,gt-blue-1))))
   `(magit-sequence-part ((t (:foreground ,gt-warning-color))))
   `(magit-sequence-head ((t (:foreground ,gt-success-color))))
   `(magit-sequence-drop ((t (:foreground ,gt-error-color))))
   `(magit-reflog-commit ((t (:foreground ,gt-success-color))))
   `(magit-reflog-amend ((t (:foreground ,gt-purple-2))))
   `(magit-reflog-merge ((t (:foreground ,gt-success-color))))
   `(magit-reflog-checkout ((t (:foreground ,gt-blue-2))))
   `(magit-reflog-reset ((t (:foreground ,gt-error-color))))
   `(magit-reflog-rebase ((t (:foreground ,gt-purple-2))))
   `(magit-reflog-cherry-pick ((t (:foreground ,gt-success-color))))
   `(magit-reflog-remote ((t (:foreground ,gt-blue-2))))
   `(magit-reflog-other ((t (:foreground ,gt-blue-2))))
   '(eshell-prompt ((t (:inherit (minibuffer-prompt)))))
   `(eshell-input ((t (:foreground ,gt-accent-color))))
   '(eshell-ls-executable ((t (:inherit (font-lock-function-name-face)))))
   '(eshell-ls-directory ((t (:inherit (dired-directory)))))
   '(eshell-ls-special ((t (:inherit (dired-special)))))
   '(eshell-ls-symlink ((t (:inherit (dired-symlink)))))
   '(eshell-ls-readonly ((t (:inherit (font-lock-constant-face)))))
   '(eshell-ls-unreadable ((t (:inherit (shadow)))))
   '(eshell-ls-missing ((t (:inherit (dired-broken-symlink)))))
   '(org-block ((t (:inherit (fixed-pitch)))))
   '(org-code ((t (:inherit (fixed-pitch)))))
   ;; Colors from Gnome Console
   '(ansi-color-black ((t (:foreground "#241f31" :background "#241f31"))))
   '(ansi-color-red ((t (:foreground "#c01c28" :background "#c01c28"))))
   '(ansi-color-green ((t (:foreground "#2ec27e" :background "#2ec27e"))))
   '(ansi-color-yellow ((t (:foreground "#f5c211" :background "#f5c211"))))
   '(ansi-color-blue ((t (:foreground "#1e78e4" :background "#1e78e4"))))
   '(ansi-color-magenta ((t (:foreground "#9841bb" :background "#9841bb"))))
   '(ansi-color-cyan ((t (:foreground "#0ab9dc" :background "#0ab9dc"))))
   '(ansi-color-white ((t (:foreground "#c0bfbc" :background "#c0bfbc"))))
   '(ansi-color-bright-black ((t (:foreground "#5e5c64" :background "#5e5c64"))))
   '(ansi-color-bright-red ((t (:foreground "#ed333b" :background "#ed333b"))))
   '(ansi-color-bright-green ((t (:foreground "#57e389" :background "#57e389"))))
   '(ansi-color-bright-yellow ((t (:foreground "#f8e45c" :background "#f8e45c"))))
   '(ansi-color-bright-blue ((t (:foreground "#51a1ff" :background "#51a1ff"))))
   '(ansi-color-bright-magenta ((t (:foreground "#c061cb" :background "#c061cb"))))
   '(ansi-color-bright-cyan ((t (:foreground "#4fd2fd" :background "#4fd2fd"))))
   '(ansi-color-bright-white ((t (:foreground "#f6f5f4" :background "#f6f5f4"))))))

(defun gt--set-config-accent-color (symbol value)
  "Set SYMBOL to VALUE and update accent-derived colors."
  (set-default symbol value)
  (gt--update-accent-colors value)
  (gt--set-faces))

(defcustom gt-config-accent-color
  (let ((value (condition-case nil
                   (car (process-lines
                         "gsettings" "get" "org.gnome.desktop.interface"
                         "accent-color"))
                 (error nil))))
    (if (and value
             (string-match "\\`'\\([a-z]+\\)'\\'" value)
             (member (match-string 1 value)
                     '("blue" "teal" "green" "yellow" "orange"
                       "red" "pink" "purple" "slate")))
        (intern (match-string 1 value))
      'blue))
  "Accent color used by the Gnome theme."
  :type '(choice (const blue)
                 (const teal)
                 (const green)
                 (const yellow)
                 (const orange)
                 (const red)
                 (const pink)
                 (const purple)
                 (const slate))
  :set #'gt--set-config-accent-color
  :group 'gnome-theme)

(custom-theme-set-variables
 'gnome
 '(gnome-theme-mode t)
 '(magit-diff-highlight-hunk-region-functions
   '(magit-diff-highlight-hunk-region-dim-outside
     magit-diff-highlight-hunk-region-using-face)))

;;;###autoload
(when load-file-name
  (add-to-list 'custom-theme-load-path
               (file-name-directory load-file-name)))

(provide-theme 'gnome)

;; Local Variables:
;; read-symbol-shorthands: (("gt-" . "gnome-theme-"))
;; byte-compile-warnings: (not lexical)
;; End:

(provide 'gnome-theme)
