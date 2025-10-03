# Task 7: Arithmetic AST + Pretty-Print

Welcome to Module B! You've mastered OCaml fundamentals—now it's time to build compiler components. This module focuses on **Abstract Syntax Trees (ASTs)**, the central data structure in any compiler or interpreter.

By the end of this task, you'll understand how to represent code as tree structures, evaluate expressions by traversing trees, and pretty-print ASTs back to readable text.

---

## 🎯 Learning Goals

- Understand Abstract Syntax Trees as the compiler's source of truth
- Define expression types using algebraic data types
- Implement recursive tree traversal for evaluation
- Master the `Format` module for pretty-printing
- Learn the difference between concrete syntax and abstract syntax

---

## 📚 Theory: Abstract Syntax Trees

### What is an AST?

An **Abstract Syntax Tree** represents the structure of code without worrying about textual details (spaces, parentheses, etc.).

**Example:** The expression `1 + 2 * 3` becomes:

```
    +
   / \
  1   *
     / \
    2   3
```

**Why "abstract"?** It abstracts away syntactic details:
- `1+2` and `1 + 2` have the same AST
- `(1+2)` and `1+2` have the same AST (unnecessary parens removed)
- Focus is on *meaning*, not *appearance*

**Comparison with other representations:**
- **String**: `"1 + 2 * 3"` — hard to analyze
- **Tokens**: `[Int 1, Plus, Int 2, Times, Int 3]` — linear, no structure
- **AST**: `Add(Int 1, Mul(Int 2, Int 3))` — tree structure, easy to process

### Defining an Expression AST

```ocaml
type expr =
  | Int of int
  | Add of expr * expr
  | Sub of expr * expr
  | Mul of expr * expr
  | Div of expr * expr
```

This is a **recursive type**: expressions contain sub-expressions!

**Examples:**
```ocaml
(* 42 *)
let e1 = Int 42

(* 1 + 2 *)
let e2 = Add (Int 1, Int 2)

(* (1 + 2) * 3 *)
let e3 = Mul (Add (Int 1, Int 2), Int 3)

(* 1 + 2 * 3 — note the structure reflects precedence! *)
let e4 = Add (Int 1, Mul (Int 2, Int 3))
```

**Key insight:** The tree structure *encodes* operator precedence. No need for precedence rules during evaluation!

### Evaluating an AST

Evaluation is **structural recursion** on the tree:

```ocaml
let rec eval = function
  | Int n -> n
  | Add (e1, e2) -> eval e1 + eval e2
  | Sub (e1, e2) -> eval e1 - eval e2
  | Mul (e1, e2) -> eval e1 * eval e2
  | Div (e1, e2) -> eval e1 / eval e2
```

**This is the entire interpreter!** Each constructor maps to an operation.

**Comparison with other languages:**
- **C/Java**: Would need visitor pattern or switch statements
- **Python**: Would use isinstance checks
- **Rust**: Pattern matching (similar to OCaml!)
- **Haskell**: Pattern matching (identical!)

### Pretty-Printing with Format

The `Format` module provides sophisticated text formatting with automatic line breaking.

**Basic usage:**
```ocaml
Format.printf "Hello, %s!\n" "World"
Format.printf "Number: %d\n" 42
```

**Format specifiers:**
- `%d` — integer
- `%s` — string
- `%f` — float
- `%a` — custom printer

**Why use Format instead of string concatenation?**

```ocaml
(* String concatenation — manual, error-prone *)
let bad_print e = "(" ^ string_of_int e ^ ")"

(* Format module — clean, composable *)
let good_print fmt e = Format.fprintf fmt "(%d)" e
```

**Benefits:**
- Automatic buffer management
- Better performance (no temporary strings)
- Composable formatters
- Can redirect output (string, file, stdout)

### Pretty-Printing Expressions

Goal: Convert AST back to readable text.

**Naive approach:**
```ocaml
let rec to_string = function
  | Int n -> string_of_int n
  | Add (e1, e2) -> "(" ^ to_string e1 ^ " + " ^ to_string e2 ^ ")"
  | (* ... *)
```

Problems:
- Too many parentheses: `((1) + (2))`
- Many temporary strings (inefficient)

**Better approach with Format:**
```ocaml
let rec pp_expr fmt = function
  | Int n -> Format.fprintf fmt "%d" n
  | Add (e1, e2) -> Format.fprintf fmt "(%a + %a)" pp_expr e1 pp_expr e2
  | (* ... *)
```

The `%a` takes a formatter function (`pp_expr`) and a value!

**Converting to string:**
```ocaml
let expr_to_string e =
  Format.asprintf "%a" pp_expr e
```

`Format.asprintf` formats to a string instead of stdout.

---

## 📝 Your Task

Implement an arithmetic expression evaluator and pretty-printer in `lib/expr.ml`.

### 1. Type Definition

Already provided:
```ocaml
type expr =
  | Int of int
  | Add of expr * expr
  | Sub of expr * expr
  | Mul of expr * expr
  | Div of expr * expr
```

