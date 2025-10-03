(* REFERENCE SOLUTION - Do not peek until you've tried implementing it yourself! *)

type expr =
  | Int of int
  | Add of expr * expr
  | Sub of expr * expr
  | Mul of expr * expr
  | Div of expr * expr

let rec eval = function
  | Int n -> n
  | Add (e1, e2) -> eval e1 + eval e2
  | Sub (e1, e2) -> eval e1 - eval e2
  | Mul (e1, e2) -> eval e1 * eval e2
  | Div (e1, e2) -> eval e1 / eval e2

let rec pp_expr fmt = function
  | Int n -> Format.fprintf fmt "%d" n
  | Add (e1, e2) -> Format.fprintf fmt "(%a + %a)" pp_expr e1 pp_expr e2
  | Sub (e1, e2) -> Format.fprintf fmt "(%a - %a)" pp_expr e1 pp_expr e2
  | Mul (e1, e2) -> Format.fprintf fmt "(%a * %a)" pp_expr e1 pp_expr e2
  | Div (e1, e2) -> Format.fprintf fmt "(%a / %a)" pp_expr e1 pp_expr e2

let expr_to_string e =
  Format.asprintf "%a" pp_expr e

