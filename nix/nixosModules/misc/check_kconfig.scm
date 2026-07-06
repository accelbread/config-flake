(use-modules (ice-9 rdelim)
             (ice-9 regex)
             (ice-9 hash-table))

(define input-desired (with-input-from-file (list-ref (command-line) 1)
                        (lambda () (read))))
(define input-configfile (open-input-file (list-ref (command-line) 2)))

(define config (make-hash-table))

(define success #t)

(define (error-cont fmt . args)
  (apply format (current-error-port)
         (string-append "Error: " fmt "\n")
         args)
  (set! success #f))

(define (process-lines)
  (let ((line (read-line input-configfile)))
    (unless (eof-object? line)
      (cond
       ((string-match "^CONFIG_([A-Za-z0-9_]+)=(y|m)$" line) =>
        (lambda (match) (hashq-set! config (string->symbol (match:substring match 1))
                               (string->symbol (match:substring match 2)))))
       ((string-match "^# CONFIG_([A-Za-z0-9_]+) is not set$" line) =>
        (lambda (match) (hashq-set! config (string->symbol (match:substring match 1))
                               'n)))
       ((string-match "^CONFIG_([A-Za-z0-9_]+)=\"(.*)\"$" line) =>
        (lambda (match) (hashq-set! config (string->symbol (match:substring match 1))
                               (match:substring match 2))))
       ((string-match "^CONFIG_([A-Za-z0-9_]+)=(-?[0-9]+|0x[0-9a-f]+)$" line) =>
        (lambda (match) (hashq-set! config (string->symbol (match:substring match 1))
                               (match:substring match 2))))
       ((string-match "^(#.*)?$" line))
       (else (error-cont "unhandled config line: ~a" line)))
      (process-lines))))

(process-lines)

(define (check key val)
  (let ((result (hashq-ref config key 'unset)))
    (unless (equal? val result)
      (error-cont "wanted ~a ~a, got ~a" key val result))))

(for-each (lambda (p) (check (car p) (cdr p))) input-desired)

(quit success)
