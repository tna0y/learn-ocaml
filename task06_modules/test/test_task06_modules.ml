(* Tests for Task 6: Modules and Functors *)

open Modules_practice

(* Part 1: Stack tests *)
module TestStack = struct
  
  let test_empty_stack () =
    let s = Part1_stack.empty in
    Alcotest.(check (option int)) "peek empty" None (Part1_stack.peek s);
    Alcotest.(check (option (pair int reject))) "pop empty" None 
      (match Part1_stack.pop s with None -> None | Some (x, _) -> Some (x, ()))
  
  let test_push_pop () =
    let open Part1_stack in
    let s = empty |> push 1 |> push 2 |> push 3 in
    Alcotest.(check (option int)) "peek top" (Some 3) (peek s);
    match pop s with
    | None -> Alcotest.fail "Should not be empty"
    | Some (x, s') ->
        Alcotest.(check int) "popped value" 3 x;
        Alcotest.(check (option int)) "peek after pop" (Some 2) (peek s')
  
  let test_stack_order () =
    let open Part1_stack in
    let s = empty |> push 1 |> push 2 |> push 3 in
    let extract_all s =
      let rec loop acc s =
        match pop s with
        | None -> List.rev acc
        | Some (x, s') -> loop (x :: acc) s'
      in loop [] s
    in
    Alcotest.(check (list int)) "LIFO order" [3; 2; 1] (extract_all s)
end

(* Part 2: Counter tests *)
module TestCounter = struct
  open Part2_counter
  
  let test_create () =
    let c = create 5 in
    Alcotest.(check int) "initial value" 5 (get_value c)
  
  let test_increment () =
    let c = create 0 |> increment |> increment |> increment in
    Alcotest.(check int) "after 3 increments" 3 (get_value c)
  
  let test_decrement () =
    let c = create 10 |> decrement |> decrement in
    Alcotest.(check int) "after 2 decrements" 8 (get_value c)
  
  let test_reset () =
    let c = create 5 |> increment |> increment |> reset in
    Alcotest.(check int) "after reset" 0 (get_value c)
end

(* Part 3: Queue tests *)
module TestQueue = struct
  open Part3_queue
  
  let test_int_queue () =
    let q = IntQueue.empty 
      |> IntQueue.enqueue 1 
      |> IntQueue.enqueue 2 
      |> IntQueue.enqueue 3 in
    match IntQueue.dequeue q with
    | None -> Alcotest.fail "Queue should not be empty"
    | Some (x, q') ->
        Alcotest.(check int) "FIFO first" 1 x;
        match IntQueue.dequeue q' with
        | None -> Alcotest.fail "Queue should have more"
        | Some (y, _) -> Alcotest.(check int) "FIFO second" 2 y
  
  let test_string_queue () =
    let q = StringQueue.empty
      |> StringQueue.enqueue "hello"
      |> StringQueue.enqueue "world" in
    match StringQueue.dequeue q with
    | None -> Alcotest.fail "Queue should not be empty"
    | Some (s, _) -> Alcotest.(check string) "first string" "hello" s
  
  let test_queue_to_string () =
    let q = IntQueue.empty |> IntQueue.enqueue 1 |> IntQueue.enqueue 2 in
    let s = IntQueue.to_string q in
    Alcotest.(check bool) "to_string not empty" true (String.length s > 0)
end

(* Part 4: Set tests *)
module TestSet = struct
  open Part4_set
  
  let test_int_set () =
    let s = IntSet.empty 
      |> IntSet.add 3 
      |> IntSet.add 1 
      |> IntSet.add 2 
      |> IntSet.add 2 in  (* Duplicate *)
    Alcotest.(check bool) "mem 1" true (IntSet.mem 1 s);
    Alcotest.(check bool) "mem 2" true (IntSet.mem 2 s);
    Alcotest.(check bool) "mem 3" true (IntSet.mem 3 s);
    Alcotest.(check bool) "mem 4" false (IntSet.mem 4 s);
    (* Should be sorted and no duplicates *)
    Alcotest.(check (list int)) "sorted list" [1; 2; 3] (IntSet.to_list s)
  
  let test_string_set () =
    let s = StringSet.empty
      |> StringSet.add "dog"
      |> StringSet.add "cat"
      |> StringSet.add "bird"
      |> StringSet.add "cat" in  (* Duplicate *)
    Alcotest.(check (list string)) "sorted strings" 
      ["bird"; "cat"; "dog"] (StringSet.to_list s)
  
  let test_float_set () =
    let s = FloatSet.empty
      |> FloatSet.add 3.14
      |> FloatSet.add 1.0
      |> FloatSet.add 2.5 in
    Alcotest.(check bool) "mem 1.0" true (FloatSet.mem 1.0 s);
    Alcotest.(check bool) "mem 5.0" false (FloatSet.mem 5.0 s)
end

(* Test suite *)
let () =
  let open Alcotest in
  run "Task06_Modules" [
    "Part1_Stack", [
      test_case "empty stack" `Quick TestStack.test_empty_stack;
      test_case "push and pop" `Quick TestStack.test_push_pop;
      test_case "LIFO order" `Quick TestStack.test_stack_order;
    ];
    "Part2_Counter", [
      test_case "create" `Quick TestCounter.test_create;
      test_case "increment" `Quick TestCounter.test_increment;
      test_case "decrement" `Quick TestCounter.test_decrement;
      test_case "reset" `Quick TestCounter.test_reset;
    ];
    "Part3_Queue", [
      test_case "int queue FIFO" `Quick TestQueue.test_int_queue;
      test_case "string queue" `Quick TestQueue.test_string_queue;
      test_case "to_string" `Quick TestQueue.test_queue_to_string;
    ];
    "Part4_Set", [
      test_case "int set" `Quick TestSet.test_int_set;
      test_case "string set" `Quick TestSet.test_string_set;
      test_case "float set" `Quick TestSet.test_float_set;
    ];
  ]
