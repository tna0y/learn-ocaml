(** Part 2: Counter Module - Full Signature *)

(** This is the FULL signature - exposes all operations *)

type t

val create : int -> t
val increment : t -> t
val decrement : t -> t  
val get_value : t -> int
val reset : t -> t

