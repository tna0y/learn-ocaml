(** Environment-Based Expression Evaluator - Implementation *)

[@@@warning "-32-27"]  (* Suppress warnings for unused functions/vars in skeleton *)

(* Task 9: Variables and let...in + Environments
 *
 * Implement:
 * 1. lookup - find variable value in environment
 * 2. eval - evaluate expression with environment
 * 3. expr_to_string - convert to string including vars and let
 *
 * Key concepts:
 * - Environment = list of (name, value) pairs
 * - Let extends environment
 * - Shadowing: newer bindings prepend to list
 *)

type expr =
  | Int of int
  | Add of expr * expr
  | Sub of expr * expr
  | Mul of expr * expr
  | Div of expr * expr
  | Var of string
  | Let of string * expr * expr

type env = (string * int) list

(** Look up a variable in the environment *)
let lookup _x _env =
  failwith "TODO: Implement lookup (use 'let rec')"
  (* Hints:
   * - Use 'let rec lookup x env = ...' (add the 'rec' keyword)
   * - Use pattern matching on env
   * - Base case: [] -> failwith ("Unbound variable: " ^ x)
   * - Recursive case: (y, v) :: rest ->
   *     if x = y then v
   *     else lookup x rest
   * - First match wins (handles shadowing)
   *)

(** Evaluate an expression in an environment *)
let eval _env _e =
  failwith "TODO: Implement eval (use 'let rec')"
  (* Hints:
   * - Use 'let rec eval env e = ...' (add the 'rec' keyword)
   * - Pattern match on e
   * - Int n -> n
   * - Add/Sub/Mul/Div: same as before, pass env to recursive calls
   * - Var x -> lookup x env
   * - Let (x, e1, e2) ->
   *     let v1 = eval env e1 in  (* eval e1 in current env *)
   *     let env' = (x, v1) :: env in  (* extend environment *)
   *     eval env' e2  (* eval e2 in extended env *)
   *)

(** Convert expression to string *)
let expr_to_string _e =
  failwith "TODO: Implement expr_to_string (use 'let rec')"
  (* Hints:
   * - Use 'let rec expr_to_string e = ...' (add the 'rec' keyword)
   * - Similar to Task 7, but add cases for:
   * - Var x -> x
   * - Let (x, e1, e2) -> 
   *     Printf.sprintf "let %s = %s in %s" 
   *       x (expr_to_string e1) (expr_to_string e2)
   *)

