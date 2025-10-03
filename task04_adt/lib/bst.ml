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
type 'a tree =
  | Leaf
  | Node of 'a * 'a tree * 'a tree
[@@warning "-37"]  (* Node will be used when you implement the functions *)

(** Empty tree *)
let empty = Leaf

(** Insert an element into the tree *)
let insert _x _tree =
  failwith "TODO: Implement insert (use 'let rec')"
  (* Hints:
   * - Match on tree:
   *     | Leaf -> create a new Node with x
   *     | Node (v, left, right) -> compare x with v
   * - If x < v: insert into left subtree
   * - If x > v: insert into right subtree
   * - If x = v: return tree unchanged (no duplicates)
   * - Use: Node (v, new_left, right) to create updated node
   *)

(** Find an element in the tree *)
let find _x _tree =
  failwith "TODO: Implement find (use 'let rec')"
  (* Hints:
   * - Match on tree:
   *     | Leaf -> false (not found)
   *     | Node (v, left, right) -> compare x with v
   * - If x = v: return true
   * - If x < v: search in left subtree
   * - If x > v: search in right subtree
   *)

(** Convert tree to sorted list (in-order traversal) *)
let to_list _tree =
  failwith "TODO: Implement to_list (use 'let rec')"
  (* Hints:
   * - Match on tree:
   *     | Leaf -> []
   *     | Node (v, left, right) -> combine left subtree, v, right subtree
   * - Use @ to concatenate lists: to_list left @ [v] @ to_list right
   * - This gives you elements in sorted order!
   * 
   * Bonus: Can you make this tail-recursive with an accumulator?
   *)

