(** Recursive Functions Library - Implementation *)

(* Task 2: Functions and Recursion
 *
 * Implement three recursive functions:
 * 1. fact - normal recursive factorial
 * 2. fact_tail - tail-recursive factorial with accumulator
 * 3. fib - tail-recursive Fibonacci
 *
 * Remember:
 * - Use 'let rec' for recursive functions
 * - For tail recursion, the recursive call must be the LAST operation
 * - Use accumulators to carry "result so far"
 * - For Fibonacci, you need TWO accumulators (previous two values)
 *)

(** Normal recursion factorial - NOT tail-recursive *)
let fact _n =
  failwith "TODO: Implement fact using 'let rec'"
  (* Hints:
   * - Use 'let rec fact n = ...' (add the 'rec' keyword)
   * - Base case: if n <= 1 then return 1
   * - Recursive case: n * fact (n - 1)
   * - This is NOT tail-recursive (multiplication after recursive call)
   *)

(** Tail-recursive factorial using an accumulator *)
let fact_tail _n =
  failwith "TODO: Implement fact_tail"
  (* Hints:
   * - Define a helper function: let rec loop i acc = ...
   * - Base case: if i <= 1 then return acc
   * - Recursive case: loop (i - 1) (acc * i)
   * - Initial call: loop n 1
   * - This IS tail-recursive (no pending operations after recursive call)
   *)

(** Tail-recursive Fibonacci using two accumulators *)
let fib _n =
  failwith "TODO: Implement fib"
  (* Hints:
   * - Define a helper function: let rec loop i a b = ...
   * - a represents F(i-2), b represents F(i-1)
   * - Base cases: 
   *     if i = 0 then return a
   *     if i = 1 then return b
   * - Recursive case: loop (i - 1) b (a + b)
   * - Initial call: loop n 0 1
   * - Each iteration: (a, b) becomes (b, a+b)
   *)

