;; Enhanced Math Library in Clarity
;; A comprehensive mathematical utility library with robust error handling
;; and a diverse set of common mathematical operations.

;; ========== Constants ==========

(define-constant ERR-OVERFLOW u"Arithmetic overflow occurred")
(define-constant ERR-UNDERFLOW u"Arithmetic underflow occurred")
(define-constant ERR-DIVIDE-BY-ZERO u"Cannot divide by zero")
(define-constant ERR-NEGATIVE-ROOT u"Cannot compute square root of negative number")
(define-constant ERR-NEGATIVE-LOG u"Cannot compute logarithm of non-positive number")
(define-constant ERR-DOMAIN-ERROR u"Input value outside valid domain")

;; ========== Basic Arithmetic Functions ==========

;; Addition Function with overflow check
;; @param a (int) - First integer operand
;; @param b (int) - Second integer operand
;; @returns (response int string) - Returns result or error message
(define-read-only (add (a int) (b int))
  (let ((result (+ a b)))
    (if (or 
          ;; Check if signs are the same and overflow occurred
          (and (> a 0) (> b 0) (< result 0))
          (and (< a 0) (< b 0) (> result 0)))
        (err ERR-OVERFLOW)
        (ok result))))

;; Subtraction Function with underflow check
;; @param a (int) - First integer operand
;; @param b (int) - Second integer operand
;; @returns (response int string) - Returns result or error message
(define-read-only (subtract (a int) (b int))
  (let ((result (- a b)))
    (if (or
          ;; Check for underflow scenarios
          (and (> a 0) (< b 0) (< result a))
          (and (< a 0) (> b 0) (> result a)))
        (err ERR-UNDERFLOW)
        (ok result))))

;; Multiplication Function with improved overflow check
;; @param a (int) - First integer operand
;; @param b (int) - Second integer operand
;; @returns (response int string) - Returns result or error message
(define-read-only (multiply (a int) (b int))
  (let ((result (* a b)))
    (if (or (is-eq a 0) (is-eq b 0))
        (ok 0)
        (if (or 
              (is-eq (/ result a) b) 
              (is-eq (/ result b) a))
            (ok result)
            (err ERR-OVERFLOW)))))

;; Division Function with error handling
;; @param a (int) - Numerator
;; @param b (int) - Denominator
;; @returns (response int string) - Returns result or error message
(define-read-only (divide (a int) (b int))
  (if (is-eq b 0)
      (err ERR-DIVIDE-BY-ZERO)
      (ok (/ a b))))

;; Safe division that returns a specified value on division by zero
;; @param a (int) - Numerator
;; @param b (int) - Denominator
;; @param default (int) - Default value to return if b is zero
;; @returns (int) - Result of division or default value
(define-read-only (safe-divide (a int) (b int) (default int))
  (if (is-eq b 0)
      default
      (/ a b)))

;; ========== Integer Math Functions ==========

;; Square Function (a^2) with overflow protection
;; @param a (int) - Input value
;; @returns (response int string) - Returns squared value or error message
(define-read-only (square (a int))
  (multiply a a))

;; Cube Function (a^3) with overflow protection
;; @param a (int) - Input value
;; @returns (response int string) - Returns cubed value or error message
(define-read-only (cube (a int))
  (match (multiply a a)
    success (multiply success a)
    error error))

;; Power Function for integers with overflow protection
;; Only works with non-negative exponents
;; @param base (int) - Base value
;; @param exponent (uint) - Exponent (must be non-negative)
;; @returns (response int string) - Returns result or error message
(define-read-only (power (base int) (exponent uint))
  (if (is-eq exponent u0)
      (ok 1)  ;; anything^0 = 1
      (if (is-eq base 0)
          (ok 0)  ;; 0^n = 0 for n > 0
          (if (is-eq exponent u1)
              (ok base)  ;; n^1 = n
              (let ((half-exp (/ exponent u2))
                    (odd (is-eq (mod exponent u2) u1)))
                (match (power base half-exp)
                  half-result (match (multiply half-result half-result)
                                squared (if odd
                                           (multiply squared base)
                                           (ok squared))
                                error error)
                  error error))))))

;; Integer square root approximation 
;; Returns the largest integer r such that r*r <= n
;; @param n (uint) - Input value
;; @returns (response uint string) - Returns integer square root or error message
(define-read-only (isqrt (n uint))
  (if (is-eq n u0)
      (ok u0)
      (let ((x u1)
            (y (+ (/ n u2) u1)))
        (ok (isqrt-iter x y n)))))

;; Helper function for isqrt using Newton's method
(define-private (isqrt-iter (x uint) (y uint) (n uint))
  (if (< x y)
      (isqrt-iter y (+ (/ n y) y u1 u2) n)
      x))

;; Modular Function (renamed to avoid conflict with built-in 'mod' function)
;; @param a (int) - Dividend
;; @param b (int) - Divisor
;; @returns (response int string) - Returns remainder or error message
(define-read-only (modular (a int) (b int))
  (if (is-eq b 0)
      (err ERR-DIVIDE-BY-ZERO)
      (ok (mod a b))))

;; Absolute Value Function
;; @param a (int) - Input value
;; @returns (response int string) - Returns absolute value or error message
(define-read-only (absolute (a int))
  (if (< a 0)
      (let ((result (- 0 a)))
        (if (< result 0)  ;; Check for MIN_INT case
            (err ERR-OVERFLOW)
            (ok result)))
      (ok a)))

