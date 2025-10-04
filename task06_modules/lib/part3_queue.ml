(** Part 3: Generic Queue Functor *)

(* Task: Write a functor that creates queues for any element type
 *
 * Key learning: One functor, multiple instantiations!
 * You write MakeQueue once, then create IntQueue, StringQueue, etc.
 *)

[@@@warning "-32"] (* Suppress unused warnings for skeleton *)

(** Module type for elements *)
module type ELEMENT = sig
  type t

  val to_string : t -> string
end

(** The Queue functor - YOU IMPLEMENT THIS *)
module MakeQueue (E : ELEMENT) : sig
  type t

  val empty : t
  val enqueue : E.t -> t -> t
  val dequeue : t -> (E.t * t) option
  val to_string : t -> string
end = struct
  (* TODO: Implement the queue using E.t as element type
   * 
   * Hints:
   * - type t could be E.t list
   * - enqueue adds to back
   * - dequeue removes from front
   * - Use E.to_string for displaying elements
   *)

  type t = E.t list

  let empty = []
  let enqueue _x _q = _q @ [ _x ]
  let dequeue _q = match _q with [] -> None | x :: xs -> Some (x, xs)
  let to_string _q = _q |> List.map E.to_string |> String.concat ", "
end

(** Now create instantiations - these use YOUR functor! *)

module IntElement : ELEMENT with type t = int = struct
  type t = int

  let to_string = string_of_int
end

module StringElement : ELEMENT with type t = string = struct
  type t = string

  let to_string s = "\"" ^ s ^ "\""
end

module IntQueue = MakeQueue (IntElement)
(** IntQueue - queue of integers *)

module StringQueue = MakeQueue (StringElement)
(** StringQueue - queue of strings *)

(* See the power? One functor, two queues for free! *)
