(** Arithmetic Expression AST - Implementation *)

(* Task 7: Arithmetic AST + Pretty-Print
 *
 * Implement:
 * 1. eval - evaluate expression to integer
 * 2. pp_expr - pretty-print expression using Format module
 * 3. expr_to_string - convert expression to string
 *
 * Key concepts:
 * - AST = tree representation of code
 * - Pattern matching on recursive types
 * - Format module for clean printing
 *)

(** Expression type *)
type expr =
  | Int of int
  | Add of expr * expr
  | Sub of expr * expr
  | Mul of expr * expr
  | Div of expr * expr

(** Evaluate an expression *)
let rec eval _e = match _e with
| Int (n) -> n
| Add (e1, e2) -> eval e1 + eval e2
| Sub (e1, e2) -> eval e1 - eval e2
| Mul (e1, e2) -> eval e1 * eval e2
| Div (e1, e2) -> eval e1 / eval e2

(** Pretty-print an expression *)
let rec pp_expr _fmt = function
  | Int n -> Format.fprintf _fmt "%d" n
  | Add (e1, e2) -> Format.fprintf _fmt "(%a + %a)" pp_expr e1 pp_expr e2
  | Sub (e1, e2) -> Format.fprintf _fmt "(%a - %a)" pp_expr e1 pp_expr e2
  | Mul (e1, e2) -> Format.fprintf _fmt "(%a * %a)" pp_expr e1 pp_expr e2
  | Div (e1, e2) -> Format.fprintf _fmt "(%a / %a)" pp_expr e1 pp_expr e2

(** Convert expression to string *)
let expr_to_string _e =
  Format.asprintf "%a" pp_expr _e


