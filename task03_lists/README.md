# Task 3: Pattern Matching and Lists

Welcome to Task 3! You've mastered recursion—now it's time to combine it with OCaml's most powerful feature: **pattern matching**. Together with lists, pattern matching forms the backbone of functional programming style in OCaml.

By the end of this task, you'll understand how to process lists recursively, implement fundamental higher-order functions, and use the pipeline operator for clean, readable code.

---

## 🎯 Learning Goals

- Master pattern matching with `match ... with`
- Understand OCaml's list data structure and syntax
- Implement `map`, `filter`, and `fold_left` from scratch
- Learn the pipeline operator `|>` for function composition
- Write tail-recursive list processing functions
- Understand higher-order functions (functions that take functions as arguments)

---

## 📚 Theory: Pattern Matching and Lists

### Lists in OCaml

A list in OCaml is either:
- `[]` — the empty list
- `head :: tail` — a head element cons-ed onto a tail list

**Examples:**
```ocaml
let empty = []
let one = [1]  (* same as 1 :: [] *)
let three = [1; 2; 3]  (* same as 1 :: 2 :: 3 :: [] *)
```

**Note the semicolons!** OCaml uses `;` to separate list elements, not commas (which are for tuples).

**Comparison with other languages:**
- **Python**: `[1, 2, 3]` — dynamic array
- **Rust**: `vec![1, 2, 3]` — growable vector, or `list!` macro for linked lists
- **Haskell**: `[1, 2, 3]` — linked list (exactly like OCaml!)
- **C**: Arrays or linked lists (manual memory management)

OCaml lists are:
- **Immutable** — cannot be modified after creation
- **Singly-linked** — efficient cons (prepend), inefficient random access
- **Homogeneous** — all elements must have the same type

### The Cons Operator `::`

The `::` operator prepends an element to a list:

```ocaml
let list = 1 :: [2; 3]  (* result: [1; 2; 3] *)
let list2 = 0 :: list    (* result: [0; 1; 2; 3] *)
```

**Comparison:**
- **Haskell**: `1 : [2, 3]` (same concept, different symbol)
- **Python**: `[1] + [2, 3]` (but this copies the list!)
- **Rust**: `vec.push(1)` (mutable operation on Vec)

### Pattern Matching: The Heart of OCaml

Pattern matching is like a supercharged `switch` statement that can destructure data:

```ocaml
match some_list with
| [] -> "empty"
| [x] -> "one element"
| x :: xs -> "at least one element"
```

**What's happening here?**
- `[]` matches the empty list
- `[x]` matches a list with exactly one element (binds it to `x`)
- `x :: xs` matches any non-empty list (binds head to `x`, tail to `xs`)

**Comparison with other languages:**
- **C**: `switch` only works with integers/enums, no destructuring
- **Python**: Pattern matching added in 3.10, but not as powerful
- **Rust**: `match` with patterns (very similar to OCaml!)
- **Haskell**: Pattern matching (identical concept!)

### The `match` Expression

```ocaml
let rec length list =
  match list with
  | [] -> 0
  | _ :: tail -> 1 + length tail
```

**Structure:**
```ocaml
match expression with
| pattern1 -> result1
| pattern2 -> result2
| pattern3 -> result3
```

**Important:**
- Patterns are tried **top to bottom**
- First match wins
- OCaml warns you about non-exhaustive patterns (missing cases)
- The `_` wildcard matches anything (like `default` in C)

### Recursive List Processing

The standard pattern for processing lists:

```ocaml
let rec process list =
  match list with
  | [] -> base_case_result
  | head :: tail -> 
      combine head (process tail)
```

**Example: Sum a list**
```ocaml
let rec sum list =
  match list with
  | [] -> 0
  | x :: xs -> x + sum xs
```

### Higher-Order Functions

Functions that take other functions as parameters:

```ocaml
let rec map f list =
  match list with
  | [] -> []
  | x :: xs -> f x :: map f xs

(* Usage *)
let doubled = map (fun x -> x * 2) [1; 2; 3]
(* result: [2; 4; 6] *)
```

The `fun x -> ...` syntax creates an anonymous function (lambda).

**Comparison:**
- **Python**: `lambda x: x * 2` or `def f(x): return x * 2`
- **Rust**: `|x| x * 2`
- **C**: Function pointers (much more verbose!)
- **JavaScript**: `x => x * 2`
- **OCaml**: `fun x -> x * 2`

### The Pipeline Operator `|>`

The `|>` operator passes a value to a function:

```ocaml
x |> f  (* same as: f x *)
x |> f |> g  (* same as: g (f x) *)
```

**Why is this useful?** It makes function composition read left-to-right:

```ocaml
(* Without pipeline *)
let result = List.filter is_even (List.map double (List.filter positive numbers))

(* With pipeline — much clearer! *)
let result = 
  numbers
  |> List.filter positive
  |> List.map double
  |> List.filter is_even
```

**Comparison:**
- **Rust**: `.iter().filter().map()` method chaining
- **Haskell**: `numbers & filter positive & map double` (with `&` from Data.Function)
- **Unix shell**: `cat file | grep pattern | sort` (same philosophy!)
- **F#**: Uses `|>` (inspired OCaml!)

