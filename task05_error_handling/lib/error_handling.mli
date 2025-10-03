(** Error Handling with Option and Result *)

(** {1 Option Type} *)

(** [parse_int s] parses string [s] to an integer.
    
    @param s the string to parse
    @return [Some n] if successful, [None] if parsing fails
    
    Examples:
    - [parse_int "42" = Some 42]
    - [parse_int "abc" = None]
*)
val parse_int : string -> int option

(** [combine_options opt1 opt2] returns the first [Some] value, or [None] if both are [None].
    
    @param opt1 first option
    @param opt2 second option
    @return first [Some] value, or [None]
    
    Examples:
    - [combine_options (Some 5) (Some 10) = Some 5]
    - [combine_options None (Some 10) = Some 10]
    - [combine_options None None = None]
*)
val combine_options : 'a option -> 'a option -> 'a option

(** {1 Result Type} *)

(** [safe_div a b] divides [a] by [b].
    
    @param a dividend
    @param b divisor
    @return [Ok (a/b)] if successful, [Error msg] if [b = 0]
    
    Examples:
    - [safe_div 10 2 = Ok 5]
    - [safe_div 10 0 = Error "Division by zero"]
*)
val safe_div : int -> int -> (int, string) result

(** [safe_sqrt x] computes the square root of [x].
    
    @param x the number
    @return [Ok (sqrt x)] if [x >= 0.0], [Error msg] if [x < 0.0]
    
    Examples:
    - [safe_sqrt 4.0 = Ok 2.0]
    - [safe_sqrt (-1.0) = Error "Cannot take square root of negative number"]
*)
val safe_sqrt : float -> (float, string) result

