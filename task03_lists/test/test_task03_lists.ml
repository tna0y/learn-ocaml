(* Tests for Task 3: Pattern Matching and Lists *)

open List_ops

(* Helper to create int list testable *)
let int_list = Alcotest.(list int)

(* Tests for map *)
let test_map_empty () =
  Alcotest.(check int_list) "map on empty list" 
    [] (map (fun x -> x * 2) [])

let test_map_double () =
  Alcotest.(check int_list) "map double" 
    [2; 4; 6] (map (fun x -> x * 2) [1; 2; 3])

let test_map_string_length () =
  Alcotest.(check int_list) "map string length" 
    [2; 5; 5] (map String.length ["hi"; "hello"; "world"])

let test_map_identity () =
  Alcotest.(check int_list) "map identity" 
    [1; 2; 3; 4; 5] (map (fun x -> x) [1; 2; 3; 4; 5])

(* Tests for filter *)
let test_filter_empty () =
  Alcotest.(check int_list) "filter on empty list" 
    [] (filter (fun x -> x > 0) [])

let test_filter_positive () =
  Alcotest.(check int_list) "filter positive" 
    [1; 2; 3] (filter (fun x -> x > 0) [-1; 0; 1; 2; 3])

let test_filter_even () =
  Alcotest.(check int_list) "filter even" 
    [2; 4; 6] (filter (fun x -> x mod 2 = 0) [1; 2; 3; 4; 5; 6])

let test_filter_all_match () =
  Alcotest.(check int_list) "filter all match" 
    [1; 2; 3] (filter (fun _ -> true) [1; 2; 3])

let test_filter_none_match () =
  Alcotest.(check int_list) "filter none match" 
    [] (filter (fun _ -> false) [1; 2; 3])

(* Tests for fold_left *)
let test_fold_left_empty () =
  Alcotest.(check int) "fold_left on empty list" 
    42 (fold_left (+) 42 [])

let test_fold_left_sum () =
  Alcotest.(check int) "fold_left sum" 
    10 (fold_left (+) 0 [1; 2; 3; 4])

let test_fold_left_product () =
  Alcotest.(check int) "fold_left product" 
    24 (fold_left ( * ) 1 [1; 2; 3; 4])

let test_fold_left_concat () =
  Alcotest.(check string) "fold_left concat" 
    "abc" (fold_left (^) "" ["a"; "b"; "c"])

let test_fold_left_reverse () =
  (* fold_left with cons reverses the list *)
  Alcotest.(check int_list) "fold_left reverse" 
    [3; 2; 1] (fold_left (fun acc x -> x :: acc) [] [1; 2; 3])

let test_fold_left_count () =
  Alcotest.(check int) "fold_left count" 
    5 (fold_left (fun acc _ -> acc + 1) 0 [10; 20; 30; 40; 50])

(* Composition tests *)
let test_composition_map_filter () =
  let result = 
    [1; 2; 3; 4; 5; 6]
    |> filter (fun x -> x mod 2 = 0)
    |> map (fun x -> x * x)
  in
  Alcotest.(check int_list) "filter then map" [4; 16; 36] result

let test_composition_sum_of_squares_of_evens () =
  let result = 
    [1; 2; 3; 4; 5; 6]
    |> filter (fun x -> x mod 2 = 0)
    |> map (fun x -> x * x)
    |> fold_left (+) 0
  in
  Alcotest.(check int) "sum of squares of evens" 56 result

(* Test that implementations work with large lists (tail recursion test) *)
let test_large_list () =
  let large_list = List.init 10000 (fun i -> i) in
  let result = map (fun x -> x + 1) large_list in
  Alcotest.(check int) "large list first element" 1 (List.hd result);
  Alcotest.(check int) "large list last element" 10000 (List.hd (List.rev result))

(* Test suite *)
let () =
  let open Alcotest in
  run "Task03_Lists" [
    "map", [
      test_case "empty list" `Quick test_map_empty;
      test_case "double" `Quick test_map_double;
      test_case "string length" `Quick test_map_string_length;
      test_case "identity" `Quick test_map_identity;
    ];
    "filter", [
      test_case "empty list" `Quick test_filter_empty;
      test_case "positive numbers" `Quick test_filter_positive;
      test_case "even numbers" `Quick test_filter_even;
      test_case "all match" `Quick test_filter_all_match;
      test_case "none match" `Quick test_filter_none_match;
    ];
    "fold_left", [
      test_case "empty list" `Quick test_fold_left_empty;
      test_case "sum" `Quick test_fold_left_sum;
      test_case "product" `Quick test_fold_left_product;
      test_case "concat" `Quick test_fold_left_concat;
      test_case "reverse" `Quick test_fold_left_reverse;
      test_case "count" `Quick test_fold_left_count;
    ];
    "composition", [
      test_case "map and filter" `Quick test_composition_map_filter;
      test_case "sum of squares of evens" `Quick test_composition_sum_of_squares_of_evens;
      test_case "large list (tail recursion)" `Quick test_large_list;
    ];
  ]

