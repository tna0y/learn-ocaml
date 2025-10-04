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
  
  type t = unit  (* TODO: Replace with your set type using Ord.t *)
  
  let empty = failwith "TODO"
  
  let add _x _s = failwith "TODO"
  (* Hint: Insert x maintaining sorted order using Ord.compare *)
  
  let mem _x _s = failwith "TODO"
  (* Hint: Search for x using Ord.compare *)
  
  let to_list _s = failwith "TODO"
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

