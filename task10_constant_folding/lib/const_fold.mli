(** Constant Folding and Algebraic Simplifications *)

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

(** {1 Transformation} *)

(** [const_fold e] applies constant folding and algebraic simplifications to [e].
    
    Constant folding rules:
    - [Int a + Int b → Int (a + b)]
    - [Int a - Int b → Int (a - b)]
    - [Int a * Int b → Int (a * b)]
    - [Int a / Int b → Int (a / b)] (if b ≠ 0)
    
    Algebraic simplification rules:
    - [x + 0 → x] and [0 + x → x]
    - [x - 0 → x]
    - [x * 0 → 0] and [0 * x → 0]
    - [x * 1 → x] and [1 * x → x]
    - [x / 1 → x]
    
    For Let bindings:
    - [Let (x, e1, e2) → Let (x, const_fold e1, const_fold e2)]
    
    @param e the expression to transform
    @return transformed expression (semantically equivalent to input)
    
    Examples:
    - [const_fold (Add (Int 2, Int 3)) = Int 5]
    - [const_fold (Add (Var "x", Int 0)) = Var "x"]
    - [const_fold (Mul (Var "x", Int 0)) = Int 0]
    - [const_fold (Add (Mul (Int 2, Int 3), Int 0)) = Int 6]
    
    Property: [eval (const_fold e) = eval e] for all [e]
*)
val const_fold : expr -> expr

(** {1 Evaluation (for testing)} *)

(** Environment type for evaluation. *)
type env = (string * int) list

(** [eval env e] evaluates expression [e] in environment [env].
    
    Provided for testing that transformations preserve semantics.
    
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

