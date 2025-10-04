(** Part 1: Basic Stack Module - Signature *)

(** The type of stacks containing elements of type ['a].
    This type is abstract - users cannot see the implementation. *)
type 'a t

(** [empty] is the empty stack. *)
val empty : 'a t

(** [push x s] adds element [x] to the top of stack [s]. *)
val push : 'a -> 'a t -> 'a t

(** [pop s] removes and returns the top element of stack [s].
    Returns [None] if the stack is empty.
    Returns [Some (x, s')] where [x] is the top element and [s'] is the remaining stack. *)
val pop : 'a t -> ('a * 'a t) option

(** [peek s] returns the top element without removing it.
    Returns [None] if the stack is empty. *)
val peek : 'a t -> 'a option

