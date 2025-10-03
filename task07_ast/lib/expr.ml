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
let eval _e =
  failwith "TODO: Implement eval (use 'let rec')"
  (* Hints:
   * - Use 'let rec eval e = ...' (add the 'rec' keyword)
   * - Use pattern matching: match e with | Int n -> ... | Add (e1, e2) -> ...
   * - Int n: just return n
   * - Add (e1, e2): return (eval e1) + (eval e2)
   * - Sub (e1, e2): return (eval e1) - (eval e2)
   * - Mul (e1, e2): return (eval e1) * (eval e2)
   * - Div (e1, e2): return (eval e1) / (eval e2)
   * - Very simple recursive function!
   *)

(** Pretty-print an expression *)
let pp_expr _fmt _e =
  failwith "TODO: Implement pp_expr (use 'let rec')"
  (* Hints:
   * - Use 'let rec pp_expr fmt e = ...' (add the 'rec' keyword)
   * - Use Format.fprintf fmt "format" args
   * - Int n: Format.fprintf fmt "%d" n
   * - Add (e1, e2): Format.fprintf fmt "(%a + %a)" pp_expr e1 pp_expr e2
   *   (Note: %a takes a formatter function and a value)
   * - Similarly for Sub, Mul, Div with -, *, / symbols
   * - Parentheses show structure clearly
   *)

(** Convert expression to string *)
let expr_to_string _e =
  failwith "TODO: Implement expr_to_string"
  (* Hints:
   * - Use Format.asprintf "%a" pp_expr e
   * - asprintf formats to a string instead of stdout
   * - Very simple one-liner!
   *)

