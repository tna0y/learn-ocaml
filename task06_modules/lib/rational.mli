(** Rational Numbers Module *)

(** The type of rational numbers. *)
type t = { num : int; den : int }

(** {1 Construction} *)

(** [make num den] creates a rational number [num/den] in simplified form.
    
    @param num numerator
    @param den denominator
    @return simplified rational number
    @raise Failure if [den = 0]
    
    Examples:
    - [make 6 9 = { num = 2; den = 3 }]
    - [make 5 1 = { num = 5; den = 1 }]
    - [make (-6) 9 = { num = -2; den = 3 }]
    - [make 6 (-9) = { num = -2; den = 3 }]  (sign in numerator)
*)
val make : int -> int -> t

(** {1 Arithmetic} *)

(** [add a b] computes [a + b].
    
    Examples:
    - [add (make 1 2) (make 1 3) = make 5 6]
    - [add (make 1 4) (make 1 4) = make 1 2]
*)
val add : t -> t -> t

(** [mul a b] computes [a * b].
    
    Examples:
    - [mul (make 2 3) (make 3 4) = make 1 2]
    - [mul (make 1 2) (make 2 1) = make 1 1]
*)
val mul : t -> t -> t

(** {1 Conversion} *)

(** [to_string r] converts rational [r] to string representation.
    
    Examples:
    - [to_string (make 2 3) = "2/3"]
    - [to_string (make 5 1) = "5" or "5/1"]
    - [to_string (make (-2) 3) = "-2/3"]
*)
val to_string : t -> string

