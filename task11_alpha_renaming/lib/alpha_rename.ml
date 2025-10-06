(** Alpha-Renaming and Shadow Elimination - Implementation *)

[@@@warning "-32-27"]  (* Suppress warnings for unused functions/vars in skeleton *)

(* Task 11: Alpha-Renaming and Shadow Elimination
 *
 * Implement:
 * 1. fresh_var - generate fresh variable names
 * 2. lookup_rename - look up variable in renaming environment
 * 3. alpha_rename - rename all variables to eliminate shadowing
 *
 * Key concepts:
 * - Fresh name generation using mutable counter
 * - Renaming environment tracks old -> new name mappings
 * - Let bindings: rename e1 in current env, e2 in extended env
 * - Preserve semantics: eval (alpha_rename e) = eval e
 *)

type expr =
  | Int of int
  | Add of expr * expr
  | Sub of expr * expr
  | Mul of expr * expr
  | Div of expr * expr
  | Var of string
  | Let of string * expr * expr

type rename_env = (string * string) list
type env = (string * int) list

(** Global counter for fresh variable generation *)
let counter = ref 0

(** Reset the counter (for testing) *)
let reset_counter () = counter := 0

(** Generate a fresh variable name *)
let fresh_var _base =
  failwith "TODO: Implement fresh_var"
  (* Hints:
   * - Get current counter value: let n = !counter in
   * - Increment counter: counter := n + 1;
   * - Format name: Printf.sprintf "%s_%d" base n
   * - Return the formatted string
   *)

(** Look up a variable in the renaming environment *)
let lookup_rename _x _env =
  failwith "TODO: Implement lookup_rename (use 'let rec')"
  (* Hints:
   * - Use 'let rec lookup_rename x env = ...' (add the 'rec' keyword)
   * - Pattern match on env
   * - Base case: [] -> x  (not found, return original)
   * - Recursive case: (y, y_new) :: rest ->
   *     if x = y then y_new
   *     else lookup_rename x rest
   * - First match wins (handles shadowing in environment)
   *)

(** Helper: rename expression with given environment *)
let rename_expr _env _e =
  failwith "TODO: Implement rename_expr (use 'let rec')"
  (* Hints:
   * - Use 'let rec rename_expr env e = ...' (add the 'rec' keyword)
   * - Pattern match on e
   * - Int n -> Int n  (unchanged)
   * - Var x -> Var (lookup_rename x env)  (look up and rename)
   * - Add/Sub/Mul/Div: recurse on both operands with same env
   *   Example: Add (e1, e2) -> Add (rename_expr env e1, rename_expr env e2)
   * - Let (x, e1, e2) ->
   *     1. Generate fresh name: let x_fresh = fresh_var x in
   *     2. Rename e1 in CURRENT env: let e1' = rename_expr env e1 in
   *     3. Extend environment: let env' = (x, x_fresh) :: env in
   *     4. Rename e2 in EXTENDED env: let e2' = rename_expr env' e2 in
   *     5. Return: Let (x_fresh, e1', e2')
   * 
   * CRITICAL: Rename e1 with current env, e2 with extended env!
   *)

(** Alpha-rename to eliminate shadowing *)
let alpha_rename e =
  reset_counter ();  (* Reset counter for consistent output *)
  rename_expr [] e

(** Helper: lookup variable in environment *)
let rec lookup x = function
  | [] -> failwith ("Unbound variable: " ^ x)
  | (y, v) :: rest -> if x = y then v else lookup x rest

(** Evaluate expression (for testing) *)
let rec eval env = function
  | Int n -> n
  | Add (e1, e2) -> eval env e1 + eval env e2
  | Sub (e1, e2) -> eval env e1 - eval env e2
  | Mul (e1, e2) -> eval env e1 * eval env e2
  | Div (e1, e2) -> eval env e1 / eval env e2
  | Var x -> lookup x env
  | Let (x, e1, e2) ->
      let v1 = eval env e1 in
      let env' = (x, v1) :: env in
      eval env' e2

(** Convert expression to string *)
let rec expr_to_string = function
  | Int n -> string_of_int n
  | Add (e1, e2) -> Printf.sprintf "(%s + %s)" (expr_to_string e1) (expr_to_string e2)
  | Sub (e1, e2) -> Printf.sprintf "(%s - %s)" (expr_to_string e1) (expr_to_string e2)
  | Mul (e1, e2) -> Printf.sprintf "(%s * %s)" (expr_to_string e1) (expr_to_string e2)
  | Div (e1, e2) -> Printf.sprintf "(%s / %s)" (expr_to_string e1) (expr_to_string e2)
  | Var x -> x
  | Let (x, e1, e2) -> 
      Printf.sprintf "let %s = %s in %s" x (expr_to_string e1) (expr_to_string e2)

