(** Recursive Functions Library *)

(** {1 Factorial Functions} *)

(** [fact n] computes the factorial of [n] using normal recursion.
    
    @param n a non-negative integer
    @return n! = n * (n-1) * ... * 2 * 1
    
    Examples:
    - [fact 0 = 1]
    - [fact 5 = 120]
    - [fact 10 = 3628800]
    
    Note: This implementation is NOT tail-recursive and may cause
    stack overflow for large values of n. *)
val fact : int -> int

(** [fact_tail n] computes the factorial of [n] using tail recursion.
    
    @param n a non-negative integer
    @return n! = n * (n-1) * ... * 2 * 1
    
    This implementation uses an accumulator to achieve tail recursion,
    making it safe for large values of n. It should produce the same
    results as [fact] but with O(1) stack space instead of O(n).
    
    Examples:
    - [fact_tail 0 = 1]
    - [fact_tail 5 = 120]
    - [fact_tail 1000] should not overflow the stack *)
val fact_tail : int -> int

(** {1 Fibonacci Function} *)

(** [fib n] computes the nth Fibonacci number using tail recursion.
    
    @param n a non-negative integer
    @return the nth Fibonacci number
    
    The Fibonacci sequence is defined as:
    - F(0) = 0
    - F(1) = 1
    - F(n) = F(n-1) + F(n-2) for n >= 2
    
    Sequence: 0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, ...
    
    Examples:
    - [fib 0 = 0]
    - [fib 1 = 1]
    - [fib 6 = 8]
    - [fib 10 = 55]
    
    This implementation must be tail-recursive and run in O(n) time
    with O(1) stack space. *)
val fib : int -> int

