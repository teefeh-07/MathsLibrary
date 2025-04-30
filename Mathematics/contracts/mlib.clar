;; Enhanced Math Library for Stacks Blockchain
;; Version 2.0
;; This library provides comprehensive math operations with safety checks
;; All functions return (ok value) on success and (err error-message) on failure

;; ------ BASIC ARITHMETIC OPERATIONS ------

;; Addition Function with overflow check
(define-read-only (add (a int) (b int))
  (let ((result (+ a b)))
    (if (or 
          (and (> a 0) (> b 0) (< result a)) 
          (and (< a 0) (< b 0) (> result a)))
        (err u"Overflow occurred in addition")
        (ok result))))

;; Subtraction Function with underflow check
(define-read-only (subtract (a int) (b int))
  (let ((result (- a b)))
    (if (or 
          (and (> a 0) (< b 0) (< result a)) 
          (and (< a 0) (> b 0) (> result a)))
        (err u"Underflow occurred in subtraction")
        (ok result))))

;; Multiplication Function with overflow check
(define-read-only (multiply (a int) (b int))
  (let ((result (* a b)))
    (if (or (is-eq a 0) (is-eq b 0))
        (ok 0)
        (if (and (> a 0) (> b 0) (< result a))
            (err u"Overflow occurred in multiplication")
            (if (and (< a 0) (< b 0) (> result a))
                (err u"Overflow occurred in multiplication")
                (if (and (> a 0) (< b 0) (> result a))
                    (err u"Overflow occurred in multiplication")
                    (if (and (< a 0) (> b 0) (< result a))
                        (err u"Overflow occurred in multiplication")
                        (if (is-eq (/ result a) b)
                            (ok result)
                            (err u"Overflow occurred in multiplication")))))))))

;; Division Function with error handling
(define-read-only (divide (a int) (b int))
  (if (is-eq b 0)
      (err u"Cannot divide by zero")
      (ok (/ a b))))

;; Integer Division Function that returns whole quotient only
(define-read-only (div-integer (a int) (b int))
  (if (is-eq b 0)
      (err u"Cannot divide by zero")
      (ok (/ a b))))

;; ------ MODULAR ARITHMETIC ------

;; Modular Function (renamed to avoid conflict with built-in 'mod' function)
(define-read-only (modular (a int) (b int))
  (if (is-eq b 0)
      (err u"Cannot perform modulo by zero")
      (ok (mod a b))))

;; Modular Exponentiation (a^b mod m) - Efficient power calculation with modulo
;; (define-read-only (mod-power (base int) (exponent uint) (modulus int))
;;   (if (is-eq modulus 0)
;;       (err u"Cannot perform modulo by zero")
;;       (ok (mod-power-internal base exponent modulus 1))))

;; Helper function for modular exponentiation using binary exponentiation
;; (define-private (mod-power-internal (base int) (exponent uint) (modulus int) (result int))
;;   (if (is-eq exponent u0)
;;       result
;;       (let ((next-result (if (is-eq (mod exponent 2) 1)
;;                              (mod (* result base) modulus)
;;                              result))
;;             (next-base (mod (* base base) modulus))
;;             (next-exponent (/ exponent u2)))
;;         (mod-power-internal next-base next-exponent modulus next-result))))

;; ------ BASIC MATH FUNCTIONS ------

;; Square Function
(define-read-only (square (a int))
  (multiply a a))

;; Power Function (a^n) - Integer exponentiation
;; (define-read-only (power (base int) (exponent uint))
;;   (power-internal base exponent 1))

;; ;; Helper function for power calculation
;; ;; Power Function (a^n) - Integer exponentiation
;; (define-read-only (power (base int) (exponent uint))
;;   (ok (power-internal base exponent 1)))

;; ;; Helper function for power calculation
;; (define-private (power-internal (base int) (exponent uint) (result int))
;;   (cond
;;     ((is-eq exponent u0) result)
;;     ((is-eq (mod exponent 2) 1) 
;;       (power-internal (* base base) (/ exponent u2) (* result base)))
;;     (true (power-internal (* base base) (/ exponent u2) result))))
;;       (ok a)

