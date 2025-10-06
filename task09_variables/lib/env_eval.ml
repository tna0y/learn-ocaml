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
  let rec loop _x _menv = match _menv with
  | (k, v) :: xs -> if k = _x then v else loop _x xs
  | [] -> failwith ("Unbound variable: " ^ _x)
  in 
  loop _x _env

(** Evaluate an expression in an environment *)
let rec eval _env = function
| Int (n) -> n
| Add (e1, e2) -> (eval _env e1) + (eval _env e2) 
| Sub (e1, e2) -> (eval _env e1) - (eval _env e2) 
| Mul (e1, e2) -> (eval _env e1) * (eval _env e2)
| Div (e1, e2) -> (eval _env e1) / (eval _env e2) 
| Var (key) -> lookup key _env
| Let (key, val_expr, subst_expr) -> let nextenv = ((key, eval _env val_expr) :: _env) in eval nextenv subst_expr
  

(** Convert expression to string *)
let rec expr_to_string = function
  | Int (n) -> string_of_int n
  | Sub (e1, e2) -> "(" ^ (expr_to_string e1) ^ " - " ^ (expr_to_string e2) ^ ")" 
  | Add (e1, e2) -> "(" ^ (expr_to_string e1) ^ " + " ^ (expr_to_string e2) ^ ")" 
  | Mul (e1, e2) -> "(" ^ (expr_to_string e1) ^ " * " ^ (expr_to_string e2) ^ ")"
  | Div (e1, e2) -> "(" ^ (expr_to_string e1) ^ " / " ^ (expr_to_string e2) ^ ")" 
  | Var (key) -> key
  | Let (key, val_expr, subst_expr) -> "let " ^ key ^ " = " ^ expr_to_string val_expr ^ " in " ^ expr_to_string subst_expr
    

