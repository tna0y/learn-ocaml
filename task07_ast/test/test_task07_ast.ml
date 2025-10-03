(* Tests for Task 7: Arithmetic AST *)

open Expr

(* Test eval on integer literals *)
let test_eval_int () =
  Alcotest.(check int) "eval 0" 0 (eval (Int 0));
  Alcotest.(check int) "eval 42" 42 (eval (Int 42));
  Alcotest.(check int) "eval -5" (-5) (eval (Int (-5)))

(* Test eval on addition *)
let test_eval_add () =
  Alcotest.(check int) "1 + 2" 3 (eval (Add (Int 1, Int 2)));
  Alcotest.(check int) "10 + 20" 30 (eval (Add (Int 10, Int 20)));
  Alcotest.(check int) "0 + 0" 0 (eval (Add (Int 0, Int 0)))

(* Test eval on subtraction *)
let test_eval_sub () =
  Alcotest.(check int) "5 - 3" 2 (eval (Sub (Int 5, Int 3)));
  Alcotest.(check int) "10 - 20" (-10) (eval (Sub (Int 10, Int 20)));
  Alcotest.(check int) "0 - 5" (-5) (eval (Sub (Int 0, Int 5)))

(* Test eval on multiplication *)
let test_eval_mul () =
  Alcotest.(check int) "2 * 3" 6 (eval (Mul (Int 2, Int 3)));
  Alcotest.(check int) "5 * 0" 0 (eval (Mul (Int 5, Int 0)));
  Alcotest.(check int) "-2 * 3" (-6) (eval (Mul (Int (-2), Int 3)))

(* Test eval on division *)
let test_eval_div () =
  Alcotest.(check int) "6 / 2" 3 (eval (Div (Int 6, Int 2)));
  Alcotest.(check int) "7 / 3" 2 (eval (Div (Int 7, Int 3)));  (* Integer division *)
  Alcotest.(check int) "10 / 5" 2 (eval (Div (Int 10, Int 5)))

(* Test eval on complex expressions *)
let test_eval_complex () =
  (* (1 + 2) * 3 = 9 *)
  Alcotest.(check int) "(1 + 2) * 3" 9 
    (eval (Mul (Add (Int 1, Int 2), Int 3)));
  
  (* 1 + 2 * 3 = 7 *)
  Alcotest.(check int) "1 + 2 * 3" 7 
    (eval (Add (Int 1, Mul (Int 2, Int 3))));
  
  (* (10 - 4) / 2 = 3 *)
  Alcotest.(check int) "(10 - 4) / 2" 3 
    (eval (Div (Sub (Int 10, Int 4), Int 2)));
  
  (* ((5 + 3) * 2) - 6 = 10 *)
  Alcotest.(check int) "((5 + 3) * 2) - 6" 10 
    (eval (Sub (Mul (Add (Int 5, Int 3), Int 2), Int 6)))

(* Test precedence encoding in AST *)
let test_precedence () =
  (* 2 + 3 * 4 should be 2 + (3 * 4) = 14, not (2 + 3) * 4 = 20 *)
  let correct = Add (Int 2, Mul (Int 3, Int 4)) in
  Alcotest.(check int) "2 + 3 * 4" 14 (eval correct);
  
  let incorrect = Mul (Add (Int 2, Int 3), Int 4) in
  Alcotest.(check int) "(2 + 3) * 4" 20 (eval incorrect)

(* Test expr_to_string on integer *)
let test_to_string_int () =
  Alcotest.(check string) "42" "42" (expr_to_string (Int 42));
  Alcotest.(check string) "0" "0" (expr_to_string (Int 0));
  Alcotest.(check string) "-5" "-5" (expr_to_string (Int (-5)))

(* Test expr_to_string on operations *)
let test_to_string_ops () =
  Alcotest.(check string) "1 + 2" "(1 + 2)" 
    (expr_to_string (Add (Int 1, Int 2)));
  
  Alcotest.(check string) "5 - 3" "(5 - 3)" 
    (expr_to_string (Sub (Int 5, Int 3)));
  
  Alcotest.(check string) "2 * 3" "(2 * 3)" 
    (expr_to_string (Mul (Int 2, Int 3)));
  
  Alcotest.(check string) "6 / 2" "(6 / 2)" 
    (expr_to_string (Div (Int 6, Int 2)))

(* Test expr_to_string on complex expressions *)
let test_to_string_complex () =
  (* (1 + 2) * 3 *)
  Alcotest.(check string) "(1 + 2) * 3" "((1 + 2) * 3)" 
    (expr_to_string (Mul (Add (Int 1, Int 2), Int 3)));
  
  (* 1 + (2 * 3) *)
  Alcotest.(check string) "1 + (2 * 3)" "(1 + (2 * 3))" 
    (expr_to_string (Add (Int 1, Mul (Int 2, Int 3))));
  
  (* ((10 + 5) / (5 - 2)) *)
  Alcotest.(check string) "complex division" "((10 + 5) / (5 - 2))" 
    (expr_to_string (Div (Add (Int 10, Int 5), Sub (Int 5, Int 2))))

(* Test that eval and to_string work together *)
let test_eval_and_print () =
  let e = Mul (Add (Int 2, Int 3), Sub (Int 10, Int 4)) in
  Alcotest.(check int) "eval result" 30 (eval e);
  Alcotest.(check string) "printed form" "((2 + 3) * (10 - 4))" (expr_to_string e)

(* Test suite *)
let () =
  let open Alcotest in
  run "Task07_AST" [
    "eval_basic", [
      test_case "integer literals" `Quick test_eval_int;
      test_case "addition" `Quick test_eval_add;
      test_case "subtraction" `Quick test_eval_sub;
      test_case "multiplication" `Quick test_eval_mul;
      test_case "division" `Quick test_eval_div;
    ];
    "eval_complex", [
      test_case "complex expressions" `Quick test_eval_complex;
      test_case "precedence in AST" `Quick test_precedence;
    ];
    "pretty_print", [
      test_case "integers" `Quick test_to_string_int;
      test_case "operations" `Quick test_to_string_ops;
      test_case "complex expressions" `Quick test_to_string_complex;
    ];
    "integration", [
      test_case "eval and print together" `Quick test_eval_and_print;
    ];
  ]