### 2. `eval : expr -> int`

Evaluate an expression to an integer.

**Examples:**
```ocaml
eval (Int 42) = 42
eval (Add (Int 1, Int 2)) = 3
eval (Mul (Add (Int 1, Int 2), Int 3)) = 9
eval (Sub (Int 10, Div (Int 8, Int 2))) = 6
```

**Hint:** Use pattern matching. This is very short!

### 3. `pp_expr : Format.formatter -> expr -> unit`

Pretty-print an expression to a formatter.

**Examples:**
```ocaml
pp_expr fmt (Int 42)  (* prints: 42 *)
pp_expr fmt (Add (Int 1, Int 2))  (* prints: (1 + 2) *)
pp_expr fmt (Mul (Add (Int 1, Int 2), Int 3))  (* prints: ((1 + 2) * 3) *)
```

**Hint:** Use `Format.fprintf` with `%a` for recursive calls.

### 4. `expr_to_string : expr -> string`

Convert expression to string (convenience wrapper).

**Examples:**
```ocaml
expr_to_string (Int 42) = "42"
expr_to_string (Add (Int 1, Int 2)) = "(1 + 2)"
```

**Hint:** Use `Format.asprintf "%a" pp_expr e`

---

## 🏗️ Building and Running

```bash
dune build
dune test
dune utop
```

In utop:
```ocaml
open Expr;;

let e = Add (Int 1, Mul (Int 2, Int 3));;
eval e;;  (* 7 *)
expr_to_string e;;  (* "(1 + (2 * 3))" *)

let complex = 
  Div (
    Add (Int 10, Int 5),
    Sub (Int 5, Int 2)
  );;
  
eval complex;;  (* 5 *)
expr_to_string complex;;
```

---

## 💡 Common Mistakes

### Mistake 1: Confusing Operator Precedence in AST

```ocaml
(* WRONG — this represents (1 + 2) * 3, not 1 + (2 * 3) *)
let bad = Mul (Add (Int 1, Int 2), Int 3)

(* RIGHT — multiplication binds tighter *)
let good = Add (Int 1, Mul (Int 2, Int 3))
```

The AST structure *is* the precedence!

### Mistake 2: String Concatenation Instead of Format

```ocaml
(* BAD — inefficient, many temp strings *)
let rec bad_print = function
  | Int n -> string_of_int n
  | Add (e1, e2) -> 
      "(" ^ bad_print e1 ^ " + " ^ bad_print e2 ^ ")"

(* GOOD — efficient, no temp strings *)
let rec good_print fmt = function
  | Int n -> Format.fprintf fmt "%d" n
  | Add (e1, e2) -> 
      Format.fprintf fmt "(%a + %a)" good_print e1 good_print e2
```

### Mistake 3: Division by Zero

```ocaml
(* Current eval will crash on division by zero *)
eval (Div (Int 1, Int 0))  (* Exception! *)

(* For now, let it crash. We'll handle errors properly in future tasks. *)
```

### Mistake 4: Wrong Format Specifier

```ocaml
(* WRONG *)
Format.fprintf fmt "%s" 42  (* Type error! %s is for strings *)

(* RIGHT *)
Format.fprintf fmt "%d" 42  (* %d is for integers *)
```

---

## 🎓 Going Deeper

### Why ASTs are Central to Compilers

Every compiler/interpreter has this pipeline:

```
Source Code → Lexer → Parser → AST → Analysis → Transformation → Code Gen
```

The AST is the **central representation**:
- All analyses work on ASTs
- All optimizations transform ASTs
- Code generation consumes ASTs

### Concrete vs Abstract Syntax

**Concrete syntax**: What the user writes
```
1 + 2 * 3
1+2*3
(1 + (2 * 3))
```

**Abstract syntax**: What the compiler sees
```ocaml
Add (Int 1, Mul (Int 2, Int 3))
```

All three concrete forms have the same abstract form!

### The Format Module's Power

Format can do much more:
- **Boxes**: Automatic line wrapping
- **Break hints**: Control where to break lines
- **Tags**: Semantic markup

Example with boxes:
```ocaml
Format.printf "@[<hov 2>{ @[<hov 2>x =@ %d;@]@ @[<hov 2>y =@ %d@] }@]" 1 2
```

This automatically formats nicely even with long values!

### Pattern Matching is Tree Traversal

Every pattern match on an AST is a tree traversal:
```ocaml
let rec depth = function
  | Int _ -> 0
  | Add (e1, e2) | Sub (e1, e2) | Mul (e1, e2) | Div (e1, e2) ->
      1 + max (depth e1) (depth e2)
```

---

## 🚀 Ready to Code!

Open `lib/expr.ml` and implement your expression evaluator and pretty-printer. The AST type is already defined—you just need to implement the three functions.

Remember:
- Pattern matching makes evaluation trivial
- `Format.fprintf` with `%a` for recursive printing
- Test with increasingly complex expressions

Good luck! 🎉

