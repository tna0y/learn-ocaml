(* Main executable for Task 10: Constant Folding *)

open Const_fold

let () =
  print_endline "Task 10: Constant Folding and Algebraic Simplifications";
  print_endline "========================================================";
  print_endline "";
  
  (* Example 1: Simple constant folding *)
  let e1 = Add (Int 2, Int 3) in
  print_endline ("Original:  " ^ expr_to_string e1);
  let e1' = const_fold e1 in
  print_endline ("Folded:    " ^ expr_to_string e1');
  print_endline "";
  
  (* Example 2: Nested constant folding *)
  let e2 = Mul (Add (Int 2, Int 3), Int 4) in
  print_endline ("Original:  " ^ expr_to_string e2);
  let e2' = const_fold e2 in
  print_endline ("Folded:    " ^ expr_to_string e2');
  print_endline "";
  
  (* Example 3: Algebraic simplification *)
  let e3 = Add (Var "x", Int 0) in
  print_endline ("Original:  " ^ expr_to_string e3);
  let e3' = const_fold e3 in
  print_endline ("Simplified: " ^ expr_to_string e3');
  print_endline "";
  
  (* Example 4: Composition *)
  let e4 = Add (Mul (Int 2, Int 3), Int 0) in
  print_endline ("Original:  " ^ expr_to_string e4);
  let e4' = const_fold e4 in
  print_endline ("Optimized: " ^ expr_to_string e4');
  print_endline "";
  
  (* Example 5: With let *)
  let e5 = Let ("x", Add (Int 2, Int 3), Mul (Var "x", Int 1)) in
  print_endline ("Original:  " ^ expr_to_string e5);
  let e5' = const_fold e5 in
  print_endline ("Optimized: " ^ expr_to_string e5');
  print_endline "";
  
  print_endline "Run 'dune test' to verify your implementation!"
