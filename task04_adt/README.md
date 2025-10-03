# Task 4: Algebraic Data Types and Interfaces

Welcome to Task 4! You've learned pattern matching on lists—now it's time to define your own data structures. **Algebraic Data Types (ADTs)** are OCaml's way of creating custom types, and they're one of the language's most powerful features.

By the end of this task, you'll understand how to define recursive types, write module interfaces (`.mli` files), and implement a Binary Search Tree.

---

## 🎯 Learning Goals

- Define algebraic data types with `type` keyword
- Understand variant types (sum types)
- Create recursive type definitions
- Write module signatures in `.mli` files
- Understand the benefits of explicit interfaces
- Implement a Binary Search Tree with `insert` and `find`

---

## 📚 Theory: Algebraic Data Types

### The `type` Keyword

Define new types with the `type` keyword:

```ocaml
type color = Red | Green | Blue

type point = { x : float; y : float }

type shape =
  | Circle of float
  | Rectangle of float * float
  | Triangle of point * point * point
```

**Comparison with other languages:**
- **C**: `enum` (but only for simple variants), `struct` (records)
- **Rust**: `enum` (exactly like OCaml variants!), `struct` (records)
- **Haskell**: `data` types (same concept!)
- **Python**: Classes with inheritance (much less powerful)
- **TypeScript**: Union types (similar)

### Variant Types (Sum Types)

Variants let you express "one of several possibilities":

```ocaml
type result =
  | Success of int
  | Failure of string

let process r =
  match r with
  | Success n -> Printf.printf "Got %d\n" n
  | Failure msg -> Printf.printf "Error: %s\n" msg
```

**Why "algebraic"?** Because they combine:
- **Sum types** (variants): "A or B" — `Red | Green | Blue`
- **Product types** (tuples/records): "A and B" — `{ x : int; y : int }`

### Recursive Types

Types can reference themselves:

```ocaml
type int_tree =
  | Leaf
  | Node of int * int_tree * int_tree
```

This defines a binary tree! Each node has:
- An integer value
- A left subtree
- A right subtree

**Pattern matching on trees:**
```ocaml
let rec size tree =
  match tree with
  | Leaf -> 0
  | Node (_, left, right) -> 1 + size left + size right
```

### Polymorphic Types

Types can be generic with type parameters:

```ocaml
type 'a tree =
  | Leaf
  | Node of 'a * 'a tree * 'a tree
```

The `'a` is a type variable (like `T` in C++ templates or generics in Rust/Java).

**Usage:**
```ocaml
let int_tree : int tree = Node (5, Leaf, Leaf)
let string_tree : string tree = Node ("hello", Leaf, Leaf)
```

**Comparison:**
- **C++**: `template<typename T>`
- **Rust**: `enum Tree<T>`
- **Java**: `class Tree<T>`
- **Haskell**: `data Tree a`
- **OCaml**: `type 'a tree`

### Module Interfaces: `.mli` Files

An `.mli` file is like a header file in C—it specifies what's publicly visible from a module.

**`bst.mli` (interface):**
```ocaml
type 'a tree

val empty : 'a tree
val insert : 'a -> 'a tree -> 'a tree
val find : 'a -> 'a tree -> bool
```

**`bst.ml` (implementation):**
```ocaml
type 'a tree =
  | Leaf
  | Node of 'a * 'a tree * 'a tree

let empty = Leaf

let rec insert x tree = ...
let rec find x tree = ...
```

**Notice:** The `.mli` file says `type 'a tree` without revealing the definition. This is **abstract**—users can't directly construct trees, they must use `empty` and `insert`. This is **encapsulation**.

**Benefits:**
1. **Encapsulation**: Hide implementation details
2. **Documentation**: Interface is a contract
3. **Type safety**: Can't misuse internal representation
4. **Refactoring**: Change implementation without changing interface

**Comparison:**
- **C**: `.h` header files
- **C++**: `.hpp` headers, abstract classes
- **Rust**: `pub` visibility, traits
- **Java**: Interfaces
- **OCaml**: `.mli` files

---

## 📝 Your Task

