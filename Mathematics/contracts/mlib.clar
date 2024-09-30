;; Enhanced Math Library in Clarity

;; Addition Function with overflow check
(define-read-only (add (a int) (b int))
  (let ((result (+ a b)))
    (if (and (>= result a) (>= result b))
        (ok result)
        (err u"Overflow occurred in addition"))))

;; Subtraction Function with underflow check
(define-read-only (subtract (a int) (b int))
  (let ((result (- a b)))
    (if (or (and (>= a b) (>= result 0)) (and (< a b) (<= result 0)))
        (ok result)
        (err u"Underflow occurred in subtraction"))))

;; Multiplication Function with overflow check
(define-read-only (multiply (a int) (b int))
  (let ((result (* a b)))
    (if (or (is-eq b 0) (is-eq (/ result b) a))
        (ok result)
        (err u"Overflow occurred in multiplication"))))


;; Division Function with error handling
(define-read-only (divide (a int) (b int))
  (if (is-eq b 0)
      (err u"Cannot divide by zero")
      (ok (/ a b))))

;; Square Function
(define-read-only (square (a int))
  (multiply a a))

;; Modular Function (renamed to avoid conflict with built-in 'mod' function)
(define-read-only (modular (a int) (b int))
  (if (is-eq b 0)
      (err u"Cannot perform modulo by zero")
      (ok (mod a b))))

;; Absolute Value Function
(define-read-only (absolute (a int))
  (if (< a 0)
      (ok (- a))
      (ok a)))

;; Average Function with overflow protection
(define-read-only (average (a int) (b int))
  (let 
    (
      (sum (add a b))
      (half (/ (+ a b) 2))
    )
    (match sum
      success (ok half)
      error (err u"Overflow occurred while calculating average"))))

;; Maximum Function
(define-read-only (maximum (a int) (b int))
  (ok (if (>= a b) a b)))

;; Is Even Function
(define-read-only (is-even (a int))
  (ok (is-eq (mod a 2) 0)))