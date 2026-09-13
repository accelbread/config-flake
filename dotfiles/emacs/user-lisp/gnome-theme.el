;;; gnome-theme.el --- Emacs Gnome theme -*- lexical-binding: t; -*-

;; Copyright (C) Archit Gupta <archit@accelbread.com>
;; SPDX-License-Identifier: GPL-3.0-or-later
;; Version: 0
;; Package-Requires: ((emacs "31.1"))

;;; Commentary:

;; Emacs theme based off of Gnome's Adwaita theme.
;;
;; Most colors are directly from the libadwaita stylesheet.
;; Also uses colors GtkSourceView's Adwaita extensions and Gnome Console's
;; terminal colors.

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

(defmacro gt--custom-theme-set-faces (theme faces)
  "Apply alist of face properties FACES for THEME.
Each element of FACES has the form (FACE ATTRIBUTE...)."
  (declare (indent 1))
  `(apply #'custom-theme-set-faces ,theme
          (mapcar (lambda (spec) `(,(car spec) ((t ,(cdr spec)))))
                  ,faces)))

(defun gt--set-faces ()
  "Update face configuration for Gnome theme."
  (gt--custom-theme-set-faces 'gnome
    `((default :background ,gt-view-bg-color
               :foreground ,gt-view-fg-color
               :family "Adwaita Mono")
      (fixed-pitch :family "Adwaita Mono")
      (fixed-pitch-serif :inherit (fixed-pitch))
      (variable-pitch :family "Adwaita Sans")
      (variable-pitch-text :inherit (variable-pitch))
      (cursor :background ,gt-view-fg-color)
      (homoglyph :foreground ,gt-warning-color :inherit (bold))
      (escape-glyph :inherit (homoglyph))
      (minibuffer-prompt :foreground ,gt-accent-color)
      (highlight :background ,gt-selected-hover-color)
      (hl-line :extend t :background ,gt-source-current-line-bg-color)
      (widget-field :foreground ,gt-view-fg-color
                    :background ,gt-button-color
                    :box (:line-width (4 . 2) :color ,gt-button-color)
                    :extend t)
      (custom-button :weight bold
                     :foreground ,gt-view-fg-color
                     :background ,gt-button-color
                     :underline (:color ,gt-view-bg-color :position t)
                     :box (:line-width (4 . 2) :style flat-button))
      (custom-button-mouse :inherit (custom-button)
                           :background ,gt-button-hover-color)
      (custom-button-pressed :inherit (custom-button)
                             :background ,gt-button-active-color)
      (custom-comment :extend nil :inherit (widget-field))
      (custom-comment-tag :inherit (default))
      (custom-state :foreground ,gt-success-color)
      (custom-variable-tag :weight bold
                           :foreground ,gt-accent-color)
      (custom-variable-obsolete :foreground ,gt-disabled-color)
      (custom-group-tag :weight bold
                        :height 1.2
                        :foreground ,gt-accent-color
                        :inherit (variable-pitch))
      (region :extend nil
              :background ,(gt-mix gt-accent-bg-color gt-view-bg-color 0.3))
      (shadow :foreground ,gt-disabled-color)
      (warning :weight bold :foreground ,gt-warning-color)
      (success :weight bold :foreground ,gt-success-color)
      (error :weight bold :foreground ,gt-error-color)
      (secondary-selection :extend nil
                           :background
                           ,(gt-mix gt-view-fg-color gt-view-bg-color 0.1))
      (trailing-whitespace :background ,gt-dark-3)
      (font-lock-builtin-face :foreground ,gt-yellow-1)
      (font-lock-comment-delimiter-face :inherit (font-lock-comment-face))
      (font-lock-comment-face :foreground ,gt-light-5 :extend t)
      (font-lock-constant-face :foreground ,gt-orange-1)
      (font-lock-doc-face :foreground ,gt-blue-1 :extend t)
      (font-lock-doc-markup-face :inherit (font-lock-constant-face))
      (font-lock-function-name-face :foreground ,gt-blue-2)
      (font-lock-keyword-face :foreground ,gt-purple-1)
      (font-lock-negation-char-face :inherit (homoglyph))
      (font-lock-preprocessor-face :foreground ,gt-brown-2 :inherit (bold))
      (font-lock-regexp-grouping-backslash :foreground ,gt-orange-1)
      (font-lock-regexp-grouping-construct :foreground ,gt-orange-1)
      (font-lock-string-face :foreground ,gt-green-2)
      (font-lock-type-face :foreground ,gt-teal-2)
      (font-lock-variable-name-face :foreground ,gt-brown-1)
      (font-lock-warning-face :inherit (warning))
      (elisp-free-variable :underline (:color ,gt-light-4 :style line))
      (elisp-shadowed-variable :inherit (elisp-bound-variable)
                               :underline (:color ,gt-light-4 :style line))
      (link :weight bold
            :underline (:color foreground-color :style line)
            :foreground ,gt-accent-color)
      (link-visited :foreground ,gt-link-visited-color)
      (fringe :foreground ,gt-accent-color)
      (header-line :inherit (mode-line))
      (header-line-inactive :inherit (mode-line-inactive))
      (mode-line :box ( :line-width (-1 . 4)
                        :color ,gt-headerbar-bg-color
                        :style nil)
                 :background ,gt-headerbar-bg-color
                 :foreground ,gt-headerbar-fg-color
                 :inherit (variable-pitch))
      (mode-line-inactive :box ( :line-width (-1 . 4)
                                 :color ,gt-headerbar-backdrop-color
                                 :style nil)
                          :background ,gt-headerbar-backdrop-color
                          :foreground ,(gt-mix gt-headerbar-fg-color
                                               gt-headerbar-backdrop-color
                                               0.5)
                          :inherit (mode-line))
      (mode-line-buffer-id :weight bold)
      (mode-line-emphasis :foreground ,gt-accent-color)
      (mode-line-highlight
       :background ,(gt-mix gt-headerbar-fg-color gt-headerbar-bg-color 0.15))
      (eglot-mode-line :inherit (fringe))
      (tab-bar :inherit (mode-line))
      (tab-bar-tab :inherit (mode-line))
      (tab-bar-tab-inactive :inherit (mode-line-inactive))
      (window-divider :foreground ,gt-headerbar-backdrop-color)
      (window-divider-first-pixel :inherit (window-divider))
      (window-divider-last-pixel :inherit (window-divider))
      (transient-key-exit :inherit (font-lock-function-name-face))
      (transient-key-stay :inherit (font-lock-variable-name-face))
      (transient-key-return :inherit (font-lock-warning-face))
      (isearch :weight bold :inherit (lazy-highlight))
      (isearch-fail :weight bold
                    :foreground ,gt-error-fg-color
                    :background ,gt-error-bg-color)
      (lazy-highlight :foreground ,gt-source-search-fg-color
                      :background ,gt-search-match-color)
      (next-error :inherit (region))
      (query-replace :inherit (isearch))
      (whitespace-tab :inherit (shadow))
      (whitespace-trailing :inherit (secondary-selection))
      (whitespace-missing-newline-at-eof :inherit (isearch-fail))
      (page-break-lines :inherit (shadow))
      (flyspell-incorrect :underline (:style wave :color ,gt-error-bg-color))
      (flyspell-duplicate :underline (:style wave :color ,gt-warning-bg-color))
      (Man-overstrike :foreground ,gt-accent-color :inherit (bold fixed-pitch))
      (Man-underline :foreground ,gt-accent-color :inherit (italic fixed-pitch))
      (woman-bold :inherit (Man-overstrike))
      (woman-italic :inherit (Man-underline))
      (diff-header :extend t
                   :foreground ,gt-source-diff-location-fg-color
                   :background ,gt-button-color)
      (diff-file-header :extend t
                        :weight bold
                        :foreground ,gt-source-diff-file-fg-color)
      (diff-index :extend t :foreground ,gt-dark-1)
      (diff-context :extend t
                    :foreground ,gt-source-text-fg-color
                    :background ,gt-view-bg-color)
      (diff-removed :extend t
                    :foreground ,gt-source-diff-removed-line-fg-color
                    :background ,gt-view-bg-color)
      (diff-added :extend t
                  :foreground ,gt-source-diff-added-line-fg-color
                  :background ,gt-view-bg-color)
      (diff-changed :extend t
                    :foreground ,gt-source-diff-changed-line-fg-color
                    :background ,gt-view-bg-color)
      (diff-changed-unspecified
       :extend t
       :foreground ,gt-source-diff-changed-line-fg-color
       :background ,gt-view-bg-color)
      (diff-indicator-removed :foreground ,gt-source-diff-removed-line-fg-color)
      (diff-indicator-added :foreground ,gt-source-diff-added-line-fg-color)
      (diff-indicator-changed :foreground ,gt-source-diff-changed-line-fg-color)
      (diff-error :inherit (error))
      (ediff-current-diff-A
       :extend t :background ,(gt-mix gt-red-5 gt-view-bg-color 0.25))
      (ediff-current-diff-B
       :extend t :background ,(gt-mix gt-teal-5 gt-view-bg-color 0.25))
      (ediff-current-diff-C
       :extend t :background ,(gt-mix gt-orange-5 gt-view-bg-color 0.25))
      (ediff-current-diff-Ancestor
       :extend t :background ,(gt-mix gt-blue-5 gt-view-bg-color 0.25))
      (ediff-fine-diff-A :background
                         ,(gt-mix gt-source-diff-removed-line-fg-color
                                  gt-source-current-line-bg-color
                                  0.25))
      (ediff-fine-diff-B :background
                         ,(gt-mix gt-source-diff-added-line-fg-color
                                  gt-source-current-line-bg-color
                                  0.25))
      (ediff-fine-diff-C :background
                         ,(gt-mix gt-source-diff-changed-line-fg-color
                                  gt-source-current-line-bg-color
                                  0.25))
      (ediff-even-diff-A :extend t :background ,gt-source-current-line-bg-color)
      (ediff-even-diff-B :extend t :background ,gt-source-current-line-bg-color)
      (ediff-even-diff-C :extend t :background ,gt-source-current-line-bg-color)
      (ediff-even-diff-Ancestor
       :extend t :background ,gt-source-current-line-bg-color)
      (ediff-odd-diff-A :extend t :background ,gt-secondary-sidebar-bg-color)
      (ediff-odd-diff-B :extend t :background ,gt-secondary-sidebar-bg-color)
      (ediff-odd-diff-C :extend t :background ,gt-secondary-sidebar-bg-color)
      (ediff-odd-diff-Ancestor
       :extend t :background ,gt-secondary-sidebar-bg-color)
      (git-commit-summary :inherit (magit-section-heading))
      (git-commit-keyword :inherit (font-lock-type-face))
      (git-commit-trailer-value :inherit (font-lock-doc-face))
      (git-commit-comment-file :foreground ,gt-source-diff-file-fg-color)
      (magit-section-highlight
       :extend t :background ,gt-source-current-line-bg-color)
      (magit-section-heading
       :extend t :weight bold :foreground ,gt-accent-color)
      (magit-section-heading-selection :extend t :foreground ,gt-warning-color)
      (magit-dimmed :inherit (shadow))
      (magit-hash :foreground ,gt-dark-1)
      (magit-tag :foreground ,gt-yellow-1)
      (magit-branch-local :foreground ,gt-blue-2)
      (magit-branch-current :inherit (magit-branch-local)
                            :underline
                            (:color ,gt-blue-2 :style line :position t))
      (magit-branch-remote :foreground ,gt-green-2)
      (magit-branch-remote-head :inherit (magit-branch-remote)
                                :underline
                                (:color ,gt-green-2 :style line :position t))
      (magit-refname :foreground ,gt-light-4)
      (magit-signature-good :inherit (success))
      (magit-signature-bad :inherit (error))
      (magit-signature-untrusted :foreground ,gt-teal-2)
      (magit-signature-expired :inherit (warning))
      (magit-signature-revoked :inherit (error))
      (magit-signature-error :foreground ,gt-blue-1)
      (magit-cherry-unmatched :foreground ,gt-blue-2)
      (magit-cherry-equivalent :foreground ,gt-purple-2)
      (magit-log-graph :foreground ,gt-light-5)
      (magit-log-author :foreground ,gt-brown-1)
      (magit-log-date :inherit (shadow))
      (magit-diff-file-heading :inherit (diff-file-header))
      (magit-diff-file-heading-selection
       :extend t :inherit (region magit-diff-file-heading-highlight))
      (magit-diff-hunk-heading :inherit (diff-hunk-header))
      (magit-diff-hunk-heading-highlight :background ,gt-button-hover-color
                                         :inherit (magit-diff-hunk-heading))
      (magit-diff-hunk-heading-selection
       :extend t :inherit (region magit-diff-hunk-heading-highlight))
      (magit-diff-lines-heading
       :extend t :inherit (region magit-diff-hunk-heading-highlight))
      (magit-diff-hunk-region :extend t :inherit (region bold))
      (magit-diff-our-heading :extend t
                              :foreground ,gt-red-1
                              :background
                              ,(gt-mix gt-red-5 gt-view-bg-color 0.25))
      (magit-diff-base-heading :extend t
                               :foreground ,gt-yellow-1
                               :background
                               ,(gt-mix gt-yellow-5 gt-view-bg-color 0.25))
      (magit-diff-their-heading :extend t
                                :foreground ,gt-green-1
                                :background
                                ,(gt-mix gt-green-5 gt-view-bg-color 0.25))
      (magit-diff-context :inherit (diff-context))
      (magit-diff-removed :inherit (diff-removed))
      (magit-diff-added :inherit (diff-added))
      (magit-diff-base :inherit (diff-changed))
      (magit-diff-context-highlight :background ,gt-source-current-line-bg-color
                                    :inherit (magit-diff-context))
      (magit-diff-removed-highlight :background ,gt-source-current-line-bg-color
                                    :inherit (magit-diff-removed))
      (magit-diff-added-highlight :background ,gt-source-current-line-bg-color
                                  :inherit (magit-diff-added))
      (magit-diff-base-highlight :background ,gt-source-current-line-bg-color
                                 :inherit (magit-diff-base))
      (magit-diff-removed-indicator :inherit (diff-indicator-removed))
      (magit-diff-added-indicator :inherit (diff-indicator-added))
      (magit-diff-base-indicator :inherit (diff-indicator-changed))
      (magit-diffstat-removed :inherit (diff-indicator-removed))
      (magit-diffstat-added :inherit (diff-indicator-added))
      (diff-refine-added :foreground ,gt-source-diff-added-line-fg-color
                         :background ,(gt-mix gt-source-diff-added-line-fg-color
                                              gt-source-current-line-bg-color
                                              0.25))
      (diff-refine-removed :foreground ,gt-source-diff-removed-line-fg-color
                           :background
                           ,(gt-mix gt-source-diff-removed-line-fg-color
                                    gt-source-current-line-bg-color
                                    0.25))
      (diff-refine-changed :foreground ,gt-source-diff-changed-line-fg-color
                           :background
                           ,(gt-mix gt-source-diff-changed-line-fg-color
                                    gt-source-current-line-bg-color
                                    0.25))
      (magit-blame-highlight :extend t
                             :foreground ,gt-view-fg-color
                             :background ,gt-headerbar-bg-color)
      (magit-process-ok :foreground ,gt-success-color
                        :inherit (magit-section-heading))
      (magit-process-ng :foreground ,gt-error-color
                        :inherit (magit-section-heading))
      (magit-bisect-good :foreground ,gt-success-color)
      (magit-bisect-skip :foreground ,gt-warning-color)
      (magit-bisect-bad :foreground ,gt-error-color)
      (magit-sequence-stop :foreground ,gt-blue-1)
      (magit-sequence-part :foreground ,gt-warning-color)
      (magit-sequence-head :foreground ,gt-success-color)
      (magit-sequence-drop :foreground ,gt-error-color)
      (magit-reflog-commit :foreground ,gt-success-color)
      (magit-reflog-amend :foreground ,gt-purple-2)
      (magit-reflog-merge :foreground ,gt-success-color)
      (magit-reflog-checkout :foreground ,gt-blue-2)
      (magit-reflog-reset :foreground ,gt-error-color)
      (magit-reflog-rebase :foreground ,gt-purple-2)
      (magit-reflog-cherry-pick :foreground ,gt-success-color)
      (magit-reflog-remote :foreground ,gt-blue-2)
      (magit-reflog-other :foreground ,gt-blue-2)
      (dired-broken-symlink :inherit (error))
      (dired-directory :foreground ,gt-blue-2)
      (dired-flagged :strike-through t :inherit (error))
      (dired-header :weight bold :foreground ,gt-accent-color)
      (dired-mark :foreground ,gt-accent-color)
      (dired-marked :foreground ,gt-view-fg-color
                    :background ,gt-view-selected-color)
      (dired-perm-write :inherit (font-lock-function-name-face))
      (dired-special :inherit (font-lock-keyword-face))
      (dired-symlink :inherit (font-lock-variable-name-face))
      (eshell-prompt :inherit (minibuffer-prompt))
      (eshell-input :foreground ,gt-accent-color)
      (eshell-ls-executable :inherit (font-lock-function-name-face))
      (eshell-ls-directory :foreground ,gt-blue-2)
      (eshell-ls-special :inherit (font-lock-keyword-face))
      (eshell-ls-symlink :inherit (font-lock-variable-name-face))
      (eshell-ls-readonly :inherit (font-lock-constant-face))
      (eshell-ls-unreadable :inherit (shadow))
      (eshell-ls-missing :inherit (error))
      (org-block :inherit (fixed-pitch))
      (org-code :inherit (fixed-pitch))
      ;; Colors from Gnome Console
      (ansi-color-black :foreground "#241f31" :background "#241f31")
      (ansi-color-red :foreground "#c01c28" :background "#c01c28")
      (ansi-color-green :foreground "#2ec27e" :background "#2ec27e")
      (ansi-color-yellow :foreground "#f5c211" :background "#f5c211")
      (ansi-color-blue :foreground "#1e78e4" :background "#1e78e4")
      (ansi-color-magenta :foreground "#9841bb" :background "#9841bb")
      (ansi-color-cyan :foreground "#0ab9dc" :background "#0ab9dc")
      (ansi-color-white :foreground "#c0bfbc" :background "#c0bfbc")
      (ansi-color-bright-black :foreground "#5e5c64" :background "#5e5c64")
      (ansi-color-bright-red :foreground "#ed333b" :background "#ed333b")
      (ansi-color-bright-green :foreground "#57e389" :background "#57e389")
      (ansi-color-bright-yellow :foreground "#f8e45c" :background "#f8e45c")
      (ansi-color-bright-blue :foreground "#51a1ff" :background "#51a1ff")
      (ansi-color-bright-magenta :foreground "#c061cb" :background "#c061cb")
      (ansi-color-bright-cyan :foreground "#4fd2fd" :background "#4fd2fd")
      (ansi-color-bright-white :foreground "#f6f5f4" :background "#f6f5f4"))))

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
