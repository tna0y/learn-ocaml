(** Arithmetic Expression AST *)

(** {1 Expression Type} *)

(** The type of arithmetic expressions. *)
type expr =
  | Int of int                    (** Integer literal *)
  | Add of expr * expr           (** Addition *)
  | Sub of expr * expr           (** Subtraction *)
  | Mul of expr * expr           (** Multiplication *)
  | Div of expr * expr           (** Division *)

(** {1 Evaluation} *)

(** [eval e] evaluates expression [e] to an integer.
    
    @param e the expression to evaluate
    @return the integer result
    @raise Division_by_zero if dividing by zero
    
    Examples:
    - [eval (Int 42) = 42]
    - [eval (Add (Int 1, Int 2)) = 3]
    - [eval (Mul (Add (Int 1, Int 2), Int 3)) = 9]
    - [eval (Sub (Int 10, Div (Int 8, Int 2))) = 6]
*)
val eval : expr -> int

(** {1 Pretty-Printing} *)

(** [pp_expr fmt e] prints expression [e] to formatter [fmt].
    
    Uses parentheses to show structure clearly.
    
    @param fmt the formatter to print to
    @param e the expression to print
    
    Examples:
    - [pp_expr fmt (Int 42)] prints ["42"]
    - [pp_expr fmt (Add (Int 1, Int 2))] prints ["(1 + 2)"]
    - [pp_expr fmt (Mul (Add (Int 1, Int 2), Int 3))] prints ["((1 + 2) * 3)"]
*)
val pp_expr : Format.formatter -> expr -> unit

(** [expr_to_string e] converts expression [e] to a string.
    
    Convenience wrapper around [pp_expr].
    
    @param e the expression
    @return string representation
    
    Examples:
    - [expr_to_string (Int 42) = "42"]
    - [expr_to_string (Add (Int 1, Int 2)) = "(1 + 2)"]
*)
val expr_to_string : expr -> string

