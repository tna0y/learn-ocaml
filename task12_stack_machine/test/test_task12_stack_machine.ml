(* Tests for Task 12: Stack Machine and Compilation *)

open Stack_compiler

(* Helper to check compilation correctness *)
let check_compile msg e =
  let code = compile e in
  let vm_result = execute code [] in
  let eval_result = eval [] e in
  Alcotest.(check int) msg eval_result vm_result

(* Helper to check compilation with environment *)
let check_compile_env msg e env =
  let code = compile e in
  let vm_result = execute code env in
  let eval_result = eval env e in
  Alcotest.(check int) msg eval_result vm_result

(* Test compiling constants *)
let test_compile_int () =
  let e = Int 42 in
  let code = compile e in
  (* Should be just PUSH 42 *)
  Alcotest.(check int) "length" 1 (List.length code);
  match code with
  | [PUSH 42] -> ()
  | _ -> Alcotest.fail "Expected [PUSH 42]"

(* Test executing constant *)
let test_execute_constant () =
  let result = execute [PUSH 42] [] in
  Alcotest.(check int) "execute PUSH 42" 42 result

(* Test executing addition *)
let test_execute_add () =
  let result = execute [PUSH 2; PUSH 3; ADD] [] in
  Alcotest.(check int) "2 + 3" 5 result

(* Test executing subtraction *)
let test_execute_sub () =
  let result = execute [PUSH 10; PUSH 3; SUB] [] in
  Alcotest.(check int) "10 - 3" 7 result

(* Test executing multiplication *)
let test_execute_mul () =
  let result = execute [PUSH 3; PUSH 4; MUL] [] in
  Alcotest.(check int) "3 * 4" 12 result

(* Test executing division *)
let test_execute_div () =
  let result = execute [PUSH 12; PUSH 3; DIV] [] in
  Alcotest.(check int) "12 / 3" 4 result

(* Test executing nested operations *)
let test_execute_nested () =
  (* (2 + 3) * 4 *)
  let result = execute [PUSH 2; PUSH 3; ADD; PUSH 4; MUL] [] in
  Alcotest.(check int) "(2 + 3) * 4" 20 result

(* Test LOAD/STORE *)
let test_execute_load_store () =
  let result = execute [PUSH 5; STORE "x"; LOAD "x"] [] in
  Alcotest.(check int) "store then load" 5 result

(* Test compiling simple addition *)
let test_compile_add () =
  check_compile "compile 2 + 3" (Add (Int 2, Int 3))

(* Test compiling simple subtraction *)
let test_compile_sub () =
  check_compile "compile 10 - 3" (Sub (Int 10, Int 3))

(* Test compiling simple multiplication *)
let test_compile_mul () =
  check_compile "compile 3 * 4" (Mul (Int 3, Int 4))

(* Test compiling simple division *)
let test_compile_div () =
  check_compile "compile 12 / 3" (Div (Int 12, Int 3))

(* Test compiling nested operations *)
let test_compile_nested () =
  (* (2 + 3) * 4 *)
  check_compile "compile (2 + 3) * 4" 
    (Mul (Add (Int 2, Int 3), Int 4))

(* Test compiling deeply nested *)
let test_compile_deep () =
  (* ((1 + 2) * 3) - 4 *)
  check_compile "compile ((1 + 2) * 3) - 4"
    (Sub (Mul (Add (Int 1, Int 2), Int 3), Int 4))

(* Test compiling variable *)
let test_compile_var () =
  let env = [("x", 10)] in
  check_compile_env "compile variable" (Var "x") env

(* Test compiling expression with variable *)
let test_compile_var_expr () =
  let env = [("x", 5)] in
  check_compile_env "compile x + 3" 
    (Add (Var "x", Int 3)) env

(* Test compiling simple let *)
let test_compile_let_simple () =
  (* let x = 5 in x *)
  check_compile "compile let x = 5 in x"
    (Let ("x", Int 5, Var "x"))

(* Test compiling let with arithmetic *)
let test_compile_let_arithmetic () =
  (* let x = 5 in x + 3 *)
  check_compile "compile let x = 5 in x + 3"
    (Let ("x", Int 5, Add (Var "x", Int 3)))

(* Test compiling nested let *)
let test_compile_let_nested () =
  (* let x = 1 in let y = 2 in x + y *)
  check_compile "compile nested let"
    (Let ("x", Int 1,
      Let ("y", Int 2,
        Add (Var "x", Var "y"))))

(* Test compiling let with computation *)
let test_compile_let_computation () =
  (* let x = 2 + 3 in x * 4 *)
  check_compile "compile let x = 2 + 3 in x * 4"
    (Let ("x", Add (Int 2, Int 3),
      Mul (Var "x", Int 4)))

(* Test compiling let shadowing *)
let test_compile_let_shadowing () =
  (* let x = 1 in let x = 2 in x *)
  check_compile "compile shadowing"
    (Let ("x", Int 1,
      Let ("x", Int 2,
        Var "x")))

