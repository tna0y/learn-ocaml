(* Tests for Task 8: Recursive Descent Parser *)

open Parser

(* ========== Lexer Tests ========== *)

(* Helper: check lex succeeds *)
let check_lex input expected =
  match lex input with
  | Ok tokens -> Alcotest.(check bool) (Printf.sprintf "lex '%s'" input) true (tokens = expected)
  | Error msg -> Alcotest.fail (Printf.sprintf "Lex failed: %s" msg)

(* Helper: check lex fails *)
let check_lex_error input =
  match lex input with
  | Ok _ -> Alcotest.fail (Printf.sprintf "Expected lex error for '%s'" input)
  | Error _ -> ()

(* Test lexing integers *)
let test_lex_int () =
  check_lex "0" [INT 0; EOF];
  check_lex "42" [INT 42; EOF];
  check_lex "123" [INT 123; EOF]

(* Test lexing negative integers *)
let test_lex_negative () =
  check_lex "-5" [INT (-5); EOF];
  check_lex "-42" [INT (-42); EOF]

(* Test lexing operators *)
let test_lex_operators () =
  check_lex "+" [PLUS; EOF];
  check_lex "-" [MINUS; EOF];
  check_lex "*" [TIMES; EOF];
  check_lex "/" [DIV; EOF]

(* Test lexing parentheses *)
let test_lex_parens () =
  check_lex "(" [LPAREN; EOF];
  check_lex ")" [RPAREN; EOF];
  check_lex "()" [LPAREN; RPAREN; EOF]

(* Test lexing with whitespace *)
let test_lex_whitespace () =
  check_lex " 42 " [INT 42; EOF];
  check_lex "  123  " [INT 123; EOF];
  check_lex "1 + 2" [INT 1; PLUS; INT 2; EOF]

(* Test lexing simple expressions *)
let test_lex_simple_expr () =
  check_lex "1+2" [INT 1; PLUS; INT 2; EOF];
  check_lex "1 + 2" [INT 1; PLUS; INT 2; EOF];
  check_lex "5 - 3" [INT 5; MINUS; INT 3; EOF];
  check_lex "2*3" [INT 2; TIMES; INT 3; EOF];
  check_lex "6 / 2" [INT 6; DIV; INT 2; EOF]

(* Test lexing complex expressions *)
let test_lex_complex () =
  check_lex "1 + 2 * 3" [INT 1; PLUS; INT 2; TIMES; INT 3; EOF];
  check_lex "(1 + 2) * 3" [LPAREN; INT 1; PLUS; INT 2; RPAREN; TIMES; INT 3; EOF];
  check_lex "2 * (3 + 4)" [INT 2; TIMES; LPAREN; INT 3; PLUS; INT 4; RPAREN; EOF]

(* Test lexing errors *)
let test_lex_errors () =
  check_lex_error "abc";    (* Invalid character *)
  check_lex_error "1 @ 2";  (* Invalid operator *)
  check_lex_error "1 # 2"   (* Invalid character *)

(* ========== Parser Tests ========== *)

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
    "lexer_basic", [
      test_case "integers" `Quick test_lex_int;
      test_case "negative integers" `Quick test_lex_negative;
      test_case "operators" `Quick test_lex_operators;
      test_case "parentheses" `Quick test_lex_parens;
      test_case "whitespace" `Quick test_lex_whitespace;
    ];
    "lexer_expressions", [
      test_case "simple expressions" `Quick test_lex_simple_expr;
      test_case "complex expressions" `Quick test_lex_complex;
    ];
    "lexer_errors", [
      test_case "invalid characters" `Quick test_lex_errors;
    ];
    "parser_basic", [
      test_case "integers" `Quick test_parse_int;
      test_case "negative integers" `Quick test_parse_negative;
      test_case "whitespace" `Quick test_parse_whitespace;
    ];
    "parser_operators", [
      test_case "addition" `Quick test_parse_add;
      test_case "subtraction" `Quick test_parse_sub;
      test_case "multiplication" `Quick test_parse_mul;
      test_case "division" `Quick test_parse_div;
    ];
    "parser_precedence", [
      test_case "operator precedence" `Quick test_precedence;
    ];
    "parser_grouping", [
      test_case "parentheses" `Quick test_parentheses;
      test_case "nested parentheses" `Quick test_nested_parens;
    ];
    "parser_complex", [
      test_case "complex expressions" `Quick test_complex;
    ];
    "parser_errors", [
      test_case "error cases" `Quick test_errors;
    ];
    "integration", [
      test_case "parse and check AST" `Quick test_parse_and_eval;
    ];
  ]

