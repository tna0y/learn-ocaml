(* REFERENCE SOLUTION - Do not peek until you've tried implementing it yourself! *)

(** Normal recursion factorial - NOT tail-recursive *)
let rec fact n =
  if n <= 1 then 1
  else n * fact (n - 1)

(** Tail-recursive factorial using an accumulator *)
let fact_tail n =
  let rec loop i acc =
    if i <= 1 then acc
    else loop (i - 1) (acc * i)
  in
  loop n 1

(** Tail-recursive Fibonacci using two accumulators *)
let fib n =
  let rec loop i a b =
    if i = 0 then a
    else if i = 1 then b
    else loop (i - 1) b (a + b)
  in
  loop n 0 1