Implement a **Binary Search Tree** in `lib/bst.ml` following the interface in `lib/bst.mli`.

### Binary Search Tree Properties

A BST maintains this invariant:
- For any node with value `v`:
  - All values in the left subtree are < `v`
  - All values in the right subtree are > `v`

This enables O(log n) search in balanced trees.

### Functions to Implement

#### 1. `empty : 'a tree`

An empty tree.

#### 2. `insert : 'a -> 'a tree -> 'a tree`

Insert a value into the tree, maintaining BST property.

**Algorithm:**
- If tree is empty, create a single-node tree
- If value < node's value, insert into left subtree
- If value > node's value, insert into right subtree
- If value = node's value, return tree unchanged (no duplicates)

**Example:**
```ocaml
let tree = empty |> insert 5 |> insert 3 |> insert 7 |> insert 1
(* Tree structure:
      5
     / \
    3   7
   /
  1
*)
```

#### 3. `find : 'a -> 'a tree -> bool`

Check if a value exists in the tree.

**Algorithm:**
- If tree is empty, return false
- If value = node's value, return true
- If value < node's value, search left subtree
- If value > node's value, search right subtree

#### 4. `to_list : 'a tree -> 'a list`

Convert tree to a sorted list (in-order traversal).

**Algorithm:**
- For Leaf: return []
- For Node (v, left, right): `to_list left @ [v] @ to_list right`

(Note: `@` is list concatenation, but it's inefficient. For bonus points, make this tail-recursive!)

---

## 🏗️ Building and Running

```bash
dune build
dune test
dune utop
```

In utop:
```ocaml
open Bst;;

let tree = empty 
  |> insert 5 
  |> insert 3 
  |> insert 7 
  |> insert 1 
  |> insert 9;;

find 3 tree;;   (* true *)
find 4 tree;;   (* false *)
to_list tree;;  (* [1; 3; 5; 7; 9] *)
```

---

## 💡 Common Mistakes

### Mistake 1: Exposing Type Definition in `.mli`

```ocaml
(* BAD - reveals implementation *)
type 'a tree = Leaf | Node of 'a * 'a tree * 'a tree

(* GOOD - keeps it abstract *)
type 'a tree
```

### Mistake 2: Not Maintaining BST Property

```ocaml
(* WRONG - always inserts right *)
let rec insert x = function
  | Leaf -> Node (x, Leaf, Leaf)
  | Node (v, left, right) -> Node (v, left, insert x right)

(* RIGHT - compares values *)
let rec insert x = function
  | Leaf -> Node (x, Leaf, Leaf)
  | Node (v, left, right) ->
      if x < v then Node (v, insert x left, right)
      else if x > v then Node (v, left, insert x right)
      else Node (v, left, right)  (* x = v, no change *)
```

### Mistake 3: Inefficient List Concatenation

```ocaml
(* Works but O(n²) due to @ *)
let rec to_list = function
  | Leaf -> []
  | Node (v, left, right) -> to_list left @ [v] @ to_list right

(* Better: use accumulator (O(n)) *)
let to_list tree =
  let rec loop acc = function
    | Leaf -> acc
    | Node (v, left, right) -> loop (v :: loop acc right) left
  in
  loop [] tree
```

---

## 🎓 Going Deeper

### Why Abstract Types?

```ocaml
(* If type is abstract in .mli: *)
let tree = empty |> insert 5  (* ONLY way to create a tree *)

(* If type is exposed: *)
let tree = Leaf  (* Can bypass our API! *)
let broken = Node (5, Leaf, Node (3, Leaf, Leaf))  (* Violates BST property! *)
```

Abstract types enforce that users can only create valid structures.

### Type Parameters: Invariant vs Covariant

OCaml's `'a tree` is **invariant**: `int tree` and `float tree` are completely different types.

**Comparison:**
- **OCaml**: Invariant by default (safe)
- **Java**: Covariant arrays (unsafe!), invariant generics
- **Rust**: Invariant (safe)

---

## 🚀 Ready to Code!

Open `lib/bst.ml` and implement your Binary Search Tree. Remember to maintain the BST invariant!

Good luck! 🎉

