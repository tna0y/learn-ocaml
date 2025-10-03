(* Tests for Task 6: Modules and Functors *)

open Rational

(* Helper to create testable for rational *)
let rational = Alcotest.testable
  (fun ppf r -> Format.fprintf ppf "%s" (to_string r))
  (fun a b -> a.num = b.num && a.den = b.den)

(* Tests for make *)
let test_make_simple () =
  let r = make 2 3 in
  Alcotest.(check int) "numerator" 2 r.num;
  Alcotest.(check int) "denominator" 3 r.den

let test_make_simplified () =
  let r = make 6 9 in  (* Should simplify to 2/3 *)
  Alcotest.(check int) "simplified numerator" 2 r.num;
  Alcotest.(check int) "simplified denominator" 3 r.den

let test_make_negative () =
  (* Sign should be in numerator *)
  let r1 = make (-6) 9 in
  Alcotest.(check int) "negative num" (-2) r1.num;
  Alcotest.(check int) "positive den" 3 r1.den;
  
  let r2 = make 6 (-9) in
  Alcotest.(check int) "negative num from neg den" (-2) r2.num;
  Alcotest.(check int) "positive den from neg den" 3 r2.den

let test_make_zero () =
  let r = make 0 5 in
  Alcotest.(check int) "zero numerator" 0 r.num;
  Alcotest.(check int) "one denominator" 1 r.den

let test_make_invalid () =
  Alcotest.check_raises "zero denominator"
    (Failure "Denominator cannot be zero")
    (fun () -> ignore (make 5 0))

(* Tests for add *)
let test_add_simple () =
  let r = add (make 1 2) (make 1 3) in
  Alcotest.(check rational) "1/2 + 1/3 = 5/6"
    (make 5 6) r

let test_add_same_denominator () =
  let r = add (make 1 4) (make 1 4) in
  Alcotest.(check rational) "1/4 + 1/4 = 1/2"
    (make 1 2) r

let test_add_with_simplification () =
  let r = add (make 1 6) (make 1 3) in
  Alcotest.(check rational) "1/6 + 1/3 = 1/2"
    (make 1 2) r

let test_add_negative () =
  let r = add (make 1 2) (make (-1) 3) in
  Alcotest.(check rational) "1/2 + (-1/3) = 1/6"
    (make 1 6) r

(* Tests for mul *)
let test_mul_simple () =
  let r = mul (make 2 3) (make 3 4) in
  Alcotest.(check rational) "2/3 * 3/4 = 1/2"
    (make 1 2) r

let test_mul_by_reciprocal () =
  let r = mul (make 1 2) (make 2 1) in
  Alcotest.(check rational) "1/2 * 2/1 = 1/1"
    (make 1 1) r

let test_mul_by_zero () =
  let r = mul (make 2 3) (make 0 1) in
  Alcotest.(check rational) "2/3 * 0 = 0"
    (make 0 1) r

let test_mul_negative () =
  let r = mul (make 2 3) (make (-3) 2) in
  Alcotest.(check rational) "2/3 * (-3/2) = -1/1"
    (make (-1) 1) r

(* Tests for to_string *)
let test_to_string () =
  Alcotest.(check string) "2/3" "2/3" (to_string (make 2 3));
  Alcotest.(check string) "-2/3" "-2/3" (to_string (make (-2) 3));
  Alcotest.(check bool) "5/1 or 5" true 
    (let s = to_string (make 5 1) in s = "5/1" || s = "5")

(* Integration tests *)
let test_complex_expression () =
  (* (1/2 + 1/3) * 2/5 = 5/6 * 2/5 = 10/30 = 1/3 *)
  let sum = add (make 1 2) (make 1 3) in
  let result = mul sum (make 2 5) in
  Alcotest.(check rational) "(1/2 + 1/3) * 2/5 = 1/3"
    (make 1 3) result

let test_chain_operations () =
  (* 1/2 + 1/4 + 1/8 = 7/8 *)
  let r1 = add (make 1 2) (make 1 4) in  (* 3/4 *)
  let r2 = add r1 (make 1 8) in          (* 7/8 *)
  Alcotest.(check rational) "1/2 + 1/4 + 1/8 = 7/8"
    (make 7 8) r2

(* Test suite *)
let () =
  let open Alcotest in
  run "Task06_Modules" [
    "make", [
      test_case "simple creation" `Quick test_make_simple;
      test_case "simplification" `Quick test_make_simplified;
      test_case "negative numbers" `Quick test_make_negative;
      test_case "zero" `Quick test_make_zero;
      test_case "invalid (zero denominator)" `Quick test_make_invalid;
    ];
    "add", [
      test_case "simple addition" `Quick test_add_simple;
      test_case "same denominator" `Quick test_add_same_denominator;
      test_case "with simplification" `Quick test_add_with_simplification;
      test_case "with negative" `Quick test_add_negative;
    ];
    "mul", [
      test_case "simple multiplication" `Quick test_mul_simple;
      test_case "by reciprocal" `Quick test_mul_by_reciprocal;
      test_case "by zero" `Quick test_mul_by_zero;
      test_case "with negative" `Quick test_mul_negative;
    ];
    "to_string", [
      test_case "string conversion" `Quick test_to_string;
    ];
    "integration", [
      test_case "complex expression" `Quick test_complex_expression;
      test_case "chain operations" `Quick test_chain_operations;
    ];
  ]

