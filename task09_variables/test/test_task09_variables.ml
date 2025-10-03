(* Tests for Task 9: Variables and Environments *)

open Env_eval

(* Test lookup *)
let test_lookup_simple () =
  Alcotest.(check int) "lookup x in [(x,5)]" 5 (lookup "x" [("x", 5)]);
  Alcotest.(check int) "lookup y" 3 (lookup "y" [("x", 5); ("y", 3)])

let test_lookup_shadowing () =
  (* First match should win *)
  Alcotest.(check int) "shadowed variable" 2 
    (lookup "x" [("x", 2); ("x", 1)])

let test_lookup_unbound () =
  Alcotest.check_raises "unbound variable"
    (Failure "Unbound variable: z")
    (fun () -> ignore (lookup "z" [("x", 5)]))

(* Test eval with integers and arithmetic *)
let test_eval_int () =
  Alcotest.(check int) "eval int" 42 (eval [] (Int 42))

let test_eval_arithmetic () =
  Alcotest.(check int) "1 + 2" 3 (eval [] (Add (Int 1, Int 2)));
  Alcotest.(check int) "5 - 3" 2 (eval [] (Sub (Int 5, Int 3)));
  Alcotest.(check int) "2 * 3" 6 (eval [] (Mul (Int 2, Int 3)));
  Alcotest.(check int) "6 / 2" 3 (eval [] (Div (Int 6, Int 2)))

(* Test eval with variables *)
let test_eval_var () =
  Alcotest.(check int) "var x" 5 (eval [("x", 5)] (Var "x"));
  Alcotest.(check int) "var in expression" 8 
    (eval [("x", 5)] (Add (Var "x", Int 3)))

(* Test eval with let bindings *)
let test_eval_let_simple () =
  (* let x = 5 in x *)
  let e = Let ("x", Int 5, Var "x") in
  Alcotest.(check int) "let x = 5 in x" 5 (eval [] e)

let test_eval_let_arithmetic () =
  (* let x = 5 in x + 3 *)
  let e = Let ("x", Int 5, Add (Var "x", Int 3)) in
  Alcotest.(check int) "let x = 5 in x + 3" 8 (eval [] e)

let test_eval_let_nested () =
  (* let x = 1 in let y = 2 in x + y *)
  let e = Let ("x", Int 1,
            Let ("y", Int 2,
              Add (Var "x", Var "y"))) in
  Alcotest.(check int) "nested let" 3 (eval [] e)

let test_eval_let_shadowing () =
  (* let x = 1 in let x = 2 in x *)
  let e = Let ("x", Int 1,
            Let ("x", Int 2,
              Var "x")) in
  Alcotest.(check int) "shadowing" 2 (eval [] e)

let test_eval_let_complex () =
  (* let x = 10 in let y = x + 5 in y * 2 *)
  let e = Let ("x", Int 10,
            Let ("y", Add (Var "x", Int 5),
              Mul (Var "x", Int 2))) in
  Alcotest.(check int) "complex let" 30 (eval [] e)

let test_eval_let_scope () =
  (* Test that x is not visible after let *)
  (* let x = 5 in x + 3 evaluates to 8, then x is not in scope *)
  let e1 = Let ("x", Int 5, Add (Var "x", Int 3)) in
  Alcotest.(check int) "inside scope" 8 (eval [] e1);
  
  (* This should fail - x not in empty environment *)
  Alcotest.check_raises "outside scope"
    (Failure "Unbound variable: x")
    (fun () -> ignore (eval [] (Var "x")))

(* Test expr_to_string *)
let test_to_string_var () =
  Alcotest.(check string) "variable" "x" (expr_to_string (Var "x"))

let test_to_string_let () =
  let e = Let ("x", Int 5, Var "x") in
  Alcotest.(check string) "simple let" "let x = 5 in x" (expr_to_string e)

let test_to_string_complex () =
  let e = Let ("x", Int 5, Add (Var "x", Int 3)) in
  Alcotest.(check string) "let with expression" 
    "let x = 5 in (x + 3)" (expr_to_string e)

(* Integration tests *)
let test_integration () =
  (* Parse, eval, and print a complex expression *)
  let e = Let ("x", Int 10,
            Let ("y", Add (Var "x", Int 5),
              Sub (Var "y", Var "x"))) in
  Alcotest.(check int) "eval" 5 (eval [] e);
  (* Just check it doesn't crash *)
  let _ = expr_to_string e in
  ()

(* Test suite *)
let () =
  let open Alcotest in
  run "Task09_Variables" [
    "lookup", [
      test_case "simple lookup" `Quick test_lookup_simple;
      test_case "shadowing" `Quick test_lookup_shadowing;
      test_case "unbound variable" `Quick test_lookup_unbound;
    ];
    "eval_basic", [
      test_case "integers" `Quick test_eval_int;
      test_case "arithmetic" `Quick test_eval_arithmetic;
      test_case "variables" `Quick test_eval_var;
    ];
    "eval_let", [
      test_case "simple let" `Quick test_eval_let_simple;
      test_case "let with arithmetic" `Quick test_eval_let_arithmetic;
      test_case "nested let" `Quick test_eval_let_nested;
      test_case "shadowing" `Quick test_eval_let_shadowing;
      test_case "complex let" `Quick test_eval_let_complex;
      test_case "scope" `Quick test_eval_let_scope;
    ];
    "to_string", [
      test_case "variable" `Quick test_to_string_var;
      test_case "let binding" `Quick test_to_string_let;
      test_case "complex" `Quick test_to_string_complex;
    ];
    "integration", [
      test_case "full workflow" `Quick test_integration;
    ];
  ]

