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
let rec fact _n =
  if _n <= 1 then 1 
  else _n * fact (_n - 1)

(** Tail-recursive factorial using an accumulator *)

let rec _fact_tail _n acc = 
  if _n <= 1 then acc
  else _fact_tail (_n - 1) (acc * _n)

let fact_tail _n = _fact_tail (_n) (1)

(** Tail-recursive Fibonacci using two accumulators *)
let fib _n =
  let rec loop i a1 a2 =
    if i == 0 then a1
    else loop (i - 1) a2 (a1 + a2)
  in
  loop _n 0 1
