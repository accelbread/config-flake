#!@guile@/bin/guile \
--no-auto-compile -s
!#
;; Copyright (C) Archit Gupta <archit@accelbread.com>
;; SPDX-License-Identifier: AGPL-3.0-or-later

(use-modules (ice-9 ftw)
             (srfi srfi-13))

(define (run bin) (apply execl (cons* bin bin (cdr (command-line)))))

(define (nom-run bin)
  (setenv "_NIX_INSIDE_NOM" "1")
  (run bin))

(define (nix) (run "@nix@/bin/nix"))
(define (nix-build) (run "@nix@/bin/nix-build"))
(define (nix-shell) (run "@nix@/bin/nix-shell"))
(define (nixos-rebuild) (run "@nixos-rebuild-ng@/bin/nixos-rebuild"))
(define (nom) (nom-run "@nix-output-monitor@/bin/nom"))
(define (nom-build) (nom-run "@nix-output-monitor@/bin/nom-build"))
(define (nom-shell) (nom-run "@nix-output-monitor@/bin/nom-shell"))

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
  (execl "@bash@/bin/bash" "@bash@/bin/bash" "-c"
         (string-append
          "set -eo pipefail; "
          "@nixos-rebuild-ng@/bin/nixos-rebuild "
          (string-join (map shell-quote (cdr (command-line))) " ")
          " --log-format internal-json |& "
          "@nix-output-monitor@/bin/nom --json")))

(define inside-nom (getenv "_NIX_INSIDE_NOM"))

(when inside-nom
  (setenv "_NIX_INSIDE_NOM" #f))

(define term (and (not inside-nom)
                  (not (string-prefix? "dumb" (or (getenv "TERM") "")))
                  (not (getenv "NO_COLOR"))
                  (isatty? (current-output-port))))

(case (string->symbol (basename (car (command-line))))
  ((nixos-rebuild) (if term (nixos-rebuild-nom) (nixos-rebuild)))
  ((nix-build) (if term (nom-build) (nix-build)))
  ((nix-shell) (if term (nom-shell) (nix-shell)))
  ((nix) (if (and term
                  (pair? (cdr (command-line)))
                  (member (cadr (command-line))
                          '("build" "shell" "develop" "copy" "flake")))
             (nom) (nix))))

(exit 1)
