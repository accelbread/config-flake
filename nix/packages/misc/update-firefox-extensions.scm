;; Copyright (C) Archit Gupta <archit@accelbread.com>
;; SPDX-License-Identifier: AGPL-3.0-or-later

(use-modules (ice-9 format)
             (ice-9 match)
             (ice-9 receive)
             (json)
             (rnrs bytevectors)
             (web client)
             (web response)
             (web uri))

(define (fetch-json url)
  (receive (response body) (http-get url)
    (unless (= (response-code response) 200)
      (error "AMO request failed" url (response-code response)))
    (json-string->scm (utf8->string body))))

(define refresh-extension
  (match-lambda
    ((name . current)
     (let* ((addon-id (assoc-ref current "addonId"))
            (addon (fetch-json
                    (string-append "https://addons.mozilla.org/api/v5/addons/addon/"
                                   (uri-encode addon-id) "/")))
            (version (assoc-ref addon "current_version"))
            (artifact (assoc-ref version "file")))
       (unless (equal? (assoc-ref addon "guid") addon-id)
         (error "Unexpected extension ID" name (assoc-ref addon "guid")))
       (format #t "~a: ~a -> ~a~%" name
               (or (assoc-ref current "version") "(new)")
               (assoc-ref version "version"))
       (cons name
             `(("addonId" . ,addon-id)
               ("version" . ,(assoc-ref version "version"))
               ("url" . ,(assoc-ref artifact "url"))
               ("hash" . ,(assoc-ref artifact "hash"))))))))

(match (command-line)
  ((_ file)
   (let* ((extensions (call-with-input-file file
                        (lambda (port)
                          (json->scm port #:ordered #t))))
          (updated (map refresh-extension extensions)))
     (call-with-output-file file
       (lambda (port)
         (scm->json updated port #:pretty #t)
         (newline port)))))
  (_ (error "Expected a JSON file argument")))
