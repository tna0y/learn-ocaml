(** Recursive Descent Parser for Arithmetic Expressions *)

(** {1 Expression Type} *)

(** The type of arithmetic expressions. *)
type expr =
  | Int of int
  | Add of expr * expr
  | Sub of expr * expr
  | Mul of expr * expr
  | Div of expr * expr

(** {1 Parsing} *)

(** [parse s] parses string [s] into an expression AST.
    
    Supports:
    - Integer literals: ["42"], ["-5"]
    - Addition and subtraction: ["1 + 2"], ["5 - 3"]
    - Multiplication and division: ["2 * 3"], ["6 / 2"]
    - Parentheses for grouping: ["(1 + 2) * 3"]
    - Operator precedence: * and / bind tighter than + and -
    - Whitespace is ignored
    
    @param s the input string
    @return [Ok expr] if parsing succeeds, [Error msg] with error message if it fails
    
    Examples:
    - [parse "42" = Ok (Int 42)]
    - [parse "1 + 2" = Ok (Add (Int 1, Int 2))]
    - [parse "1 + 2 * 3" = Ok (Add (Int 1, Mul (Int 2, Int 3)))]
    - [parse "(1 + 2) * 3" = Ok (Mul (Add (Int 1, Int 2), Int 3))]
    - [parse "1 +" = Error "..."]
*)
val parse : string -> (expr, string) result

