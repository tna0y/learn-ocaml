(* Tests for Task 10: Constant Folding and Algebraic Simplifications *)

open Const_fold

(* Helper to check semantic equivalence *)
let check_equiv msg e e' =
  let v1 = eval [] e in
  let v2 = eval [] e' in
  Alcotest.(check int) msg v1 v2

(* Test constant folding for integers *)
let test_fold_int () =
  let e = Int 42 in
  let e' = const_fold e in
  Alcotest.(check int) "int unchanged" 42 (eval [] e')

(* Test constant folding - addition *)
let test_fold_add_constants () =
  let e = Add (Int 2, Int 3) in
  let e' = const_fold e in
  Alcotest.(check int) "2 + 3 = 5" 5 (eval [] e');
  (* Should actually be Int 5 *)
  match e' with
  | Int 5 -> ()
  | _ -> Alcotest.fail "Expected Int 5"

(* Test constant folding - subtraction *)
let test_fold_sub_constants () =
  let e = Sub (Int 10, Int 3) in
  let e' = const_fold e in
  Alcotest.(check int) "10 - 3 = 7" 7 (eval [] e');
  match e' with
  | Int 7 -> ()
  | _ -> Alcotest.fail "Expected Int 7"

(* Test constant folding - multiplication *)
let test_fold_mul_constants () =
  let e = Mul (Int 3, Int 4) in
  let e' = const_fold e in
  Alcotest.(check int) "3 * 4 = 12" 12 (eval [] e');
  match e' with
  | Int 12 -> ()
  | _ -> Alcotest.fail "Expected Int 12"

(* Test constant folding - division *)
let test_fold_div_constants () =
  let e = Div (Int 12, Int 3) in
  let e' = const_fold e in
  Alcotest.(check int) "12 / 3 = 4" 4 (eval [] e');
  match e' with
  | Int 4 -> ()
  | _ -> Alcotest.fail "Expected Int 4"

(* Test constant folding - nested *)
let test_fold_nested () =
  (* (2 + 3) * 4 *)
  let e = Mul (Add (Int 2, Int 3), Int 4) in
  let e' = const_fold e in
  Alcotest.(check int) "(2 + 3) * 4 = 20" 20 (eval [] e');
  match e' with
  | Int 20 -> ()
  | _ -> Alcotest.fail "Expected Int 20"

(* Test algebraic simplification - x + 0 *)
let test_simplify_add_zero_right () =
  let e = Add (Var "x", Int 0) in
  let e' = const_fold e in
  (* Should be just Var "x" *)
  match e' with
  | Var "x" -> ()
  | _ -> Alcotest.fail "Expected Var \"x\""

(* Test algebraic simplification - 0 + x *)
let test_simplify_add_zero_left () =
  let e = Add (Int 0, Var "x") in
  let e' = const_fold e in
  match e' with
  | Var "x" -> ()
  | _ -> Alcotest.fail "Expected Var \"x\""

(* Test algebraic simplification - x - 0 *)
let test_simplify_sub_zero () =
  let e = Sub (Var "x", Int 0) in
  let e' = const_fold e in
  match e' with
  | Var "x" -> ()
  | _ -> Alcotest.fail "Expected Var \"x\""

(* Test algebraic simplification - x * 0 *)
let test_simplify_mul_zero_right () =
  let e = Mul (Var "x", Int 0) in
  let e' = const_fold e in
  match e' with
  | Int 0 -> ()
  | _ -> Alcotest.fail "Expected Int 0"

(* Test algebraic simplification - 0 * x *)
let test_simplify_mul_zero_left () =
  let e = Mul (Int 0, Var "x") in
  let e' = const_fold e in
  match e' with
  | Int 0 -> ()
  | _ -> Alcotest.fail "Expected Int 0"

(* Test algebraic simplification - x * 1 *)
let test_simplify_mul_one_right () =
  let e = Mul (Var "x", Int 1) in
  let e' = const_fold e in
  match e' with
  | Var "x" -> ()
  | _ -> Alcotest.fail "Expected Var \"x\""

(* Test algebraic simplification - 1 * x *)
let test_simplify_mul_one_left () =
  let e = Mul (Int 1, Var "x") in
  let e' = const_fold e in
  match e' with
  | Var "x" -> ()
  | _ -> Alcotest.fail "Expected Var \"x\""

(* Test algebraic simplification - x / 1 *)
let test_simplify_div_one () =
  let e = Div (Var "x", Int 1) in
  let e' = const_fold e in
  match e' with
  | Var "x" -> ()
  | _ -> Alcotest.fail "Expected Var \"x\""

(* Test composition of transformations *)
let test_composition () =
  (* (2 * 3) + 0 should fold to 6 then simplify to 6 *)
  let e = Add (Mul (Int 2, Int 3), Int 0) in
  let e' = const_fold e in
  match e' with
  | Int 6 -> ()
  | _ -> Alcotest.fail "Expected Int 6"

(* Test with variables that can't be folded *)
let test_with_variables () =
  (* x + y can't be folded, but should remain unchanged *)
  let e = Add (Var "x", Var "y") in
  let e' = const_fold e in
  match e' with
  | Add (Var "x", Var "y") -> ()
  | _ -> Alcotest.fail "Expected Add (Var \"x\", Var \"y\")"

(* Test let bindings *)
let test_let_simple () =
  (* let x = 2 + 3 in x + 0 should become let x = 5 in x *)
  let e = Let ("x", Add (Int 2, Int 3), Add (Var "x", Int 0)) in
  let e' = const_fold e in
  match e' with
  | Let ("x", Int 5, Var "x") -> ()
  | _ -> Alcotest.fail "Expected Let (\"x\", Int 5, Var \"x\")"

(* Test let bindings - complex *)
let test_let_complex () =
  (* let x = 10 in (x + 0) * 1 should become let x = 10 in x *)
  let e = Let ("x", Int 10, Mul (Add (Var "x", Int 0), Int 1)) in
  let e' = const_fold e in
  match e' with
  | Let ("x", Int 10, Var "x") -> ()
  | _ -> Alcotest.fail "Expected Let (\"x\", Int 10, Var \"x\")"

(* Test semantic equivalence - property *)
let test_semantic_equivalence () =
  let test_cases = [
    Add (Int 2, Int 3);
    Mul (Add (Int 2, Int 3), Int 4);
    Add (Mul (Int 2, Int 3), Int 0);
    Let ("x", Add (Int 2, Int 3), Mul (Var "x", Int 2));
  ] in
  List.iter (fun e ->
    let e' = const_fold e in
    check_equiv "semantic equivalence" e e'
  ) test_cases

(* Test deep nesting *)
let test_deep_nesting () =
  (* ((1 + 2) * (3 + 4)) + 0 *)
  let e = Add (Mul (Add (Int 1, Int 2), Add (Int 3, Int 4)), Int 0) in
  let e' = const_fold e in
  match e' with
  | Int 21 -> ()  (* (3 * 7) = 21 *)
  | _ -> Alcotest.fail "Expected Int 21"

(* Test that variables are preserved correctly *)
let test_variables_preserved () =
  (* (x + 0) * 1 should become x *)
  let e = Mul (Add (Var "x", Int 0), Int 1) in
  let e' = const_fold e in
  match e' with
  | Var "x" -> ()
  | _ -> Alcotest.fail "Expected Var \"x\""

(* Test suite *)
let () =
  let open Alcotest in
  run "Task10_ConstantFolding" [
    "constant_folding", [
      test_case "integers" `Quick test_fold_int;
      test_case "add constants" `Quick test_fold_add_constants;
      test_case "sub constants" `Quick test_fold_sub_constants;
      test_case "mul constants" `Quick test_fold_mul_constants;
      test_case "div constants" `Quick test_fold_div_constants;
      test_case "nested operations" `Quick test_fold_nested;
      test_case "deep nesting" `Quick test_deep_nesting;
    ];
    "algebraic_simplifications", [
      test_case "x + 0 = x" `Quick test_simplify_add_zero_right;
      test_case "0 + x = x" `Quick test_simplify_add_zero_left;
      test_case "x - 0 = x" `Quick test_simplify_sub_zero;
      test_case "x * 0 = 0" `Quick test_simplify_mul_zero_right;
      test_case "0 * x = 0" `Quick test_simplify_mul_zero_left;
      test_case "x * 1 = x" `Quick test_simplify_mul_one_right;
      test_case "1 * x = x" `Quick test_simplify_mul_one_left;
      test_case "x / 1 = x" `Quick test_simplify_div_one;
      test_case "variables preserved" `Quick test_variables_preserved;
    ];
    "composition", [
      test_case "fold then simplify" `Quick test_composition;
      test_case "with variables" `Quick test_with_variables;
    ];
    "let_bindings", [
      test_case "simple let" `Quick test_let_simple;
      test_case "complex let" `Quick test_let_complex;
    ];
    "properties", [
      test_case "semantic equivalence" `Quick test_semantic_equivalence;
    ];
  ]

