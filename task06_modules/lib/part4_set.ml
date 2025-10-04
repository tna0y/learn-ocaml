(** Part 4: Ordered Set Functor *)

(* Task: Write a functor for sets of ordered elements
 *
 * Key learning: See how OCaml's real Set module works!
 * This is the same pattern used in the standard library.
 *)

[@@@warning "-32"]  (* Suppress unused warnings for skeleton *)

(** Module type for ordered types *)
module type ORDERED = sig
  type t
  val compare : t -> t -> int
end

(** The Set functor - YOU IMPLEMENT THIS *)
module MakeSet(Ord : ORDERED) : sig
  type t
  val empty : t
  val add : Ord.t -> t -> t
  val mem : Ord.t -> t -> bool
  val to_list : t -> Ord.t list
end = struct
  (* TODO: Implement a set using Ord.t as element type
   *
   * Hints:
   * - type t could be Ord.t list (sorted, no duplicates)
   * - Use Ord.compare to maintain order and check membership
   * - add: insert maintaining sorted order, skip if exists
   * - mem: search using Ord.compare
   * - to_list: already a list, return as-is
   *)


  type t = 
  | Leaf
  | Node of (Ord.t * t * t)
  
  let empty = Leaf
  
  let rec add _x _s = match _s with
  | Leaf -> Node (_x, Leaf, Leaf)
  | Node (value, left, right) -> (
      match compare _x value with
      | 0 -> _s
      | n when n < 0 -> Node (value, add _x left, right)
      | _ -> Node (value, left, add _x right))
  (* Hint: Insert x maintaining sorted order using Ord.compare *)
  
  let rec mem _x _s = match _s with
  | Leaf -> false
  | Node (value, left, right) -> (
      match compare _x value with
      | 0 -> true
      | n when n < 0 -> mem _x left
      | _ -> mem _x right)
  (* Hint: Search for x using Ord.compare *)
  
  let rec to_list _s = match _s with
  | Leaf -> []
  | Node (value, left, right) -> to_list left @ [value] @ to_list right
end

(** Now create instantiations for different types *)

module IntOrdered : ORDERED with type t = int = struct
  type t = int
  let compare = compare  (* Built-in polymorphic compare works for ints *)
end

module StringOrdered : ORDERED with type t = string = struct
  type t = string
  let compare = compare  (* Works for strings too *)
end

module FloatOrdered : ORDERED with type t = float = struct
  type t = float
  let compare = compare
  (* Note: Float comparison has issues with NaN, but OK for this exercise *)
end

(** IntSet - set of integers *)
module IntSet = MakeSet(IntOrdered)

(** StringSet - set of strings *)
module StringSet = MakeSet(StringOrdered)

(** FloatSet - set of floats *)
module FloatSet = MakeSet(FloatOrdered)

(* Three sets from ONE functor! This is code reuse! *)

