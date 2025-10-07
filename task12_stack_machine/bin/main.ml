(* Main executable for Task 12: Stack Machine Compiler *)

open Stack_compiler

let () =
  print_endline "Task 12: Stack Machine and Compilation";
  print_endline "======================================";
  print_endline "";
  
  (* Example 1: Simple constant *)
  print_endline "=== Example 1: Constant ===";
  let e1 = Int 42 in
  print_endline ("Expression: " ^ expr_to_string e1);
  let code1 = compile e1 in
  print_endline "Compiled code:";
  print_endline (instrs_to_string code1);
  let result1 = execute code1 [] in
  Printf.printf "Result: %d\n" result1;
  print_endline "";
  
  (* Example 2: Simple addition *)
  print_endline "=== Example 2: Addition ===";
  let e2 = Add (Int 2, Int 3) in
  print_endline ("Expression: " ^ expr_to_string e2);
  let code2 = compile e2 in
  print_endline "Compiled code:";
  print_endline (instrs_to_string code2);
  let result2 = execute code2 [] in
  Printf.printf "Result: %d\n" result2;
  print_endline "";
  
  (* Example 3: Nested operations *)
  print_endline "=== Example 3: Nested Operations ===";
  let e3 = Mul (Add (Int 2, Int 3), Int 4) in
  print_endline ("Expression: " ^ expr_to_string e3);
  let code3 = compile e3 in
  print_endline "Compiled code:";
  print_endline (instrs_to_string code3);
  let result3 = execute code3 [] in
  Printf.printf "Result: %d\n" result3;
  print_endline "";
  
  (* Example 4: Simple let *)
  print_endline "=== Example 4: Simple Let ===";
  let e4 = Let ("x", Int 5, Add (Var "x", Int 3)) in
  print_endline ("Expression: " ^ expr_to_string e4);
  let code4 = compile e4 in
  print_endline "Compiled code:";
  print_endline (instrs_to_string code4);
  let result4 = execute code4 [] in
  Printf.printf "Result: %d\n" result4;
  print_endline "";
  
  (* Example 5: Debug execution *)
  print_endline "=== Example 5: Debug Execution ===";
  let e5 = Let ("x", Add (Int 2, Int 3), Mul (Var "x", Int 2)) in
  print_endline ("Expression: " ^ expr_to_string e5);
  let code5 = compile e5 in
  print_endline "Compiled code:";
  print_endline (instrs_to_string code5);
  print_endline "\nStep-by-step execution:";
  let _result5 = execute_debug code5 [] in
  print_endline "";
  
  print_endline "Run 'dune test' to verify your implementation!"
