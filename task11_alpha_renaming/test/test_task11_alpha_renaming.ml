(* Tests for Task 11: Alpha-Renaming and Shadow Elimination *)

open Alpha_rename

(* Helper to check semantic equivalence *)
let check_equiv msg e e' =
  let v1 = eval [] e in
  let v2 = eval [] e' in
  Alcotest.(check int) msg v1 v2

(* Test fresh_var *)
let test_fresh_var () =
  reset_counter ();
  Alcotest.(check string) "first call" "x_0" (fresh_var "x");
  Alcotest.(check string) "second call" "x_1" (fresh_var "x");
  Alcotest.(check string) "different base" "y_2" (fresh_var "y");
  reset_counter ();
  Alcotest.(check string) "after reset" "z_0" (fresh_var "z")

(* Test lookup_rename *)
let test_lookup_rename_found () =
  let env = [("x", "x_0"); ("y", "y_1")] in
  Alcotest.(check string) "lookup x" "x_0" (lookup_rename "x" env);
  Alcotest.(check string) "lookup y" "y_1" (lookup_rename "y" env)

let test_lookup_rename_not_found () =
  let env = [("x", "x_0")] in
  Alcotest.(check string) "lookup z" "z" (lookup_rename "z" env)

let test_lookup_rename_shadowing () =
  (* First match should win *)
  let env = [("x", "x_1"); ("x", "x_0")] in
  Alcotest.(check string) "shadowed lookup" "x_1" (lookup_rename "x" env)

(* Test alpha_rename - simple cases *)
let test_rename_int () =
  let e = Int 42 in
  let e' = alpha_rename e in
  match e' with
  | Int 42 -> ()
  | _ -> Alcotest.fail "Expected Int 42"

let test_rename_var () =
  (* Free variables should remain unchanged *)
  let e = Var "x" in
  let e' = alpha_rename e in
  match e' with
  | Var "x" -> ()
  | _ -> Alcotest.fail "Expected Var \"x\""

let test_rename_simple_let () =
  (* let x = 5 in x *)
  let e = Let ("x", Int 5, Var "x") in
  let e' = alpha_rename e in
  match e' with
  | Let ("x_0", Int 5, Var "x_0") -> ()
  | _ -> Alcotest.fail "Expected Let (\"x_0\", Int 5, Var \"x_0\")"

(* Test alpha_rename - shadowing *)
let test_rename_shadowing_simple () =
  (* let x = 1 in let x = 2 in x *)
  let e = Let ("x", Int 1,
            Let ("x", Int 2,
              Var "x")) in
  let e' = alpha_rename e in
  match e' with
  | Let ("x_0", Int 1,
      Let ("x_1", Int 2,
        Var "x_1")) -> ()
  | _ -> Alcotest.fail "Expected proper shadowing elimination"

let test_rename_shadowing_reference () =
  (* let x = 10 in let x = x + 5 in x *)
  (* Inner x should reference outer x in its binding *)
  let e = Let ("x", Int 10,
            Let ("x", Add (Var "x", Int 5),
              Var "x")) in
  let e' = alpha_rename e in
  match e' with
  | Let ("x_0", Int 10,
      Let ("x_1", Add (Var "x_0", Int 5),  (* References x_0 *)
        Var "x_1")) -> ()  (* But body uses x_1 *)
  | _ -> Alcotest.fail "Expected Let (\"x_0\", ..., Let (\"x_1\", Add (Var \"x_0\", ...), Var \"x_1\"))"

(* Test alpha_rename - nested lets *)
let test_rename_nested () =
  (* let x = 1 in let y = 2 in x + y *)
  let e = Let ("x", Int 1,
            Let ("y", Int 2,
              Add (Var "x", Var "y"))) in
  let e' = alpha_rename e in
  match e' with
  | Let ("x_0", Int 1,
      Let ("y_1", Int 2,
        Add (Var "x_0", Var "y_1"))) -> ()
  | _ -> Alcotest.fail "Expected properly renamed nested lets"

(* Test alpha_rename - complex expression *)
let test_rename_complex () =
  (* let x = 5 in (x + 3) * 2 *)
  let e = Let ("x", Int 5,
            Mul (Add (Var "x", Int 3), Int 2)) in
  let e' = alpha_rename e in
  match e' with
  | Let ("x_0", Int 5,
      Mul (Add (Var "x_0", Int 3), Int 2)) -> ()
  | _ -> Alcotest.fail "Expected Let (\"x_0\", Int 5, Mul (Add (Var \"x_0\", ...), ...))"

