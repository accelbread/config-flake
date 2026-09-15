#!@guile@/bin/guile \
--no-auto-compile -s
!#
;; Copyright (C) Archit Gupta <archit@accelbread.com>
;; SPDX-License-Identifier: AGPL-3.0-or-later

(use-modules (ice-9 ftw)
             (srfi srfi-13))

(define nix "@nix@/bin/nix")
(define nom "@nix-output-monitor@/bin/nom")
(define nixos-rebuild "@nixos-rebuild-ng@/bin/nixos-rebuild")
(define bash "@bash@/bin/bash")

(define (run bin) (apply execl (cons bin (command-line))))

(define (shell-quote arg)
  (call-with-output-string
    (lambda (port)
      (write-char #\' port)
      (string-for-each
       (lambda (char)
         (if (char=? char #\')
             (display "'\\''" port)
             (write-char char port)))
       arg)
      (write-char #\' port))))

(define (nixos-rebuild-nom)
  (execl bash bash "-c"
         (string-append
          "set -eo pipefail; "
          (shell-quote nixos-rebuild) " "
          (string-join (map shell-quote (cdr (command-line))) " ")
          " --log-format internal-json -v |& "
          (shell-quote nom) " --json")))

(define term (and (not (string-prefix? "dumb" (or (getenv "TERM") "")))
                  (not (getenv "NO_COLOR"))
                  (isatty? (current-output-port))))

(case (string->symbol (basename (car (command-line))))
  ((nixos-rebuild) (if term (nixos-rebuild-nom) (run nixos-rebuild)))
  ((nix-build) (run (string-append (if term nom nix) "-build")))
  ((nix-shell) (run (string-append (if term nom nix) "-shell")))
  ((nix) (if (and term
                  (pair? (cdr (command-line)))
                  (member (cadr (command-line))
                          '("build" "shell" "develop" "copy" "flake")))
             (run nom) (run nix))))

(exit 1)