;; Sign Function
;; Returns -1 for negative numbers, 0 for zero, and 1 for positive numbers
;; @param a (int) - Input value
;; @returns (int) - Sign of the input value
(define-read-only (sign (a int))
  (if (> a 0)
      1
      (if (< a 0)
          -1
          0)))

;; ========== Statistical Functions ==========

;; Average Function with overflow protection
;; @param a (int) - First value
;; @param b (int) - Second value
;; @returns (response int string) - Returns average value or error message
(define-read-only (average (a int) (b int))
  (match (add a b)
    sum-result (divide sum-result 2)
    error error))

;; Calculate weighted average of two values
;; @param a (int) - First value
;; @param weight-a (uint) - Weight for first value
;; @param b (int) - Second value
;; @param weight-b (uint) - Weight for second value
;; @returns (response int string) - Returns weighted average or error message
(define-read-only (weighted-average (a int) (weight-a uint) (b int) (weight-b uint))
  (if (and (is-eq weight-a u0) (is-eq weight-b u0))
      (err ERR-DIVIDE-BY-ZERO)
      (let ((total-weight (+ weight-a weight-b)))
        (match (multiply a (to-int weight-a))
          weighted-a (match (multiply b (to-int weight-b))
                       weighted-b (match (add weighted-a weighted-b)
                                    sum (divide sum (to-int total-weight))
                                    error error)
                       error error)
          error error))))

;; ========== Comparison Functions ==========

;; Maximum Function
;; @param a (int) - First value
;; @param b (int) - Second value
;; @returns (int) - Larger of the two values
(define-read-only (maximum (a int) (b int))
  (if (>= a b) a b))

;; Minimum Function
;; @param a (int) - First value
;; @param b (int) - Second value
;; @returns (int) - Smaller of the two values
(define-read-only (minimum (a int) (b int))
  (if (<= a b) a b))

;; Clamp Function
;; Restricts a value to a specified range
;; @param value (int) - Value to clamp
;; @param min-val (int) - Minimum bound
;; @param max-val (int) - Maximum bound
;; @returns (int) - Clamped value
(define-read-only (clamp (value int) (min-val int) (max-val int))
  (if (< value min-val)
      min-val
      (if (> value max-val)
          max-val
          value)))

;; ========== Number Property Functions ==========

;; Is Even Function
;; @param a (int) - Input value
;; @returns (bool) - True if the value is even, false otherwise
(define-read-only (is-even (a int))
  (is-eq (mod a 2) 0))

;; Is Odd Function
;; @param a (int) - Input value
;; @returns (bool) - True if the value is odd, false otherwise
(define-read-only (is-odd (a int))
  (is-eq (mod a 2) 1))

;; Is Positive Function
;; @param a (int) - Input value
;; @returns (bool) - True if the value is positive, false otherwise
(define-read-only (is-positive (a int))
  (> a 0))

;; Is Negative Function
;; @param a (int) - Input value
;; @returns (bool) - True if the value is negative, false otherwise
(define-read-only (is-negative (a int))
  (< a 0))

;; Is Divisible By Function
;; @param a (int) - Dividend
;; @param b (int) - Divisor
;; @returns (response bool string) - Returns divisibility check or error message
(define-read-only (is-divisible-by (a int) (b int))
  (if (is-eq b 0)
      (err ERR-DIVIDE-BY-ZERO)
      (ok (is-eq (mod a b) 0))))

;; ========== Utility Conversion Functions ==========

;; Convert int to uint if possible
;; @param a (int) - Input integer
;; @returns (response uint string) - Returns uint or error message
(define-read-only (to-uint (a int))
  (if (< a 0)
      (err ERR-DOMAIN-ERROR)
      (ok (to-uint a))))

;; Convert uint to int safely
;; @param a (uint) - Input unsigned integer
;; @returns (response int string) - Returns int or error message
(define-read-only (uint-to-int (a uint))
  (let ((result (to-int a)))
    (if (< result 0)  ;; Check for overflow
        (err ERR-OVERFLOW)
        (ok result))))

;; ========== Bitwise Operations ==========

;; Bitwise AND operation
;; @param a (uint) - First operand
;; @param b (uint) - Second operand
;; @returns (uint) - Result of bitwise AND
(define-read-only (bit-and (a uint) (b uint))
  (bit-and a b))

;; Bitwise OR operation
;; @param a (uint) - First operand
;; @param b (uint) - Second operand
;; @returns (uint) - Result of bitwise OR
(define-read-only (bit-or (a uint) (b uint))
  (bit-or a b))

;; Bitwise XOR operation
;; @param a (uint) - First operand
;; @param b (uint) - Second operand
;; @returns (uint) - Result of bitwise XOR
(define-read-only (bit-xor (a uint) (b uint))
  (bit-xor a b))

;; Left shift operation
;; @param a (uint) - Value to shift
;; @param b (uint) - Shift amount
;; @returns (uint) - Result of left shift
(define-read-only (left-shift (a uint) (b uint))
  (if (> b u128)
      u0  ;; Shift by more than the bit width results in 0
      (bit-shift-left a b)))

;; Right shift operation
;; @param a (uint) - Value to shift
;; @param b (uint) - Shift amount
;; @returns (uint) - Result of right shift
(define-read-only (right-shift (a uint) (b uint))
  (if (> b u128)
      u0  ;; Shift by more than the bit width results in 0
      (bit-shift-right a b)))