(* Test semantic equivalence *)
let test_semantic_equivalence () =
  let test_cases = [
    Let ("x", Int 5, Var "x");
    Let ("x", Int 1, Let ("x", Int 2, Var "x"));
    Let ("x", Int 10, Let ("x", Add (Var "x", Int 5), Var "x"));
    Let ("x", Int 1, Let ("y", Int 2, Add (Var "x", Var "y")));
  ] in
  List.iter (fun e ->
    let e' = alpha_rename e in
    check_equiv "semantic equivalence" e e'
  ) test_cases

(* Test free variables *)
let test_free_variables () =
  (* let x = y in x + z - free variables y and z should remain *)
  let e = Let ("x", Var "y", Add (Var "x", Var "z")) in
  let e' = alpha_rename e in
  match e' with
  | Let ("x_0", Var "y", Add (Var "x_0", Var "z")) -> ()
  | _ -> Alcotest.fail "Expected free variables to remain unchanged"

(* Test triple shadowing *)
let test_triple_shadowing () =
  (* let x = 1 in let x = 2 in let x = 3 in x *)
  let e = Let ("x", Int 1,
            Let ("x", Int 2,
              Let ("x", Int 3,
                Var "x"))) in
  let e' = alpha_rename e in
  match e' with
  | Let ("x_0", Int 1,
      Let ("x_1", Int 2,
        Let ("x_2", Int 3,
          Var "x_2"))) -> ()
  | _ -> Alcotest.fail "Expected x_0, x_1, x_2"

(* Test different variables *)
let test_different_variables () =
  (* let x = 1 in let y = 2 in let z = 3 in x + y + z *)
  let e = Let ("x", Int 1,
            Let ("y", Int 2,
              Let ("z", Int 3,
                Add (Add (Var "x", Var "y"), Var "z")))) in
  let e' = alpha_rename e in
  match e' with
  | Let ("x_0", Int 1,
      Let ("y_1", Int 2,
        Let ("z_2", Int 3,
          Add (Add (Var "x_0", Var "y_1"), Var "z_2")))) -> ()
  | _ -> Alcotest.fail "Expected x_0, y_1, z_2"

(* Test arithmetic operations *)
let test_rename_arithmetic () =
  (* let x = 2 in let y = 3 in (x + y) * (x - y) *)
  let e = Let ("x", Int 2,
            Let ("y", Int 3,
              Mul (Add (Var "x", Var "y"),
                   Sub (Var "x", Var "y")))) in
  let e' = alpha_rename e in
  check_equiv "arithmetic" e e'

(* Test that counter resets *)
let test_counter_reset () =
  let e1 = Let ("x", Int 1, Var "x") in
  let e1' = alpha_rename e1 in
  let e2 = Let ("y", Int 2, Var "y") in
  let e2' = alpha_rename e2 in
  (* Both should start from _0 due to reset *)
  match (e1', e2') with
  | (Let ("x_0", _, _), Let ("y_0", _, _)) -> ()
  | _ -> Alcotest.fail "Counter should reset between alpha_rename calls"

(* Test suite *)
let () =
  let open Alcotest in
  run "Task11_AlphaRenaming" [
    "fresh_var", [
      test_case "fresh variable generation" `Quick test_fresh_var;
    ];
    "lookup_rename", [
      test_case "found" `Quick test_lookup_rename_found;
      test_case "not found" `Quick test_lookup_rename_not_found;
      test_case "shadowing" `Quick test_lookup_rename_shadowing;
    ];
    "alpha_rename_basic", [
      test_case "integers" `Quick test_rename_int;
      test_case "variables" `Quick test_rename_var;
      test_case "simple let" `Quick test_rename_simple_let;
      test_case "free variables" `Quick test_free_variables;
    ];
    "shadowing_elimination", [
      test_case "simple shadowing" `Quick test_rename_shadowing_simple;
      test_case "shadowing with reference" `Quick test_rename_shadowing_reference;
      test_case "triple shadowing" `Quick test_triple_shadowing;
    ];
    "nested_bindings", [
      test_case "nested different vars" `Quick test_rename_nested;
      test_case "different variables" `Quick test_different_variables;
    ];
    "complex", [
      test_case "complex expression" `Quick test_rename_complex;
      test_case "arithmetic operations" `Quick test_rename_arithmetic;
    ];
    "properties", [
      test_case "semantic equivalence" `Quick test_semantic_equivalence;
      test_case "counter reset" `Quick test_counter_reset;
    ];
  ]

