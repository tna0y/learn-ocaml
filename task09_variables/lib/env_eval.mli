(** Environment-Based Expression Evaluator with Variables *)

(** {1 Expression Type} *)

(** The type of expressions with variables and let bindings. *)
type expr =
  | Int of int
  | Add of expr * expr
  | Sub of expr * expr
  | Mul of expr * expr
  | Div of expr * expr
  | Var of string                    (** Variable reference *)
  | Let of string * expr * expr      (** Let binding: let x = e1 in e2 *)

(** {1 Environment} *)

(** The type of environments mapping variable names to values. *)
type env = (string * int) list

(** {1 Operations} *)

(** [lookup x env] looks up variable [x] in environment [env].
    
    @param x the variable name
    @param env the environment
    @return the value bound to [x]
    @raise Failure if [x] is not bound in [env]
    
    Examples:
    - [lookup "x" [("x", 5)] = 5]
    - [lookup "y" [("x", 5); ("y", 3)] = 3]
    - [lookup "x" [("y", 1); ("x", 5); ("x", 3)] = 5] (first match)
*)
val lookup : string -> env -> int

(** [eval env e] evaluates expression [e] in environment [env].
    
    @param env the environment
    @param e the expression
    @return the integer result
    @raise Failure if a variable is unbound
    
    Examples:
    - [eval [] (Int 42) = 42]
    - [eval [("x", 5)] (Var "x") = 5]
    - [eval [] (Let ("x", Int 5, Add (Var "x", Int 3))) = 8]
    - [eval [] (Let ("x", Int 1, Let ("y", Int 2, Add (Var "x", Var "y")))) = 3]
*)
val eval : env -> expr -> int

(** [expr_to_string e] converts expression [e] to a string.
    
    @param e the expression
    @return string representation
    
    Examples:
    - [expr_to_string (Var "x") = "x"]
    - [expr_to_string (Let ("x", Int 5, Var "x")) = "let x = 5 in x"]
*)
val expr_to_string : expr -> string

