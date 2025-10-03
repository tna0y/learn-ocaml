(* Tests for Task 2: Functions and Recursion *)

open Recursion

(* Test factorial - normal recursion *)
let test_fact_base_cases () =
  Alcotest.(check int) "fact 0" 1 (fact 0);
  Alcotest.(check int) "fact 1" 1 (fact 1)

let test_fact_small_values () =
  Alcotest.(check int) "fact 2" 2 (fact 2);
  Alcotest.(check int) "fact 3" 6 (fact 3);
  Alcotest.(check int) "fact 4" 24 (fact 4);
  Alcotest.(check int) "fact 5" 120 (fact 5)

let test_fact_larger_values () =
  Alcotest.(check int) "fact 6" 720 (fact 6);
  Alcotest.(check int) "fact 7" 5040 (fact 7);
  Alcotest.(check int) "fact 10" 3628800 (fact 10)

(* Test factorial - tail recursive *)
let test_fact_tail_base_cases () =
  Alcotest.(check int) "fact_tail 0" 1 (fact_tail 0);
  Alcotest.(check int) "fact_tail 1" 1 (fact_tail 1)

let test_fact_tail_small_values () =
  Alcotest.(check int) "fact_tail 2" 2 (fact_tail 2);
  Alcotest.(check int) "fact_tail 3" 6 (fact_tail 3);
  Alcotest.(check int) "fact_tail 4" 24 (fact_tail 4);
  Alcotest.(check int) "fact_tail 5" 120 (fact_tail 5)

let test_fact_tail_larger_values () =
  Alcotest.(check int) "fact_tail 6" 720 (fact_tail 6);
  Alcotest.(check int) "fact_tail 7" 5040 (fact_tail 7);
  Alcotest.(check int) "fact_tail 10" 3628800 (fact_tail 10)

(* Test that tail version can handle larger inputs *)
let test_fact_tail_large_input () =
  (* This should not overflow the stack *)
  let _ = fact_tail 10000 in
  Alcotest.(check pass) "fact_tail handles large input" () ()

(* Test that both factorial implementations agree *)
let test_fact_equivalence () =
  for i = 0 to 15 do
    let expected = fact i in
    let actual = fact_tail i in
    Alcotest.(check int) 
      (Printf.sprintf "fact and fact_tail agree on %d" i)
      expected actual
  done

(* Test Fibonacci - base cases *)
let test_fib_base_cases () =
  Alcotest.(check int) "fib 0" 0 (fib 0);
  Alcotest.(check int) "fib 1" 1 (fib 1)

(* Test Fibonacci - small values *)
let test_fib_small_values () =
  Alcotest.(check int) "fib 2" 1 (fib 2);
  Alcotest.(check int) "fib 3" 2 (fib 3);
  Alcotest.(check int) "fib 4" 3 (fib 4);
  Alcotest.(check int) "fib 5" 5 (fib 5);
  Alcotest.(check int) "fib 6" 8 (fib 6);
  Alcotest.(check int) "fib 7" 13 (fib 7)

(* Test Fibonacci - larger values *)
let test_fib_larger_values () =
  Alcotest.(check int) "fib 8" 21 (fib 8);
  Alcotest.(check int) "fib 9" 34 (fib 9);
  Alcotest.(check int) "fib 10" 55 (fib 10);
  Alcotest.(check int) "fib 15" 610 (fib 15);
  Alcotest.(check int) "fib 20" 6765 (fib 20)

(* Test Fibonacci sequence properties *)
let test_fib_sequence_property () =
  (* Property: fib(n) = fib(n-1) + fib(n-2) for n >= 2 *)
  for n = 2 to 20 do
    let fib_n = fib n in
    let fib_n1 = fib (n - 1) in
    let fib_n2 = fib (n - 2) in
    Alcotest.(check int)
      (Printf.sprintf "fib %d = fib %d + fib %d" n (n-1) (n-2))
      fib_n (fib_n1 + fib_n2)
  done

(* Test that fib can handle larger inputs efficiently *)
let test_fib_efficiency () =
  (* This should complete quickly if tail-recursive *)
  let start_time = Sys.time () in
  let _ = fib 1000 in
  let end_time = Sys.time () in
  let elapsed = end_time -. start_time in
  (* Should be very fast (under 1 second) *)
  Alcotest.(check bool) "fib 1000 completes quickly" true (elapsed < 1.0)

(* Test suite *)
let () =
  let open Alcotest in
  run "Task02_Recursion" [
    "factorial_normal", [
      test_case "base cases" `Quick test_fact_base_cases;
      test_case "small values" `Quick test_fact_small_values;
      test_case "larger values" `Quick test_fact_larger_values;
    ];
    "factorial_tail", [
      test_case "base cases" `Quick test_fact_tail_base_cases;
      test_case "small values" `Quick test_fact_tail_small_values;
      test_case "larger values" `Quick test_fact_tail_larger_values;
      test_case "large input" `Quick test_fact_tail_large_input;
      test_case "equivalence with normal fact" `Quick test_fact_equivalence;
    ];
    "fibonacci", [
      test_case "base cases" `Quick test_fib_base_cases;
      test_case "small values" `Quick test_fib_small_values;
      test_case "larger values" `Quick test_fib_larger_values;
      test_case "sequence property" `Quick test_fib_sequence_property;
      test_case "efficiency" `Quick test_fib_efficiency;
    ];
  ]

