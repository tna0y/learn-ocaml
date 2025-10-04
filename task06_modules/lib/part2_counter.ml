(** Part 2: Counter Module - Implementation *)

(* Task: Implement a simple counter
 *
 * Key learning: Same implementation, different signatures (.mli files)
 * show different interfaces to users!
 *)

type t = int

let create _initial = _initial

let increment _c = _c + 1

let decrement _c = _c - 1

let get_value _c = _c

let reset _c = 0
(* Reset counter to 0 *)

