;;; my-purple-theme.el --- Custom theme -*- lexical-binding: t; -*-

;;; Commentary:

;; Personal custom theme

;;; Code:

(deftheme my-purple)

(custom-theme-set-faces
 'my-purple
 '(default ((t (:background "#262330" :foreground "#E7E4F2"))))
 '(variable-pitch-text ((t (:inherit (variable-pitch)))))
 '(cursor ((t (:background "#A08BEF"))))
 '(homoglyph ((t (:foreground "#00FFFF" :inherit (bold)))))
 '(escape-glyph ((t (:inherit (homoglyph)))))
 '(minibuffer-prompt ((t (:foreground "#A08BEF"))))
 '(highlight ((t (:foreground "#E7E4F2" :background "#40385C"))))
 '(region ((t (:extend nil :background "#40385C"))))
 '(shadow ((t (:foreground "#716A8A"))))
 '(warning ((t (:weight bold :foreground "#FFFF80"))))
 '(success ((t (:weight bold :foreground "#80FF80"))))
 '(error ((t (:weight bold :foreground "#FF8080"))))
 '(secondary-selection ((t (:extend nil :background "#383F5C"))))
 '(trailing-whitespace ((t (:background "#40385C"))))
 '(font-lock-builtin-face ((t (:foreground "#A08BEF"))))
 '(font-lock-comment-delimiter-face ((default (:inherit (font-lock-comment-face)))))
 '(font-lock-comment-face ((t (:foreground "#7864BF" :extend t))))
 '(font-lock-constant-face ((t (:foreground "#66CCCC"))))
 '(font-lock-doc-face ((t (:foreground "#A395D4" :extend t))))
 '(font-lock-doc-markup-face ((t (:inherit (font-lock-constant-face)))))
 '(font-lock-function-name-face ((t (:foreground "#FF80DE"))))
 '(font-lock-keyword-face ((t (:foreground "#A08BEF"))))
 '(font-lock-negation-char-face ((t (:inherit (homoglyph)))))
 '(font-lock-preprocessor-face ((t (:foreground "#838CF4" :inherit (bold)))))
 '(font-lock-regexp-grouping-backslash ((t (:foreground "#80A2FF"))))
 '(font-lock-regexp-grouping-construct ((t (:foreground "#80A2FF"))))
 '(font-lock-string-face ((t (:foreground "#80FFCA"))))
 '(font-lock-type-face ((t (:foreground "#E780FF"))))
 '(font-lock-variable-name-face ((t (:foreground "#62B0FC"))))
 '(font-lock-warning-face ((t (:inherit (warning)))))
 '(button ((t (:inherit (link)))))
 '(link ((t (:weight bold :underline (:color foreground-color :style line) :foreground "#62B0FC"))))
 '(link-visited ((t (:foreground "#E780FF"))))
 '(fringe ((t (:foreground "#A08BEF"))))
 '(header-line ((t (:inherit (mode-line)))))
 '(mode-line ((t (:box (:line-width (8 . 4) :color "#1A1821" :style nil) :background "#1A1821" :foreground "#D7CDFF" :inherit (variable-pitch)))))
 '(mode-line-flash ((t (:background "#D7CDFF" :foreground "#1A1821" :inherit (mode-line)))))
 '(mode-line-inactive ((t (:inherit (shadow mode-line)))))
 '(mode-line-buffer-id ((t (:weight bold))))
 '(mode-line-emphasis ((t (:foreground "#FF80DE"))))
 '(mode-line-highlight ((t (:inherit (highlight)))))
 '(eglot-mode-line ((t (:inherit (fringe)))))
 '(window-divider ((t (:foreground "#1A1821"))))
 '(window-divider-first-pixel ((t (:inherit (window-divider)))))
 '(window-divider-last-pixel ((t (:inherit (window-divider)))))
 '(isearch ((t (:weight bold :inherit (lazy-highlight)))))
 '(isearch-fail ((t (:weight bold :foreground "#1A1821" :background "#FF8080"))))
 '(lazy-highlight ((t (:inherit secondary-selection))))
 '(next-error ((t (:inherit (region)))))
 '(query-replace ((t (:inherit (isearch)))))
 '(whitespace-tab ((t (:inherit (shadow)))))
 '(whitespace-trailing ((t (:inherit (secondary-selection)))))
 '(whitespace-missing-newline-at-eof ((t (:inherit (isearch-fail)))))
 '(page-break-lines ((t (:inherit (shadow)))))
 '(vundo-highlight ((t (:inherit (minibuffer-prompt)))))
 '(jinx-misspelled ((t (:underline (:style wave :color "#FF0000")))))
 '(jinx-save ((t (:inherit (font-lock-builtin-face)))))
 '(evil-ex-info ((t (:inherit (minibuffer-prompt)))))
 '(evil-ex-substitute-matches ((t (:strike-through t :inherit (error)))))
 '(evil-ex-substitute-replacement ((t (:inherit (success)))))
 '(evil-ex-info ((t (:inherit (minibuffer-prompt)))))
 '(Man-overstrike ((t (:foreground "#A08BEF" :inherit (bold fixed-pitch)))))
 '(Man-underline ((t (:foreground "#66CCCC" :inherit (italic fixed-pitch)))))
 '(woman-bold ((t (:inherit (Man-overstrike)))))
 '(woman-italic ((t (:inherit (Man-underline)))))
 '(rainbow-delimiters-depth-1-face ((t (:foreground  "#BF7FFF"))))
 '(rainbow-delimiters-depth-2-face ((t (:foreground  "#7FBFFF"))))
 '(rainbow-delimiters-depth-3-face ((t (:foreground  "#7FFFBF"))))
 '(rainbow-delimiters-depth-4-face ((t (:foreground  "#BFFF7F"))))
 '(rainbow-delimiters-depth-5-face ((t (:foreground  "#FFBF7F"))))
 '(rainbow-delimiters-depth-6-face ((t (:foreground  "#FF7FBF"))))
 '(rainbow-delimiters-base-error-face ((t (:foreground "#FF0000" :background "#000000"))))
 '(company-tooltip ((t (:background "#1A1821"))))
 '(company-tooltip-common ((t (:foreground "#A08BEF"))))
 '(company-tooltip-selection ((t (:background "#40385C"))))
 '(company-tooltip-annotation ((t (:foreground "#66CCCC"))))
 '(company-scrollbar-bg ((t (:background "#201E29"))))
 '(company-scrollbar-fg ((t (:background "#A08BEF"))))
 '(dired-broken-symlink ((t (:inherit (error)))))
 '(dired-directory ((t (:inherit (font-lock-preprocessor-face)))))
 '(dired-flagged ((t (:strike-through t :inherit (error)))))
 '(dired-header ((t (:inherit (font-lock-keyword-face)))))
 '(dired-mark ((t (:inherit (font-lock-keyword-face)))))
 '(dired-marked ((t (:weight bold :inherit (font-lock-string-face)))))
 '(dired-perm-write ((t (:foreground "#A395D4"))))
 '(dired-special ((t (:inherit (font-lock-function-name-face)))))
 '(dired-symlink ((t (:inherit (font-lock-constant-face)))))
 '(eshell-prompt ((t (:inherit (minibuffer-prompt)))))
 '(eshell-input ((t (:inherit (font-lock-function-name-face)))))
 '(eshell-ls-executable ((t (:inherit (font-lock-type-face)))))
 '(eshell-ls-directory ((t (:inherit (dired-directory)))))
 '(eshell-ls-special ((t (:inherit (dired-special)))))
 '(eshell-ls-symlink ((t (:inherit (dired-symlink)))))
 '(eshell-ls-readonly ((t (:foreground "#A395D4"))))
 '(eshell-ls-unreadable ((t (:inherit (shadow)))))
 '(eshell-ls-missing ((t (:inherit (dired-broken-symlink)))))
 '(eshell-syntax-highlighting-shell-command-face ((t (:inherit (eshell-ls-executable)))))
 '(eshell-syntax-highlighting-alias-face ((t (:inherit (font-lock-constant-face)))))
 '(eshell-syntax-highlighting-file-arg-face ((t (:inherit (eshell-ls-directory)))))
 '(eshell-syntax-highlighting-directory-face ((t (:inherit (eshell-ls-directory)))))
 '(git-annex-dired-annexed-available ((t (:inherit (dired-symlink)))))
 '(git-annex-dired-annexed-unavailable ((t (:inherit (dired-broken-symlink)))))
 '(org-block ((t (:inherit (fixed-pitch)))))
 '(org-code ((t (:inherit (fixed-pitch)))))
 '(term-color-black ((t (:foreground "#1A1821" :background "#1A1821"))))
 '(term-color-red ((t (:foreground "#FF8080" :background "#FF8080"))))
 '(term-color-green ((t (:foreground "#80FF80" :background "#80FF80"))))
 '(term-color-yellow ((t (:foreground "#FFFF80" :background "#FFFF80"))))
 '(term-color-blue ((t (:foreground "#8080FF" :background "#8080FF"))))
 '(term-color-magenta ((t (:foreground "#FF80FF" :background "#FF80FF"))))
 '(term-color-cyan ((t (:foreground "#80FFFF" :background "#80FFFF"))))
 '(term-color-white ((t (:foreground "#E7E4F2" :background "#E7E4F2"))))
 '(term-color-bright-black ((t (:foreground "#655D80" :background "#655D80"))))
 '(term-color-bright-red ((t (:foreground "#FF5050" :background "#FF5050"))))
 '(term-color-bright-green ((t (:foreground "#50FF50" :background "#50FF50"))))
 '(term-color-bright-yellow ((t (:foreground "#FFFF50" :background "#FFFF50"))))
 '(term-color-bright-blue ((t (:foreground "#5050FF" :background "#5050FF"))))
 '(term-color-bright-magenta ((t (:foreground "#FF50FF" :background "#FF50FF"))))
 '(term-color-bright-cyan ((t (:foreground "#50FFFF" :background "#50FFFF"))))
 '(term-color-bright-white ((t (:foreground "#FFFFFF" :background "#FFFFFF"))))
 '(ansi-color-black ((t (:inherit (term-color-black)))))
 '(ansi-color-red ((t (:inherit (term-color-red)))))
 '(ansi-color-green ((t (:inherit (term-color-green)))))
 '(ansi-color-yellow ((t (:inherit (term-color-yellow)))))
 '(ansi-color-blue ((t (:inherit (term-color-blue)))))
 '(ansi-color-magenta ((t (:inherit (term-color-magenta)))))
 '(ansi-color-cyan ((t (:inherit (term-color-cyan)))))
 '(ansi-color-white ((t (:inherit (term-color-white)))))
 '(ansi-color-bright-black ((t (:inherit (term-color-bright-black)))))
 '(ansi-color-bright-red ((t (:inherit (term-color-bright-red)))))
 '(ansi-color-bright-green ((t (:inherit (term-color-bright-green)))))
 '(ansi-color-bright-yellow ((t (:inherit (term-color-bright-yellow)))))
 '(ansi-color-bright-blue ((t (:inherit (term-color-bright-blue)))))
 '(ansi-color-bright-magenta ((t (:inherit (term-color-bright-magenta)))))
 '(ansi-color-bright-cyan ((t (:inherit (term-color-bright-cyan)))))
 '(ansi-color-bright-white ((t (:inherit (term-color-bright-white)))))
 '(vterm-color-black ((t (:foreground "#1A1821" :background "#655D80"))))
 '(vterm-color-red ((t (:foreground "#FF8080" :background "#FF0000"))))
 '(vterm-color-green ((t (:foreground "#80FF80" :background "#00FF00"))))
 '(vterm-color-yellow ((t (:foreground "#FFFF80" :background "#FFFF00"))))
 '(vterm-color-blue ((t (:foreground "#8080FF" :background "#0000FF"))))
 '(vterm-color-magenta ((t (:foreground "#FF80FF" :background "#FF00FF"))))
 '(vterm-color-cyan ((t (:foreground "#80FFFF" :background "#00FFFF"))))
 '(vterm-color-white ((t (:foreground "#E7E4F2" :background "#FFFFFF")))))

(custom-theme-set-variables
 'my-purple
 '(rainbow-delimiters-max-face-count 6)
 '(orderless-match-faces [rainbow-delimiters-depth-1-face
                          rainbow-delimiters-depth-2-face
                          rainbow-delimiters-depth-3-face
                          rainbow-delimiters-depth-4-face
                          rainbow-delimiters-depth-5-face
                          rainbow-delimiters-depth-6-face]))

(provide-theme 'my-purple)

(provide 'my-purple-theme)
;;; my-purple-theme.el ends here
