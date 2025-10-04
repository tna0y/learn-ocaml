(** Part 1: Basic Stack Module - Implementation *)

(* Task: Implement a stack using a list
 * 
 * Key learning: The .mli file keeps 'type t' abstract,
 * so users can't directly access the list implementation.
 * This is encapsulation!
 *)

type 'a t = 'a list
(** The stack type - implement this however you want (list is easiest) *)

(** Empty stack *)
let empty = []

(** Push an element *)
let push _x _s = _x :: _s
(* Hint: If using list, this is just :: (cons) *)

(** Pop an element *)
let pop _s = match _s with [] -> None | x :: xs -> Some (x, xs)
(* Hint: Pattern match on your representation
 * - Empty case: return None
 * - Non-empty: return Some (element, rest)
 *)

(** Peek at top element *)
let peek _s = match _s with [] -> None | x :: _ -> Some (x)
(* Hint: Similar to pop, but don't remove the element *)
