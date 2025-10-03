(* Tests for Task 4: ADT and BST *)

open Bst

let int_list = Alcotest.(list int)

(* Test empty tree *)
let test_empty () =
  Alcotest.(check bool) "find in empty tree" false (find 5 empty);
  Alcotest.(check int_list) "empty tree to_list" [] (to_list empty)

(* Test single insertion *)
let test_single_insert () =
  let tree = insert 5 empty in
  Alcotest.(check bool) "find inserted element" true (find 5 tree);
  Alcotest.(check bool) "find non-existent" false (find 3 tree);
  Alcotest.(check int_list) "single element to_list" [5] (to_list tree)

(* Test multiple insertions *)
let test_multiple_inserts () =
  let tree = empty 
    |> insert 5 
    |> insert 3 
    |> insert 7 
    |> insert 1 
    |> insert 9 
  in
  Alcotest.(check bool) "find 5" true (find 5 tree);
  Alcotest.(check bool) "find 3" true (find 3 tree);
  Alcotest.(check bool) "find 7" true (find 7 tree);
  Alcotest.(check bool) "find 1" true (find 1 tree);
  Alcotest.(check bool) "find 9" true (find 9 tree);
  Alcotest.(check bool) "find non-existent" false (find 4 tree);
  Alcotest.(check int_list) "to_list is sorted" [1; 3; 5; 7; 9] (to_list tree)

(* Test that to_list produces sorted output *)
let test_to_list_sorted () =
  let tree = empty 
    |> insert 5 
    |> insert 2 
    |> insert 8 
    |> insert 1 
    |> insert 3 
    |> insert 7 
    |> insert 9 
  in
  Alcotest.(check int_list) "to_list is sorted" 
    [1; 2; 3; 5; 7; 8; 9] (to_list tree)

(* Test duplicate insertion *)
let test_duplicate_insert () =
  let tree = empty |> insert 5 |> insert 5 |> insert 5 in
  Alcotest.(check int_list) "no duplicates" [5] (to_list tree)

(* Test insertion order doesn't matter for membership *)
let test_insertion_order () =
  let tree1 = empty |> insert 1 |> insert 2 |> insert 3 in
  let tree2 = empty |> insert 3 |> insert 2 |> insert 1 in
  let tree3 = empty |> insert 2 |> insert 1 |> insert 3 in
  
  Alcotest.(check int_list) "tree1 sorted" [1; 2; 3] (to_list tree1);
  Alcotest.(check int_list) "tree2 sorted" [1; 2; 3] (to_list tree2);
  Alcotest.(check int_list) "tree3 sorted" [1; 2; 3] (to_list tree3)

(* Test with larger tree *)
let test_larger_tree () =
  let values = [15; 10; 20; 8; 12; 17; 25; 6; 11; 16; 27] in
  let tree = List.fold_left (fun t v -> insert v t) empty values in
  
  (* All values should be findable *)
  List.iter (fun v -> 
    Alcotest.(check bool) (Printf.sprintf "find %d" v) true (find v tree)
  ) values;
  
  (* Non-existent values *)
  Alcotest.(check bool) "find 0" false (find 0 tree);
  Alcotest.(check bool) "find 100" false (find 100 tree);
  
  (* to_list should be sorted *)
  let sorted = List.sort compare values |> List.sort_uniq compare in
  Alcotest.(check int_list) "larger tree sorted" sorted (to_list tree)

(* Test with strings *)
let test_string_tree () =
  let tree = empty 
    |> insert "dog" 
    |> insert "cat" 
    |> insert "elephant" 
    |> insert "ant" 
  in
  Alcotest.(check bool) "find dog" true (find "dog" tree);
  Alcotest.(check bool) "find zebra" false (find "zebra" tree);
  Alcotest.(check (list string)) "string tree sorted"
    ["ant"; "cat"; "dog"; "elephant"] (to_list tree)

(* Test suite *)
let () =
  let open Alcotest in
  run "Task04_ADT_BST" [
    "basic", [
      test_case "empty tree" `Quick test_empty;
      test_case "single insert" `Quick test_single_insert;
      test_case "multiple inserts" `Quick test_multiple_inserts;
    ];
    "properties", [
      test_case "to_list is sorted" `Quick test_to_list_sorted;
      test_case "duplicate handling" `Quick test_duplicate_insert;
      test_case "insertion order independence" `Quick test_insertion_order;
    ];
    "larger_trees", [
      test_case "larger integer tree" `Quick test_larger_tree;
      test_case "string tree" `Quick test_string_tree;
    ];
  ]

