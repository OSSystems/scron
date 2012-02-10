(use srfi-1 srfi-18 posix)
(declare (uses chicken-syntax))

(define (schedule! basedir)
  (let ((wait-for-thread #f))
    (for-each
     (lambda (dir)
       (let ((interval (string->number (pathname-strip-directory dir))))
         (when interval
           (set! wait-for-thread
                 (thread-start!
                  (lambda ()
                    (let loop ()
                      (let ((files (append (glob (make-pathname dir "*.scm"))
                                           (glob (make-pathname dir "*.so")))))
                        (for-each load files))
                      (thread-sleep! interval)
                      (loop))))))))
     (filter directory? (glob (make-pathname basedir "*"))))
    (when wait-for-thread (thread-join! wait-for-thread))))

(define (usage #!optional exit-code)
  (print "Usage: " (pathname-strip-directory (program-name)) " <basedir>")
  (when exit-code (exit exit-code)))

(let ((args (command-line-arguments)))
  (when (or (null? args)
            (member "-h" args)
            (member "--help" args))
    (usage 0))
  (schedule! (car args)))
