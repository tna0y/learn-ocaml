(** Part 2: Counter Module - Limited Signature *)

(** This is the LIMITED signature - hides get_value and reset!
    
    Task: Compare this with part2_counter.mli
    Same implementation, but this signature restricts what users can do.
    
    Users can increment/decrement but can't peek at or reset the value!
*)

type t

val create : int -> t
val increment : t -> t
val decrement : t -> t
(* Note: get_value and reset are NOT exposed! *)

