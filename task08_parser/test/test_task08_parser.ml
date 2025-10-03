(* Tests for Task 8: Recursive Descent Parser *)

open Parser

(* Helper: check parse succeeds *)
let check_parse input expected =
  match parse input with
  | Ok expr -> Alcotest.(check bool) (Printf.sprintf "parse '%s'" input) true (expr = expected)
  | Error msg -> Alcotest.fail (Printf.sprintf "Parse failed: %s" msg)

(* Helper: check parse fails *)
let check_parse_error input =
  match parse input with
  | Ok _ -> Alcotest.fail (Printf.sprintf "Expected parse error for '%s'" input)
  | Error _ -> ()

(* Test parsing integers *)
let test_parse_int () =
  check_parse "0" (Int 0);
  check_parse "42" (Int 42);
  check_parse "123" (Int 123)

(* Test parsing negative integers *)
let test_parse_negative () =
  check_parse "-5" (Int (-5));
  check_parse "-42" (Int (-42))

(* Test parsing with whitespace *)
let test_parse_whitespace () =
  check_parse " 42 " (Int 42);
  check_parse "  123  " (Int 123)

(* Test parsing addition *)
let test_parse_add () =
  check_parse "1 + 2" (Add (Int 1, Int 2));
  check_parse "10+20" (Add (Int 10, Int 20));
  check_parse "1 + 2 + 3" (Add (Add (Int 1, Int 2), Int 3))

(* Test parsing subtraction *)
let test_parse_sub () =
  check_parse "5 - 3" (Sub (Int 5, Int 3));
  check_parse "10-5" (Sub (Int 10, Int 5));
  check_parse "10 - 3 - 2" (Sub (Sub (Int 10, Int 3), Int 2))

(* Test parsing multiplication *)
let test_parse_mul () =
  check_parse "2 * 3" (Mul (Int 2, Int 3));
  check_parse "5*4" (Mul (Int 5, Int 4))

(* Test parsing division *)
let test_parse_div () =
  check_parse "6 / 2" (Div (Int 6, Int 2));
  check_parse "10/5" (Div (Int 10, Int 5))

(* Test operator precedence *)
let test_precedence () =
  (* 1 + 2 * 3 should be 1 + (2 * 3), not (1 + 2) * 3 *)
  check_parse "1 + 2 * 3" (Add (Int 1, Mul (Int 2, Int 3)));
  
  (* 2 * 3 + 4 should be (2 * 3) + 4 *)
  check_parse "2 * 3 + 4" (Add (Mul (Int 2, Int 3), Int 4));
  
  (* 10 - 2 * 3 should be 10 - (2 * 3) *)
  check_parse "10 - 2 * 3" (Sub (Int 10, Mul (Int 2, Int 3)));
  
  (* 6 / 2 + 1 should be (6 / 2) + 1 *)
  check_parse "6 / 2 + 1" (Add (Div (Int 6, Int 2), Int 1))

(* Test parentheses *)
let test_parentheses () =
  check_parse "(1 + 2) * 3" (Mul (Add (Int 1, Int 2), Int 3));
  check_parse "2 * (3 + 4)" (Mul (Int 2, Add (Int 3, Int 4)));
  check_parse "(10 - 5) / (3 - 2)" (Div (Sub (Int 10, Int 5), Sub (Int 3, Int 2)))

(* Test nested parentheses *)
let test_nested_parens () =
  check_parse "((1 + 2))" (Add (Int 1, Int 2));
  check_parse "((1 + 2) * (3 + 4))" (Mul (Add (Int 1, Int 2), Add (Int 3, Int 4)))

(* Test complex expressions *)
let test_complex () =
  (* (1 + 2) * 3 - 4 / 2 *)
  check_parse "(1 + 2) * 3 - 4 / 2" 
    (Sub (Mul (Add (Int 1, Int 2), Int 3), Div (Int 4, Int 2)));
  
  (* 2 * (3 + 4) - (5 - 1) *)
  check_parse "2 * (3 + 4) - (5 - 1)"
    (Sub (Mul (Int 2, Add (Int 3, Int 4)), Sub (Int 5, Int 1)))

(* Test error cases *)
let test_errors () =
  check_parse_error "";           (* Empty input *)
  check_parse_error "1 +";        (* Missing right operand *)
  check_parse_error "+ 1";        (* Missing left operand *)
  check_parse_error "(1 + 2";     (* Unclosed parenthesis *)
  check_parse_error "1 + 2)";     (* Extra closing parenthesis *)
  check_parse_error "1 2";        (* Missing operator *)
  check_parse_error "a + b"       (* Invalid characters *)

(* Test that parse result can be evaluated *)
let test_parse_and_eval () =
  (* We can't actually eval here without Task 7's eval function,
     but we can check the AST structure is correct *)
  match parse "1 + 2 * 3" with
  | Ok (Add (Int 1, Mul (Int 2, Int 3))) -> ()
  | Ok _ -> Alcotest.fail "Wrong AST structure"
  | Error msg -> Alcotest.fail (Printf.sprintf "Parse failed: %s" msg)

(* Test suite *)
let () =
  let open Alcotest in
  run "Task08_Parser" [
    "basic", [
      test_case "integers" `Quick test_parse_int;
      test_case "negative integers" `Quick test_parse_negative;
      test_case "whitespace" `Quick test_parse_whitespace;
    ];
    "operators", [
      test_case "addition" `Quick test_parse_add;
      test_case "subtraction" `Quick test_parse_sub;
      test_case "multiplication" `Quick test_parse_mul;
      test_case "division" `Quick test_parse_div;
    ];
    "precedence", [
      test_case "operator precedence" `Quick test_precedence;
    ];
    "grouping", [
      test_case "parentheses" `Quick test_parentheses;
      test_case "nested parentheses" `Quick test_nested_parens;
    ];
    "complex", [
      test_case "complex expressions" `Quick test_complex;
    ];
    "errors", [
      test_case "error cases" `Quick test_errors;
    ];
    "integration", [
      test_case "parse and check AST" `Quick test_parse_and_eval;
    ];
  ]

