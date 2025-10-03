(* REFERENCE SOLUTION - Do not peek until you've tried implementing it yourself! *)

type expr =
  | Int of int
  | Add of expr * expr
  | Sub of expr * expr
  | Mul of expr * expr
  | Div of expr * expr
  | Var of string
  | Let of string * expr * expr

type env = (string * int) list

let rec lookup x = function
  | [] -> failwith ("Unbound variable: " ^ x)
  | (y, v) :: rest ->
      if x = y then v
      else lookup x rest

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

let rec expr_to_string = function
  | Int n -> string_of_int n
  | Add (e1, e2) -> Printf.sprintf "(%s + %s)" (expr_to_string e1) (expr_to_string e2)
  | Sub (e1, e2) -> Printf.sprintf "(%s - %s)" (expr_to_string e1) (expr_to_string e2)
  | Mul (e1, e2) -> Printf.sprintf "(%s * %s)" (expr_to_string e1) (expr_to_string e2)
  | Div (e1, e2) -> Printf.sprintf "(%s / %s)" (expr_to_string e1) (expr_to_string e2)
  | Var x -> x
  | Let (x, e1, e2) ->
      Printf.sprintf "let %s = %s in %s" x (expr_to_string e1) (expr_to_string e2)

