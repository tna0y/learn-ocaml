(* Tests for Task 1: Hello World + I/O *)

(* Helper function to run the program with given input and capture output *)
let run_with_input input =
  let cmd = Printf.sprintf "echo '%s' | dune exec task01_hello_world 2>&1" input in
  let ic = Unix.open_process_in cmd in
  let output = ref [] in
  (try
     while true do
       output := input_line ic :: !output
     done
   with End_of_file -> ());
  let status = Unix.close_process_in ic in
  (List.rev !output, status)

(* Test that program prints "Hello, World!" first *)
let test_hello_world () =
  let (lines, _) = run_with_input "Alice" in
  match lines with
  | first_line :: _ ->
      Alcotest.(check string) "first line should be 'Hello, World!'" 
        "Hello, World!" first_line
  | [] ->
      Alcotest.fail "Program produced no output"

(* Test that program prints personalized greeting *)
let test_personalized_greeting () =
  let test_cases = [
    ("Alice", "Hello, Alice!");
    ("Bob", "Hello, Bob!");
    ("OCaml", "Hello, OCaml!");
    ("", "Hello, !");  (* Edge case: empty name *)
  ] in
  List.iter (fun (name, expected) ->
    let (lines, _) = run_with_input name in
    match lines with
    | _ :: second_line :: _ ->
        Alcotest.(check string) 
          (Printf.sprintf "should greet '%s' correctly" name)
          expected second_line
    | _ ->
        Alcotest.fail "Program didn't produce enough output"
  ) test_cases

(* Test complete output for a typical interaction *)
let test_complete_output () =
  let (lines, _) = run_with_input "World" in
  let expected = [
    "Hello, World!";
    "Hello, World!";  (* greeting the input "World" *)
  ] in
  match lines with
  | [line1; line2] ->
      Alcotest.(check string) "first line" (List.nth expected 0) line1;
      Alcotest.(check string) "second line" (List.nth expected 1) line2
  | _ ->
      Alcotest.fail (Printf.sprintf "Expected 2 lines, got %d" (List.length lines))

(* Test suite *)
let () =
  let open Alcotest in
  run "Task01_HelloWorld" [
    "basic_output", [
      test_case "prints Hello, World!" `Quick test_hello_world;
      test_case "prints personalized greeting" `Quick test_personalized_greeting;
      test_case "complete interaction" `Quick test_complete_output;
    ];
  ]

