(** Alpha-Renaming and Shadow Elimination *)

(** {1 Expression Type} *)

(** The type of expressions with variables and let bindings. *)
type expr =
  | Int of int
  | Add of expr * expr
  | Sub of expr * expr
  | Mul of expr * expr
  | Div of expr * expr
  | Var of string
  | Let of string * expr * expr

(** {1 Renaming Environment} *)

(** Renaming environment mapping old variable names to new names. *)
type rename_env = (string * string) list

(** {1 Fresh Variable Generation} *)

(** [fresh_var base] generates a fresh variable name based on [base].
    
    Uses an internal counter to ensure uniqueness. Each call returns a new name.
    
    @param base the base name for the variable
    @return a fresh variable name in the form "base_N" where N is a unique number
    
    Examples:
    - [fresh_var "x" = "x_0"]
    - [fresh_var "x" = "x_1"]
    - [fresh_var "y" = "y_2"]
    
    Note: The counter is global and persists across calls unless reset.
*)
val fresh_var : string -> string

(** [reset_counter ()] resets the fresh variable counter to 0.
    
    Useful for testing and ensuring consistent output across multiple runs.
*)
val reset_counter : unit -> unit

(** {1 Renaming Operations} *)

(** [lookup_rename x env] looks up variable [x] in renaming environment [env].
    
    @param x the variable name to look up
    @param env the renaming environment
    @return the renamed variable if found, otherwise the original name
    
    Examples:
    - [lookup_rename "x" [("x", "x_0")] = "x_0"]
    - [lookup_rename "y" [("x", "x_0")] = "y"] (not found, return original)
    - [lookup_rename "x" [("x", "x_1"); ("x", "x_0")] = "x_1"] (first match)
*)
val lookup_rename : string -> rename_env -> string

(** [alpha_rename e] renames all variables in [e] to eliminate shadowing.
    
    Generates fresh names for all let-bound variables and updates all references.
    Preserves semantic equivalence: eval (alpha_rename e) = eval e
    
    @param e the expression to rename
    @return expression with unique variable names (no shadowing)
    
    Examples:
    - [alpha_rename (Var "x") = Var "x"] (free variables unchanged)
    - [alpha_rename (Let ("x", Int 5, Var "x")) = Let ("x_0", Int 5, Var "x_0")]
    - [alpha_rename (Let ("x", Int 1, Let ("x", Int 2, Var "x"))) = 
       Let ("x_0", Int 1, Let ("x_1", Int 2, Var "x_1"))]
    
    Note: The counter is reset at the start to ensure consistent output.
*)
val alpha_rename : expr -> expr

(** {1 Evaluation (for testing)} *)

(** Environment type for evaluation. *)
type env = (string * int) list

(** [eval env e] evaluates expression [e] in environment [env].
    
    Provided for testing that alpha-renaming preserves semantics.
    
    @param env the environment
    @param e the expression
    @return the integer result
    @raise Failure if a variable is unbound or division by zero
*)
val eval : env -> expr -> int

(** {1 Utilities} *)

(** [expr_to_string e] converts expression [e] to a string.
    
    @param e the expression
    @return string representation
*)
val expr_to_string : expr -> string

