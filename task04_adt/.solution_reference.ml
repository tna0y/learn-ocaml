(* REFERENCE SOLUTION - Do not peek until you've tried implementing it yourself! *)

type 'a tree =
  | Leaf
  | Node of 'a * 'a tree * 'a tree

let empty = Leaf

let rec insert x = function
  | Leaf -> Node (x, Leaf, Leaf)
  | Node (v, left, right) as node ->
      if x < v then Node (v, insert x left, right)
      else if x > v then Node (v, left, insert x right)
      else node  (* x = v, no change *)

let rec find x = function
  | Leaf -> false
  | Node (v, left, right) ->
      if x = v then true
      else if x < v then find x left
      else find x right

(* Simple version - works but not tail-recursive *)
let rec to_list = function
  | Leaf -> []
  | Node (v, left, right) -> to_list left @ [v] @ to_list right

(* Tail-recursive version with accumulator *)
(* let to_list tree =
  let rec loop acc = function
    | Leaf -> acc
    | Node (v, left, right) -> 
        loop (v :: loop acc right) left
  in
  loop [] tree
*)

