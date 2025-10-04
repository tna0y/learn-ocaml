(* Tests for Task 5: Error Handling *)

open Error_handling

(* Helper testables *)
let int_option = Alcotest.(option int)
let int_result = Alcotest.(result int string)
let float_result = Alcotest.(result (float 0.001) string)

(* Tests for parse_int *)
let test_parse_int_valid () =
  Alcotest.(check int_option) "parse_int \"42\"" (Some 42) (parse_int "42");
  Alcotest.(check int_option) "parse_int \"0\"" (Some 0) (parse_int "0");
  Alcotest.(check int_option) "parse_int \"-100\"" (Some (-100)) (parse_int "-100")

let test_parse_int_invalid () =
  Alcotest.(check int_option) "parse_int \"abc\"" None (parse_int "abc");
  Alcotest.(check int_option) "parse_int \"\"" None (parse_int "");
  Alcotest.(check int_option) "parse_int \"12.5\"" None (parse_int "12.5");
  Alcotest.(check int_option) "parse_int \"12abc\"" None (parse_int "12abc")

(* Tests for combine_options *)
let test_combine_both_some () =
  Alcotest.(check int_option) "Some 5, Some 10" 
    (Some 5) (combine_options (Some 5) (Some 10))

let test_combine_first_none () =
  Alcotest.(check int_option) "None, Some 10" 
    (Some 10) (combine_options None (Some 10))

let test_combine_second_none () =
  Alcotest.(check int_option) "Some 5, None" 
    (Some 5) (combine_options (Some 5) None)

let test_combine_both_none () =
  Alcotest.(check int_option) "None, None" 
    None (combine_options None None)

(* Tests for safe_div *)
let test_safe_div_success () =
  Alcotest.(check int_result) "10 / 2" (Ok 5) (safe_div 10 2);
  Alcotest.(check int_result) "7 / 3" (Ok 2) (safe_div 7 3);
  Alcotest.(check int_result) "0 / 5" (Ok 0) (safe_div 0 5);
  Alcotest.(check int_result) "-10 / 2" (Ok (-5)) (safe_div (-10) 2)

let test_safe_div_by_zero () =
  match safe_div 10 0 with
  | Error msg -> 
      let lower = String.lowercase_ascii msg in
      let contains_zero = 
        try let _ = Str.search_forward (Str.regexp_string "zero") lower 0 in true
        with Not_found -> false
      in
      Alcotest.(check bool) "error message contains 'zero'" true contains_zero
  | Ok _ -> Alcotest.fail "Expected Error for division by zero"

(* Tests for safe_sqrt *)
let test_safe_sqrt_positive () =
  Alcotest.(check float_result) "sqrt 4.0" (Ok 2.0) (safe_sqrt 4.0);
  Alcotest.(check float_result) "sqrt 0.0" (Ok 0.0) (safe_sqrt 0.0);
  Alcotest.(check float_result) "sqrt 9.0" (Ok 3.0) (safe_sqrt 9.0)

let test_safe_sqrt_negative () =
  match safe_sqrt (-1.0) with
  | Error msg -> 
      let lower = String.lowercase_ascii msg in
      let contains_negative = 
        try let _ = Str.search_forward (Str.regexp_string "negative") lower 0 in true
        with Not_found -> false
      in
      Alcotest.(check bool) "error message contains 'negative'" true contains_negative
  | Ok _ -> Alcotest.fail "Expected Error for negative number"

(* Test chaining operations *)
let test_chaining () =
  (* Parse a number, divide by 2, check if positive *)
  let process s divisor =
    match parse_int s with
    | None -> Error "Parse failed"
    | Some n -> safe_div n divisor
  in
  Alcotest.(check int_result) "chain: \"10\" / 2" (Ok 5) (process "10" 2);
  match process "abc" 2 with
  | Error _ -> Alcotest.(check pass) "chain: invalid parse" () ()
  | Ok _ -> Alcotest.fail "Expected error for invalid input"

(* Test suite *)
let () =
  let open Alcotest in
  run "Task05_ErrorHandling" [
    "parse_int", [
      test_case "valid integers" `Quick test_parse_int_valid;
      test_case "invalid strings" `Quick test_parse_int_invalid;
    ];
    "combine_options", [
      test_case "both Some" `Quick test_combine_both_some;
      test_case "first None" `Quick test_combine_first_none;
      test_case "second None" `Quick test_combine_second_none;
      test_case "both None" `Quick test_combine_both_none;
    ];
    "safe_div", [
      test_case "successful division" `Quick test_safe_div_success;
      test_case "division by zero" `Quick test_safe_div_by_zero;
    ];
    "safe_sqrt", [
      test_case "positive numbers" `Quick test_safe_sqrt_positive;
      test_case "negative number" `Quick test_safe_sqrt_negative;
    ];
    "integration", [
      test_case "chaining operations" `Quick test_chaining;
    ];
  ]

