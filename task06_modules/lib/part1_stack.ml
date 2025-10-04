(** Part 1: Basic Stack Module - Implementation *)

(* Task: Implement a stack using a list
 * 
 * Key learning: The .mli file keeps 'type t' abstract,
 * so users can't directly access the list implementation.
 * This is encapsulation!
 *)

(** The stack type - implement this however you want (list is easiest) *)
type 'a t = unit  (* TODO: Replace 'unit' with your implementation *)

(** Empty stack *)
let empty = failwith "TODO: Implement empty"

(** Push an element *)
let push _x _s = failwith "TODO: Implement push"
(* Hint: If using list, this is just :: (cons) *)

(** Pop an element *)
let pop _s = failwith "TODO: Implement pop"
(* Hint: Pattern match on your representation
 * - Empty case: return None
 * - Non-empty: return Some (element, rest)
 *)

(** Peek at top element *)
let peek _s = failwith "TODO: Implement peek"
(* Hint: Similar to pop, but don't remove the element *)