### Tail Recursion with Lists

Just like with numbers, list processing should be tail-recursive for large lists:

```ocaml
(* NOT tail-recursive — cons happens after recursive call *)
let rec map f list =
  match list with
  | [] -> []
  | x :: xs -> f x :: map f xs  (* pending :: operation *)

(* Tail-recursive with accumulator *)
let map f list =
  let rec loop acc = function
    | [] -> List.rev acc  (* reverse accumulated result *)
    | x :: xs -> loop (f x :: acc) xs
  in
  loop [] list
```

**The trick:** Build the result in reverse using an accumulator, then reverse at the end.

---

## 📝 Your Task

Implement the following functions in `lib/list_ops.ml`. All must be **tail-recursive**.

### 1. `map : ('a -> 'b) -> 'a list -> 'b list`

Apply a function to every element of a list.

**Examples:**
```ocaml
map (fun x -> x * 2) [1; 2; 3] = [2; 4; 6]
map String.length ["hi"; "hello"] = [2; 5]
```

### 2. `filter : ('a -> bool) -> 'a list -> 'a list`

Keep only elements that satisfy a predicate.

**Examples:**
```ocaml
filter (fun x -> x > 0) [-1; 0; 1; 2] = [1; 2]
filter (fun x -> x mod 2 = 0) [1; 2; 3; 4] = [2; 4]
```

### 3. `fold_left : ('acc -> 'a -> 'acc) -> 'acc -> 'a list -> 'acc`

Reduce a list to a single value by processing elements left-to-right.

**Examples:**
```ocaml
fold_left (+) 0 [1; 2; 3; 4] = 10
fold_left (fun acc x -> acc ^ x) "" ["a"; "b"; "c"] = "abc"
```

**How fold_left works:**
```
fold_left f init [x1; x2; x3]
= f (f (f init x1) x2) x3
```

---

## 🏗️ Building and Running

```bash
dune build     # Build
dune test      # Run tests
dune utop      # Interactive REPL
```

In utop:
```ocaml
open List_ops;;
map (fun x -> x * 2) [1; 2; 3];;
filter (fun x -> x > 0) [-2; -1; 0; 1; 2];;
fold_left (+) 0 [1; 2; 3; 4];;

(* Pipeline style *)
[1; 2; 3; 4; 5]
|> filter (fun x -> x mod 2 = 0)
|> map (fun x -> x * x);;
```

---

## 💡 Common Mistakes

### Mistake 1: Using Commas Instead of Semicolons

```ocaml
(* WRONG *)
let list = [1, 2, 3]  (* This is a list with ONE element: a tuple *)

(* RIGHT *)
let list = [1; 2; 3]  (* This is a list with three elements *)
```

### Mistake 2: Forgetting List.rev in Tail-Recursive Functions

```ocaml
(* WRONG — result is reversed *)
let map f list =
  let rec loop acc = function
    | [] -> acc  (* Missing List.rev! *)
    | x :: xs -> loop (f x :: acc) xs
  in loop [] list

(* RIGHT *)
let map f list =
  let rec loop acc = function
    | [] -> List.rev acc
    | x :: xs -> loop (f x :: acc) xs
  in loop [] list
```

### Mistake 3: Non-Exhaustive Patterns

```ocaml
(* OCaml warns about this *)
let rec head list =
  match list with
  | x :: _ -> x
  (* Missing [] case! *)
```

### Mistake 4: Wrong fold_left Parameter Order

```ocaml
(* The function takes (accumulator, element), in that order *)
fold_left (fun acc x -> acc + x) 0 [1; 2; 3]  (* RIGHT *)
fold_left (fun x acc -> acc + x) 0 [1; 2; 3]  (* WRONG — confusing! *)
```

---

## 🎓 Going Deeper

### Why Immutable Lists?

Immutability enables:
- **Safe sharing**: Multiple variables can reference the same list tail
- **Easier reasoning**: No spooky mutations
- **Persistent data structures**: Old versions remain accessible

```ocaml
let list1 = [2; 3; 4]
let list2 = 1 :: list1  (* list1 and list2 share [2; 3; 4] *)
(* No copying needed — safe because lists are immutable *)
```

### The Power of Higher-Order Functions

Instead of writing loops, you compose operations:

```ocaml
(* Get sum of squares of even numbers *)
let result =
  [1; 2; 3; 4; 5; 6]
  |> filter (fun x -> x mod 2 = 0)  (* [2; 4; 6] *)
  |> map (fun x -> x * x)            (* [4; 16; 36] *)
  |> fold_left (+) 0                 (* 56 *)
```

This style is declarative ("what to do") vs imperative ("how to do it").

---

## ✅ Checklist

- [ ] Understand list syntax: `[]`, `::`, `[x; y; z]`
- [ ] Can pattern match on lists
- [ ] Understand higher-order functions
- [ ] Implement `map`, `filter`, `fold_left` tail-recursively
- [ ] Use the pipeline operator `|>`
- [ ] Know when to use `List.rev` with accumulators

---

## 🚀 Ready to Code!

Open `lib/list_ops.ml` and implement your solutions. Remember to use tail recursion with accumulators and `List.rev`!

Good luck! 🎉

