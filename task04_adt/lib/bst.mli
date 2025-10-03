(** Binary Search Tree Module *)

(** The type of binary search trees containing elements of type ['a].
    The type definition is kept abstract to maintain BST invariants. *)
type 'a tree

(** {1 Construction} *)

(** [empty] is the empty tree. *)
val empty : 'a tree

(** [insert x t] inserts element [x] into tree [t], maintaining BST property.
    If [x] is already in the tree, returns the tree unchanged.
    
    @param x the element to insert
    @param t the tree
    @return a new tree with [x] inserted *)
val insert : 'a -> 'a tree -> 'a tree

(** {1 Queries} *)

(** [find x t] checks if element [x] exists in tree [t].
    
    @param x the element to search for
    @param t the tree to search in
    @return [true] if [x] is in [t], [false] otherwise *)
val find : 'a -> 'a tree -> bool

(** [to_list t] converts tree [t] to a sorted list (in-order traversal).
    
    @param t the tree
    @return a list of all elements in [t] in ascending order *)
val to_list : 'a tree -> 'a list

