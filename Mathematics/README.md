# Enhanced Math Library in Clarity

## Overview

This smart contract implements an enhanced math library in Clarity, providing a set of mathematical functions with built-in error handling and overflow/underflow protection. The library is designed to be used in other Clarity smart contracts that require safe and reliable mathematical operations.

## Functions

### 1. add(a int, b int) → (response int uint)
Adds two integers with overflow protection.
- Returns `(ok result)` if the addition is successful.
- Returns `(err u"Overflow occurred in addition")` if an overflow occurs.

### 2. subtract(a int, b int) → (response int uint)
Subtracts two integers with underflow protection.
- Returns `(ok result)` if the subtraction is successful.
- Returns `(err u"Underflow occurred in subtraction")` if an underflow occurs.

### 3. multiply(a int, b int) → (response int uint)
Multiplies two integers with overflow protection.
- Returns `(ok result)` if the multiplication is successful.
- Returns `(err u"Overflow occurred in multiplication")` if an overflow occurs.

### 4. divide(a int, b int) → (response int uint)
Divides two integers with error handling for division by zero.
- Returns `(ok result)` if the division is successful.
- Returns `(err u"Cannot divide by zero")` if attempting to divide by zero.

### 5. square(a int) → (response int uint)
Calculates the square of an integer using the `multiply` function.
- Returns `(ok result)` if the calculation is successful.
- Returns an error if an overflow occurs during multiplication.

### 6. modular(a int, b int) → (response int uint)
Calculates the modulus of two integers with error handling for modulo by zero.
- Returns `(ok result)` if the modulo operation is successful.
- Returns `(err u"Cannot perform modulo by zero")` if attempting to perform modulo by zero.

### 7. absolute(a int) → (response int uint)
Calculates the absolute value of an integer.
- Always returns `(ok result)` with the absolute value.

### 8. average(a int, b int) → (response int uint)
Calculates the average of two integers with overflow protection.
- Returns `(ok result)` if the average calculation is successful.
- Returns `(err u"Overflow occurred while calculating average")` if an overflow occurs during the calculation.

### 9. maximum(a int, b int) → (response int uint)
Returns the maximum of two integers.
- Always returns `(ok result)` with the larger of the two input values.

### 10. is-even(a int) → (response bool uint)
Checks if an integer is even.
- Returns `(ok true)` if the input is even.
- Returns `(ok false)` if the input is odd.

## Usage

To use this library in your Clarity smart contract, you can either:

1. Copy the functions you need directly into your contract.
2. Deploy this contract separately and call its functions from your contract using inter-contract calls.

Example usage:

```clarity
(use-trait math-lib .math-library.math-trait)

(define-public (example-function (math-contract <math-lib>))
  (let
    (
      (sum (contract-call? math-contract add 5 3))
      (product (contract-call? math-contract multiply 4 7))
    )
    (match sum
      success (match product
        success (ok {sum: success, product: success})
        error (err error))
      error (err error))))
```

## Error Handling

All functions in this library return a `response` type, which allows for proper error handling in the calling contract. Always use `match` expressions to handle both successful and error cases when calling these functions.

## Limitations

- This library operates on Clarity's `int` type, which has a fixed size. Be aware of the maximum and minimum values that can be represented.
- The overflow and underflow checks may not catch all possible cases, especially for extreme values close to the limits of the `int` type.

## Security Considerations

While this library provides basic overflow and underflow protection, it's crucial to thoroughly test your contract with a wide range of inputs, including edge cases, before deploying it to a live network.