;; Sign Function (-1 for negative, 0 for zero, 1 for positive)
;; (define-read-only (sign (a int))
;;   (cond
;;     ((< a 0) (ok -1))
;;     ((> a 0) (ok 1))
;;     (true (ok 0))))

;; ------ AGGREGATE OPERATIONS ------

;; Average Function with overflow protection
(define-read-only (average (a int) (b int))
  (match (add a b)
    sum (ok (/ sum 2))
    error (err error)))

;; Weighted Average (a*weight_a + b*weight_b)/(weight_a + weight_b)
;; (define-read-only (weighted-average (a int) (weight-a uint) (b int) (weight-b uint))
;;   (begin
;;     (if (and (is-eq weight-a u0) (is-eq weight-b u0))
;;         (err u"Both weights cannot be zero")
;; ;; Weighted Average (a*weight_a + b*weight_b)/(weight_a + weight_b)
;; (define-read-only (weighted-average (a int) (weight-a uint) (b int) (weight-b uint))
;;   (if (and (is-eq weight-a u0) (is-eq weight-b u0))
;;       (err u"Both weights cannot be zero")
;;       (let
;;         (
;;           (prod-a (match (multiply a (unwrap-panic (to-int weight-a)))
;;                     success success
;;                     error (err error)))
;;           (prod-b (match (multiply b (unwrap-panic (to-int weight-b)))
;;                     success success
;;                     error (err error)))
;;         )
;;         (match prod-a
;;           success-a 
;;             (match prod-b
;;               success-b 
;;                 (match (add success-a success-b)
;;                   sum (ok (/ sum (unwrap-panic (to-int (+ weight-a weight-b)))))
;;                   error (err error))
;;               error-b (err error-b))
;;           error-a (err error-a)))))
;; Minimum Function
(define-read-only (minimum (a int) (b int))
  (ok (if (<= a b) a b)))

;; ------ NUMERIC PROPERTY FUNCTIONS ------

;; Is Even Function
(define-read-only (is-even (a int))
  (ok (is-eq (mod a 2) 0)))

;; Is Odd Function
(define-read-only (is-odd (a int))
  (ok (is-eq (mod a 2) 1)))

;; Is Positive Function
(define-read-only (is-positive (a int))
  (ok (> a 0)))

;; Is Negative Function
(define-read-only (is-negative (a int))
  (ok (< a 0)))

;; Is Zero Function
(define-read-only (is-zero (a int))
  (ok (is-eq a 0)))

;; ------ CONVERSION FUNCTIONS ------

;; Integer to uint conversion with validation
(define-read-only (to-uint (a int))
  (if (>= a 0)
      (ok (unwrap-panic (to-uint a)))
      (err u"Cannot convert negative number to uint")))
;; Integer to uint conversion with validation
(define-read-only (to-uint (a int))
  (if (>= a 0)
      (ok (unwrap-panic (to-uint a)))
      (err u"Cannot convert negative number to uint")))

;; Uint to int conversion (always safe)
(define-read-only (to-int (a uint))
  (ok (unwrap-panic (to-int a))))
(define-constant FIXED-POINT-FACTOR 1000000)

;; Convert integer to fixed-point representation
(define-read-only (to-fixed-point (a int))
  (multiply a FIXED-POINT-FACTOR))

;; Multiply two fixed-point numbers
(define-read-only (fixed-multiply (a int) (b int))
  (match (multiply a b)
    product (ok (/ product FIXED-POINT-FACTOR))
    error (err error)))

;; Divide two fixed-point numbers
(define-read-only (fixed-divide (a int) (b int))
  (if (is-eq b 0)
      (err u"Cannot divide by zero")
      (match (multiply a FIXED-POINT-FACTOR)
        product (ok (/ product b))
        error (err error))))

;; Square root approximation for fixed-point numbers using Newton's method
;; Returns result with 6 decimal places precision
(define-public (sqrt (x int))
  (begin
    (asserts! (>= x 0) (err u"Cannot calculate square root of negative number"))
;; Square root approximation for fixed-point numbers using Newton's method
;; Returns result with 6 decimal places precision
(define-read-only (sqrt (x int))
  (if (< x 0)
      (err u"Cannot calculate square root of negative number")
      (if (is-eq x 0)
          (ok 0)
          (ok (sqrt-newton x (/ (+ x 1) 2) 10)))))  ;; 10 iterations for good precision

;; Helper function for Newton's method of square root approximation
(define-private (sqrt-newton (x int) (guess int) (iterations int))
  (if (is-eq iterations 0)
      guess
      (let ((new-guess (/ (+ guess (/ x guess)) 2)))
        (sqrt-newton x new-guess (- iterations 1)))))

;; Sine approximation using Taylor series (fixed-point result)
(define-read-only (sin (angle-rad int))
  (let
    ((normalized-angle (mod angle-rad (* 2 FIXED-POINT-FACTOR 314159 10))))  ;; Normalize to [0, 2)
    (match (add 
             normalized-angle 
             (match (multiply 
                     (multiply 
                       (multiply normalized-angle normalized-angle) 
                       normalized-angle) 
                     (/ -1 (* 6 FIXED-POINT-FACTOR)))
               term (ok term)
               error (err error)))
      result (ok result)
      error (err error))))

;; Cosine approximation using Taylor series (fixed-point result)
(define-read-only (cos (angle-rad int))
  (let
    ((normalized-angle (mod angle-rad (* 2 FIXED-POINT-FACTOR 314159 10))))  ;; Normalize to [0, 2)
    (match (add 
            FIXED-POINT-FACTOR
            (match (multiply
                    (multiply normalized-angle normalized-angle)
                    (/ -1 (* 2 FIXED-POINT-FACTOR)))
              term (ok term)
              error (err error)))
      result (ok result)
      error (err error))))

;; ------ UTILITY FUNCTIONS ------

;; Greatest Common Divisor (GCD) using Euclidean algorithm
(define-read-only (gcd (a int) (b int))
  (match (absolute a)
    abs-a (match (absolute b)
            abs-b (ok (gcd-internal abs-a abs-b))
            error (err error))
    error (err error)))

;; Helper function for GCD calculation
(define-private (gcd-internal (a int) (b int))
  (if (is-eq b 0)
      a
      (gcd-internal b (mod a b))))

;; Least Common Multiple (LCM)
(define-read-only (lcm (a int) (b int))
  (match (absolute a)
    abs-a (match (absolute b)
            abs-b (if (or (is-eq abs-a 0) (is-eq abs-b 0))
                      (ok 0)
                      (match (multiply abs-a abs-b)
                        product (ok (/ product (gcd-internal abs-a abs-b)))
                        error (err error)))
            error (err error))
    error (err error)))

;; Factorial function (n!)
(define-read-only (factorial (n uint))
  (if (> n u20)  ;; Limit to prevent overflow
      (err u"Input too large for factorial calculation")
      (ok (factorial-internal n))))
;; Factorial function (n!)
(define-read-only (factorial (n uint))
  (if (> n u20)  ;; Limit to prevent overflow
      (err u"Input too large for factorial calculation")
      (ok (factorial-internal n 1))))

;; Helper function for factorial calculation (tail-recursive)
(define-private (factorial-internal (n uint) (acc int))
  (if (<= n u1)
      acc
      (factorial-internal (- n u1) (* acc (unwrap-panic (to-int n))))))
      (ok (fibonacci-internal n))))
;; Fibonacci sequence function
(define-read-only (fibonacci (n uint))
  (if (> n u50)  ;; Limit to prevent overflow
      (err u"Input too large for Fibonacci calculation")
      (ok (fibonacci-internal n 0 1))))

;; Helper function for Fibonacci calculation (tail-recursive)
(define-private (fibonacci-internal (n uint) (a int) (b int))
  (if (is-eq n u0)
      a
      (fibonacci-internal (- n u1) b (+ a b)))))))