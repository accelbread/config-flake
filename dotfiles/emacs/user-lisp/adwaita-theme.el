;;; adwaita-theme.el --- Adwaita theme -*- lexical-binding: t; -*-

;; Copyright (C) Archit Gupta <archit@accelbread.com>
;; SPDX-License-Identifier: GPL-3.0-or-later
;; Version: 0

;;; Commentary:

;; Theme based off of Adwaita colors.

;;; Code:

(require 'cl-lib)
(require 'color)

(defvar adwaita-theme--system-accent-color
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
      'blue)))

(deftheme adwaita)

(cl-labels
    ((rgb (color)
       (mapcar (lambda (component) (/ component 65535.0))
               (color-values-from-color-spec color)))
     (hex (rgb)
       (apply #'format "#%02x%02x%02x"
              (mapcar (lambda (component)
                        (min 255 (max 0 (floor (+ (* component 255) 0.5)))))
                      rgb)))
     (mix (foreground background alpha)
       (hex (color-blend (rgb foreground)
                         (rgb background)
                         alpha)))
     (standalone (color)
       (let ((oklab (apply #'color-srgb-to-oklab
                           (rgb color))))
         (hex (apply #'color-oklab-to-srgb
                     (cons (max 0.85 (car oklab)) (cdr oklab)))))))
  (let* (;; Colors from libadwaita
         (accent-blue "#3584e4")
         (accent-teal "#2190a4")
         (accent-green "#3a944a")
         (accent-yellow "#c88800")
         (accent-orange "#ed5b00")
         (accent-red "#e62d42")
         (accent-pink "#d56199")
         (accent-purple "#9141ac")
         (accent-slate "#6f8396")
         (accent-bg-color (pcase adwaita-theme--system-accent-color
                            ('blue accent-blue)
                            ('teal accent-teal)
                            ('green accent-green)
                            ('yellow accent-yellow)
                            ('orange accent-orange)
                            ('red accent-red)
                            ('pink accent-pink)
                            ('purple accent-purple)
                            ('slate accent-slate)))
         (accent-fg-color "#ffffff")
         (accent-color (standalone accent-bg-color)) ; #fba7ff
         (destructive-bg-color "#c01c28")
         (destructive-fg-color "#ffffff")
         (destructive-color (standalone destructive-bg-color)) ; #ff938b
         (success-bg-color "#26a269")
         (success-fg-color "#ffffff")
         (success-color (standalone success-bg-color)) ; #78e9ab
         (warning-bg-color "#cd9309")
         (warning-fg-color "#291d02")
         (warning-color (standalone warning-bg-color)) ; #ffc252
         (error-bg-color "#c01c28")
         (error-fg-color "#ffffff")
         (error-color (standalone error-bg-color)) ; #ff938b
         (window-bg-color "#222226")
         (window-fg-color "#ffffff")
         (view-bg-color "#1d1d20")
         (view-fg-color "#ffffff")
         (headerbar-bg-color "#2e2e32")
         (headerbar-fg-color "#ffffff")
         (headerbar-backdrop-color window-bg-color) ; #222226
         (sidebar-bg-color "#2e2e32")
         (sidebar-fg-color "#ffffff")
         (secondary-sidebar-bg-color "#28282c")
         (secondary-sidebar-fg-color "#ffffff")
         (button-color (mix view-fg-color view-bg-color 0.1)) ; #343436
         (button-hover-color (mix view-fg-color view-bg-color 0.15)) ; #3f3f41
         (button-active-color (mix view-fg-color view-bg-color 0.3)) ; #616163
         (selected-hover-color (mix view-fg-color view-bg-color 0.13)) ; #3a3a3d
         (link-visited-color (mix accent-color view-fg-color 0.8)) ; #fcb9ff
         (disabled-color (mix view-fg-color view-bg-color 0.5)) ; #8e8e90
         (view-selected-color (mix accent-bg-color view-bg-color 0.25)) ; #3a2643
         (blue-1 "#99c1f1")
         (blue-2 "#62a0ea")
         (blue-3 "#3584e4")
         (blue-4 "#1c71d8")
         (blue-5 "#1a5fb4")
         (green-1 "#8ff0a4")
         (green-2 "#57e389")
         (green-3 "#33d17a")
         (green-4 "#2ec27e")
         (green-5 "#26a269")
         (yellow-1 "#f9f06b")
         (yellow-2 "#f8e45c")
         (yellow-3 "#f6d32d")
         (yellow-4 "#f5c211")
         (yellow-5 "#e5a50a")
         (orange-1 "#ffbe6f")
         (orange-2 "#ffa348")
         (orange-3 "#ff7800")
         (orange-4 "#e66100")
         (orange-5 "#c64600")
         (red-1 "#f66151")
         (red-2 "#ed333b")
         (red-3 "#e01b24")
         (red-4 "#c01c28")
         (red-5 "#a51d2d")
         (purple-1 "#dc8add")
         (purple-2 "#c061cb")
         (purple-3 "#9141ac")
         (purple-4 "#813d9c")
         (purple-5 "#613583")
         (brown-1 "#cdab8f")
         (brown-2 "#b5835a")
         (brown-3 "#986a44")
         (brown-4 "#865e3c")
         (brown-5 "#63452c")
         (light-1 "#ffffff")
         (light-2 "#f6f5f4")
         (light-3 "#deddda")
         (light-4 "#c0bfbc")
         (light-5 "#9a9996")
         (dark-1 "#77767b")
         (dark-2 "#5e5c64")
         (dark-3 "#3d3846")
         (dark-4 "#241f31")
         (dark-5 "#000000")
         ;; Colors from GtkSourceView's Adwaita style scheme.
         (teal-1 "#93ddc2")
         (teal-2 "#5bc8af")
         (teal-3 "#33b2a4")
         (teal-4 "#26a1a2")
         (teal-5 "#218787")
         (violet-2 "#7d8ac7")
         (violet-3 "#6362c8")
         (violet-4 "#4e57ba")
         (source-text-fg-color "#c0bfbc")
         (source-search-fg-color "#242424")
         (search-match-color (mix yellow-3 view-bg-color 0.5)) ; #8a7827
         (source-current-line-bg-color "#242428")
         (source-diff-added-line-fg-color teal-3)
         (source-diff-changed-line-fg-color orange-3)
         (source-diff-file-fg-color violet-2)
         (source-diff-location-fg-color yellow-4)
         (source-diff-removed-line-fg-color red-1))
    (custom-theme-set-faces
     'adwaita
     `(default ((t ( :background ,view-bg-color
                     :foreground ,view-fg-color
                     :family "Adwaita Mono"))))
     '(fixed-pitch ((t (:family "Adwaita Mono"))))
     '(fixed-pitch-serif ((t (:inherit (fixed-pitch)))))
     '(variable-pitch ((t (:family "Adwaita Sans"))))
     '(variable-pitch-text ((t (:inherit (variable-pitch)))))
     `(cursor ((t (:background ,view-fg-color))))
     `(homoglyph ((t (:foreground ,warning-color :inherit (bold)))))
     '(escape-glyph ((t (:inherit (homoglyph)))))
     `(minibuffer-prompt ((t (:foreground ,accent-color))))
     `(highlight ((t (:background ,selected-hover-color))))
     `(hl-line ((t (:extend t :background ,source-current-line-bg-color))))
     `(widget-field ((t ( :foreground ,view-fg-color
                          :background ,button-color
                          :box (:line-width (4 . 2) :color ,button-color)
                          :extend t))))
     `(custom-button ((t ( :weight bold
                           :foreground ,view-fg-color
                           :background ,button-color
                           :underline (:color ,view-bg-color :position t)
                           :box (:line-width (4 . 2) :style flat-button)))))
     `(custom-button-mouse ((t ( :inherit (custom-button)
                                 :background ,button-hover-color))))
     `(custom-button-pressed ((t ( :inherit (custom-button)
                                   :background ,button-active-color))))
     '(custom-comment ((t (:extend nil :inherit (widget-field)))))
     '(custom-comment-tag ((t (:inherit (default)))))
     `(custom-state ((t (:foreground ,success-color))))
     `(custom-variable-tag ((t ( :weight bold
                                 :foreground ,accent-color))))
     `(custom-variable-obsolete ((t (:foreground ,disabled-color))))
     `(custom-group-tag ((t ( :weight bold
                              :height 1.2
                              :foreground ,accent-color
                              :inherit (variable-pitch)))))
     `(region ((t ( :extend nil
                    :background ,(mix accent-bg-color view-bg-color 0.3))))) ; #40284a
     `(shadow ((t (:foreground ,disabled-color))))
     `(warning ((t (:weight bold :foreground ,warning-color))))
     `(success ((t (:weight bold :foreground ,success-color))))
     `(error ((t (:weight bold :foreground ,error-color))))
     `(secondary-selection
       ((t ( :extend nil
             :background ,(mix view-fg-color view-bg-color 0.1))))) ; #343436
     `(trailing-whitespace ((t (:background ,dark-3))))
     `(font-lock-builtin-face ((t (:foreground ,yellow-1))))
     '(font-lock-comment-delimiter-face ((default (:inherit (font-lock-comment-face)))))
     `(font-lock-comment-face ((t (:foreground ,light-5 :extend t))))
     `(font-lock-constant-face ((t (:foreground ,orange-1))))
     `(font-lock-doc-face ((t (:foreground ,blue-1 :extend t))))
     `(font-lock-doc-markup-face ((t (:inherit (font-lock-constant-face)))))
     `(font-lock-function-name-face ((t (:foreground ,blue-2))))
     `(font-lock-keyword-face ((t (:foreground ,purple-2))))
     '(font-lock-negation-char-face ((t (:inherit (homoglyph)))))
     `(font-lock-preprocessor-face ((t (:foreground ,brown-3 :inherit (bold)))))
     `(font-lock-regexp-grouping-backslash ((t (:foreground ,orange-1))))
     `(font-lock-regexp-grouping-construct ((t (:foreground ,orange-1))))
     `(font-lock-string-face ((t (:foreground ,green-2))))
     `(font-lock-type-face ((t (:foreground ,purple-1))))
     `(font-lock-variable-name-face ((t (:foreground ,brown-1))))
     '(font-lock-warning-face ((t (:inherit (warning)))))
     `(elisp-free-variable ((t (:underline (:color ,light-4 :style line)))))
     `(elisp-shadowed-variable ((t ( :inherit (elisp-bound-variable)
                                     :underline (:color ,light-4 :style line)))))
     `(link ((t ( :weight bold
                  :underline (:color foreground-color :style line)
                  :foreground ,accent-color))))
     `(link-visited ((t (:foreground ,link-visited-color))))
     `(fringe ((t (:foreground ,accent-color))))
     '(header-line ((t (:inherit (mode-line)))))
     '(header-line-inactive ((t (:inherit (mode-line-inactive)))))
     `(mode-line ((t ( :box ( :line-width (8 . 4)
                              :color ,headerbar-bg-color
                              :style nil)
                       :background ,headerbar-bg-color
                       :foreground ,headerbar-fg-color
                       :inherit (variable-pitch)))))
     `(mode-line-inactive ((t ( :box ( :line-width (8 . 4)
                                       :color ,headerbar-backdrop-color
                                       :style nil)
                                :background ,headerbar-backdrop-color
                                :foreground ,(mix headerbar-fg-color
                                                  headerbar-backdrop-color
                                                  0.5) ; #919193
                                :inherit (mode-line)))))
     '(mode-line-buffer-id ((t (:weight bold))))
     `(mode-line-emphasis ((t (:foreground ,accent-color))))
     `(mode-line-highlight
       ((t (:background ,(mix headerbar-fg-color headerbar-bg-color 0.15))))) ; #4d4d50
     '(eglot-mode-line ((t (:inherit (fringe)))))
     '(tab-bar ((t (:inherit (mode-line)))))
     '(tab-bar-tab ((t (:inherit (mode-line)))))
     '(tab-bar-tab-inactive ((t (:inherit (mode-line-inactive)))))
     `(window-divider ((t (:foreground ,headerbar-backdrop-color))))
     '(window-divider-first-pixel ((t (:inherit (window-divider)))))
     '(window-divider-last-pixel ((t (:inherit (window-divider)))))
     '(transient-key-exit ((t (:inherit (font-lock-function-name-face)))))
     '(transient-key-stay ((t (:inherit (font-lock-variable-name-face)))))
     '(transient-key-return ((t (:inherit (font-lock-warning-face)))))
     '(isearch ((t (:weight bold :inherit (lazy-highlight)))))
     `(isearch-fail ((t ( :weight bold
                          :foreground ,error-fg-color
                          :background ,error-bg-color))))
     `(lazy-highlight ((t ( :foreground ,source-search-fg-color
                            :background ,search-match-color))))
     '(next-error ((t (:inherit (region)))))
     '(query-replace ((t (:inherit (isearch)))))
     '(whitespace-tab ((t (:inherit (shadow)))))
     '(whitespace-trailing ((t (:inherit (secondary-selection)))))
     '(whitespace-missing-newline-at-eof ((t (:inherit (isearch-fail)))))
     '(page-break-lines ((t (:inherit (shadow)))))
     `(flyspell-incorrect ((t (:underline (:style wave :color ,error-bg-color)))))
     `(flyspell-duplicate ((t (:underline (:style wave :color ,warning-bg-color)))))
     `(Man-overstrike ((t (:foreground ,accent-color :inherit (bold fixed-pitch)))))
     `(Man-underline ((t (:foreground ,accent-color :inherit (italic fixed-pitch)))))
     '(woman-bold ((t (:inherit (Man-overstrike)))))
     '(woman-italic ((t (:inherit (Man-underline)))))
     '(dired-broken-symlink ((t (:inherit (error)))))
     `(dired-directory ((t (:foreground ,blue-2))))
     '(dired-flagged ((t (:strike-through t :inherit (error)))))
     `(dired-header ((t (:weight bold :foreground ,accent-color))))
     `(dired-mark ((t (:foreground ,accent-color))))
     `(dired-marked ((t ( :foreground ,view-fg-color
                          :background ,view-selected-color))))
     '(dired-perm-write ((t (:inherit (font-lock-function-name-face)))))
     '(dired-special ((t (:inherit (font-lock-keyword-face)))))
     '(dired-symlink ((t (:inherit (font-lock-variable-name-face)))))
     `(diff-header ((t ( :extend t
                         :foreground ,source-diff-location-fg-color
                         :background ,button-color))))
     `(diff-file-header ((t ( :extend t
                              :weight bold
                              :foreground ,source-diff-file-fg-color
                              :background ,view-bg-color))))
     `(diff-context ((t ( :extend t
                          :foreground ,source-text-fg-color
                          :background ,view-bg-color))))
     `(diff-removed ((t ( :extend t
                          :foreground ,source-diff-removed-line-fg-color
                          :background ,view-bg-color))))
     `(diff-added ((t ( :extend t
                        :foreground ,source-diff-added-line-fg-color
                        :background ,view-bg-color))))
     `(diff-changed ((t ( :extend t
                          :foreground ,source-diff-changed-line-fg-color
                          :background ,view-bg-color))))
     `(diff-changed-unspecified
       ((t ( :extend t
             :foreground ,source-diff-changed-line-fg-color
             :background ,view-bg-color))))
     `(diff-indicator-removed
       ((t (:foreground ,source-diff-removed-line-fg-color))))
     `(diff-indicator-added
       ((t (:foreground ,source-diff-added-line-fg-color))))
     `(diff-indicator-changed
       ((t (:foreground ,source-diff-changed-line-fg-color))))
     '(diff-error ((t (:inherit (error)))))
     `(ediff-current-diff-A
       ((t (:extend t :background ,(mix red-5 view-bg-color 0.25)))))
     `(ediff-current-diff-B
       ((t (:extend t :background ,(mix teal-5 view-bg-color 0.25)))))
     `(ediff-current-diff-C
       ((t (:extend t :background ,(mix orange-5 view-bg-color 0.25)))))
     `(ediff-current-diff-Ancestor
       ((t (:extend t :background ,(mix blue-5 view-bg-color 0.25)))))
     `(ediff-fine-diff-A
       ((t (:background ,(mix source-diff-removed-line-fg-color
                              source-current-line-bg-color
                              0.25)))))
     `(ediff-fine-diff-B
       ((t (:background ,(mix source-diff-added-line-fg-color
                              source-current-line-bg-color
                              0.25)))))
     `(ediff-fine-diff-C
       ((t (:background ,(mix source-diff-changed-line-fg-color
                              source-current-line-bg-color
                              0.25)))))
     `(ediff-even-diff-A
       ((t (:extend t :background ,source-current-line-bg-color))))
     `(ediff-even-diff-B
       ((t (:extend t :background ,source-current-line-bg-color))))
     `(ediff-even-diff-C
       ((t (:extend t :background ,source-current-line-bg-color))))
     `(ediff-even-diff-Ancestor
       ((t (:extend t :background ,source-current-line-bg-color))))
     `(ediff-odd-diff-A
       ((t (:extend t :background ,secondary-sidebar-bg-color))))
     `(ediff-odd-diff-B
       ((t (:extend t :background ,secondary-sidebar-bg-color))))
     `(ediff-odd-diff-C
       ((t (:extend t :background ,secondary-sidebar-bg-color))))
     `(ediff-odd-diff-Ancestor
       ((t (:extend t :background ,secondary-sidebar-bg-color))))
     `(magit-section-highlight
       ((t (:extend t :background ,source-current-line-bg-color))))
     `(magit-section-heading
       ((t (:extend t :weight bold :foreground ,accent-color))))
     `(magit-section-heading-selection
       ((t (:extend t :foreground ,warning-color))))
     '(magit-dimmed ((t (:inherit (shadow)))))
     `(magit-hash ((t (:foreground ,dark-1))))
     `(magit-tag ((t (:foreground ,yellow-1))))
     `(magit-branch-local ((t (:foreground ,blue-2))))
     `(magit-branch-current
       ((t ( :inherit (magit-branch-local)
             :underline (:color ,blue-2 :style line :position t)))))
     `(magit-branch-remote ((t (:foreground ,green-2))))
     `(magit-branch-remote-head
       ((t ( :inherit (magit-branch-remote)
             :underline (:color ,green-2 :style line :position t)))))
     `(magit-refname ((t (:foreground ,light-4))))
     '(magit-signature-good ((t (:inherit (success)))))
     '(magit-signature-bad ((t (:inherit (error)))))
     `(magit-signature-untrusted ((t (:foreground ,teal-2))))
     '(magit-signature-expired ((t (:inherit (warning)))))
     '(magit-signature-revoked ((t (:inherit (error)))))
     `(magit-signature-error ((t (:foreground ,blue-1))))
     `(magit-cherry-unmatched ((t (:foreground ,blue-2))))
     `(magit-cherry-equivalent ((t (:foreground ,purple-2))))
     `(magit-log-graph ((t (:foreground ,light-5))))
     `(magit-log-author ((t (:foreground ,brown-1))))
     '(magit-log-date ((t (:inherit (shadow)))))
     '(magit-diff-file-heading ((t (:inherit (diff-file-header)))))
     `(magit-diff-file-heading-selection
       ((t (:extend t :inherit (region magit-diff-file-heading-highlight)))))
     '(magit-diff-hunk-heading ((t (:inherit (diff-hunk-header)))))
     `(magit-diff-hunk-heading-highlight
       ((t ( :background ,button-hover-color
             :inherit (magit-diff-hunk-heading)))))
     `(magit-diff-hunk-heading-selection
       ((t (:extend t :inherit (region magit-diff-hunk-heading-highlight)))))
     `(magit-diff-lines-heading
       ((t (:extend t :inherit (region magit-diff-hunk-heading-highlight)))))
     '(magit-diff-hunk-region ((t (:extend t :inherit (region bold)))))
     `(magit-diff-our-heading
       ((t ( :extend t
             :foreground ,red-1
             :background ,(mix red-5 view-bg-color 0.25)))))
     `(magit-diff-base-heading
       ((t ( :extend t
             :foreground ,yellow-1
             :background ,(mix yellow-5 view-bg-color 0.25)))))
     `(magit-diff-their-heading
       ((t ( :extend t
             :foreground ,green-1
             :background ,(mix green-5 view-bg-color 0.25)))))
     '(magit-diff-context ((t (:inherit (diff-context)))))
     '(magit-diff-removed ((t (:inherit (diff-removed)))))
     '(magit-diff-added ((t (:inherit (diff-added)))))
     '(magit-diff-base ((t (:inherit (diff-changed)))))
     `(magit-diff-context-highlight
       ((t ( :background ,source-current-line-bg-color
             :inherit (magit-diff-context)))))
     `(magit-diff-removed-highlight
       ((t ( :background ,source-current-line-bg-color
             :inherit (magit-diff-removed)))))
     `(magit-diff-added-highlight
       ((t ( :background ,source-current-line-bg-color
             :inherit (magit-diff-added)))))
     `(magit-diff-base-highlight
       ((t ( :background ,source-current-line-bg-color
             :inherit (magit-diff-base)))))
     '(magit-diff-removed-indicator ((t (:inherit (diff-indicator-removed)))))
     '(magit-diff-added-indicator ((t (:inherit (diff-indicator-added)))))
     '(magit-diff-base-indicator ((t (:inherit (diff-indicator-changed)))))
     '(magit-diffstat-removed ((t (:inherit (diff-indicator-removed)))))
     '(magit-diffstat-added ((t (:inherit (diff-indicator-added)))))
     `(diff-refine-added
       ((t ( :foreground ,source-diff-added-line-fg-color
             :background ,(mix source-diff-added-line-fg-color
                               source-current-line-bg-color
                               0.25)))))
     `(diff-refine-removed
       ((t ( :foreground ,source-diff-removed-line-fg-color
             :background ,(mix source-diff-removed-line-fg-color
                               source-current-line-bg-color
                               0.25)))))
     `(diff-refine-changed
       ((t ( :foreground ,source-diff-changed-line-fg-color
             :background ,(mix source-diff-changed-line-fg-color
                               source-current-line-bg-color
                               0.25)))))
     `(magit-blame-highlight
       ((t ( :extend t
             :foreground ,view-fg-color
             :background ,headerbar-bg-color))))
     `(magit-process-ok
       ((t (:foreground ,success-color :inherit (magit-section-heading)))))
     `(magit-process-ng
       ((t (:foreground ,error-color :inherit (magit-section-heading)))))
     `(magit-bisect-good ((t (:foreground ,success-color))))
     `(magit-bisect-skip ((t (:foreground ,warning-color))))
     `(magit-bisect-bad ((t (:foreground ,error-color))))
     `(magit-sequence-stop ((t (:foreground ,blue-1))))
     `(magit-sequence-part ((t (:foreground ,warning-color))))
     `(magit-sequence-head ((t (:foreground ,success-color))))
     `(magit-sequence-drop ((t (:foreground ,error-color))))
     `(magit-reflog-commit ((t (:foreground ,success-color))))
     `(magit-reflog-amend ((t (:foreground ,purple-2))))
     `(magit-reflog-merge ((t (:foreground ,success-color))))
     `(magit-reflog-checkout ((t (:foreground ,blue-2))))
     `(magit-reflog-reset ((t (:foreground ,error-color))))
     `(magit-reflog-rebase ((t (:foreground ,purple-2))))
     `(magit-reflog-cherry-pick ((t (:foreground ,success-color))))
     `(magit-reflog-remote ((t (:foreground ,blue-2))))
     `(magit-reflog-other ((t (:foreground ,blue-2))))
     '(eshell-prompt ((t (:inherit (minibuffer-prompt)))))
     `(eshell-input ((t (:foreground ,accent-color))))
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
     '(ansi-color-bright-white ((t (:foreground "#f6f5f4" :background "#f6f5f4")))))))

(custom-theme-set-variables
 'adwaita
 '(magit-diff-highlight-hunk-region-functions
   '(magit-diff-highlight-hunk-region-dim-outside
     magit-diff-highlight-hunk-region-using-face)))

;;;###autoload
(when load-file-name
  (add-to-list 'custom-theme-load-path
               (file-name-directory load-file-name)))

(provide-theme 'adwaita)

;; Local Variables:
;; byte-compile-warnings: (not lexical)
;; End:

(provide 'adwaita-theme)
;;; adwaita-theme.el ends here