(* Test compiling let with reference to outer *)
let test_compile_let_outer_reference () =
  (* let x = 10 in let x = x + 5 in x *)
  check_compile "compile let x = 10 in let x = x + 5 in x"
    (Let ("x", Int 10,
      Let ("x", Add (Var "x", Int 5),
        Var "x")))

(* Test that instruction order is correct for subtraction *)
let test_instruction_order_sub () =
  let e = Sub (Int 10, Int 3) in
  let code = compile e in
  let result = execute code [] in
  Alcotest.(check int) "10 - 3 (not 3 - 10)" 7 result

(* Test that instruction order is correct for division *)
let test_instruction_order_div () =
  let e = Div (Int 12, Int 3) in
  let code = compile e in
  let result = execute code [] in
  Alcotest.(check int) "12 / 3 (not 3 / 12)" 4 result

(* Test complex expression *)
let test_complex_expression () =
  (* let x = 10 in let y = x * 2 in (x + y) / 5 *)
  check_compile "complex expression"
    (Let ("x", Int 10,
      Let ("y", Mul (Var "x", Int 2),
        Div (Add (Var "x", Var "y"), Int 5))))

(* Test multiple operations *)
let test_multiple_operations () =
  (* 1 + 2 - 3 * 4 / 2 *)
  check_compile "1 + 2 - 3 * 4 / 2"
    (Sub (Add (Int 1, Int 2),
      Div (Mul (Int 3, Int 4), Int 2)))

(* Test that compiled code produces correct result *)
let test_correctness_property () =
  let test_cases = [
    Int 42;
    Add (Int 2, Int 3);
    Mul (Add (Int 2, Int 3), Int 4);
    Sub (Int 10, Int 3);
    Div (Int 12, Int 3);
    Let ("x", Int 5, Add (Var "x", Int 3));
    Let ("x", Int 1, Let ("y", Int 2, Add (Var "x", Var "y")));
    Let ("x", Add (Int 2, Int 3), Mul (Var "x", Int 2));
  ] in
  List.iter (fun e ->
    let code = compile e in
    let vm_result = execute code [] in
    let eval_result = eval [] e in
    if vm_result <> eval_result then
      Alcotest.fail (Printf.sprintf 
        "Mismatch for %s: VM=%d, eval=%d" 
        (expr_to_string e) vm_result eval_result)
  ) test_cases

(* Test instruction list structure for let *)
let test_let_instruction_structure () =
  (* let x = 5 in x should have PUSH, STORE, LOAD *)
  let e = Let ("x", Int 5, Var "x") in
  let code = compile e in
  match code with
  | [PUSH 5; STORE "x"; LOAD "x"] -> ()
  | _ -> Alcotest.fail (Printf.sprintf
      "Expected [PUSH 5; STORE \"x\"; LOAD \"x\"], got %s"
      (instrs_to_string code))

(* Test suite *)
let () =
  let open Alcotest in
  run "Task12_StackMachine" [
    "vm_execution", [
      test_case "constant" `Quick test_execute_constant;
      test_case "addition" `Quick test_execute_add;
      test_case "subtraction" `Quick test_execute_sub;
      test_case "multiplication" `Quick test_execute_mul;
      test_case "division" `Quick test_execute_div;
      test_case "nested" `Quick test_execute_nested;
      test_case "load/store" `Quick test_execute_load_store;
    ];
    "compile_basic", [
      test_case "integer" `Quick test_compile_int;
      test_case "addition" `Quick test_compile_add;
      test_case "subtraction" `Quick test_compile_sub;
      test_case "multiplication" `Quick test_compile_mul;
      test_case "division" `Quick test_compile_div;
    ];
    "compile_nested", [
      test_case "nested operations" `Quick test_compile_nested;
      test_case "deeply nested" `Quick test_compile_deep;
      test_case "multiple operations" `Quick test_multiple_operations;
    ];
    "compile_variables", [
      test_case "variable" `Quick test_compile_var;
      test_case "variable in expression" `Quick test_compile_var_expr;
    ];
    "compile_let", [
      test_case "simple let" `Quick test_compile_let_simple;
      test_case "let with arithmetic" `Quick test_compile_let_arithmetic;
      test_case "nested let" `Quick test_compile_let_nested;
      test_case "let with computation" `Quick test_compile_let_computation;
      test_case "let shadowing" `Quick test_compile_let_shadowing;
      test_case "let with outer reference" `Quick test_compile_let_outer_reference;
      test_case "instruction structure" `Quick test_let_instruction_structure;
    ];
    "correctness", [
      test_case "instruction order (sub)" `Quick test_instruction_order_sub;
      test_case "instruction order (div)" `Quick test_instruction_order_div;
      test_case "complex expression" `Quick test_complex_expression;
      test_case "property: compile ≡ eval" `Quick test_correctness_property;
    ];
  ]

