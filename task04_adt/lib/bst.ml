(** Binary Search Tree - Implementation *)

(* Task 4: Algebraic Data Types and Interfaces
 *
 * Implement a Binary Search Tree with:
 * - empty: create an empty tree
 * - insert: add an element maintaining BST property
 * - find: search for an element
 * - to_list: convert to sorted list
 *
 * BST Invariant: For any node with value v:
 * - All values in left subtree < v
 * - All values in right subtree > v
 *)

(** Type definition for binary search tree *)
type 'a tree = Leaf | Node of 'a * 'a tree * 'a tree [@@warning "-37"]
(* Node will be used when you implement the functions *)

(** Empty tree *)
let empty = Leaf

(** Insert an element into the tree *)
let insert _x _tree =
  let rec _insert tree =
    match tree with
    | Leaf -> Node (_x, Leaf, Leaf)
    | Node (value, left, right) -> (
        match compare _x value with
        | 0 -> tree
        | n when n < 0 -> Node (value, _insert left, right)
        | _ -> Node (value, left, _insert right))
  in
  _insert _tree

(** Find an element in the tree *)
let find _x _tree = 
  let rec _find tree =
    match tree with
    | Leaf -> false
    | Node (value, left, right) -> (
        match compare _x value with
        | 0 -> true
        | n when n < 0 -> _find left
        | _ -> _find right)
  in
  _find _tree


(** Convert tree to sorted list (in-order traversal) *)
let rec to_list _tree = match _tree with
  | Leaf -> []
  | Node (value, left, right) -> to_list left @ [value] @ to_list right
