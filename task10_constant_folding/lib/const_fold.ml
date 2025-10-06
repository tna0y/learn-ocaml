(** Constant Folding and Algebraic Simplifications - Implementation *)

[@@@warning "-32-27"]  (* Suppress warnings for unused functions/vars in skeleton *)

(* Task 10: Constant Folding and Algebraic Simplifications
 *
 * Implement:
 * 1. const_fold - transform AST applying constant folding and algebraic simplifications
 *
 * Key concepts:
 * - AST transformation = expr -> expr
 * - Preserve semantics: eval (const_fold e) = eval e
 * - Structural recursion: transform children first, then apply rules
 * - Immutability: create new trees, don't modify old ones
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

(** Constant folding and algebraic simplifications *)
let const_fold _e =
  failwith "TODO: Implement const_fold (use 'let rec')"
  (* Hints:
   * - Use 'let rec const_fold e = ...' (add the 'rec' keyword)
   * - Pattern match on e
   * - For Int and Var: return unchanged
   * - For binary operations (Add/Sub/Mul/Div):
   *   1. Recurse first: let e1' = const_fold e1 in
   *                      let e2' = const_fold e2 in
   *   2. Pattern match on (e1', e2'):
   *      - (Int a, Int b) -> fold the operation (e.g., Int (a + b))
   *      - Apply algebraic laws (e.g., x + 0 = x)
   *      - Otherwise: rebuild (e.g., Add (e1', e2'))
   * 
   * Example for Add:
   *   | Add (e1, e2) ->
   *       let e1' = const_fold e1 in
   *       let e2' = const_fold e2 in
   *       match (e1', e2') with
   *       | (Int a, Int b) -> Int (a + b)   (* Constant fold *)
   *       | (e, Int 0) -> e                  (* x + 0 = x *)
   *       | (Int 0, e) -> e                  (* 0 + x = x *)
   *       | _ -> Add (e1', e2')             (* Keep as is *)
   * 
   * Algebraic laws to implement:
   * Addition:
   *   - x + 0 = x, 0 + x = x
   * Subtraction:
   *   - x - 0 = x
   * Multiplication:
   *   - x * 0 = 0, 0 * x = 0
   *   - x * 1 = x, 1 * x = x
   * Division:
   *   - x / 1 = x
   * 
   * For Let:
   *   - Let (x, e1, e2) -> Let (x, const_fold e1, const_fold e2)
   *)

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

