# Task 9: Variables and `let...in` + Environments

Welcome to Task 9, the final task in Module B! You've learned to build and parse ASTs—now it's time to add **variables** and **scoping**. This task introduces the environment model of evaluation, a fundamental concept in interpreters and compilers.

By the end of this task, you'll understand how variable bindings work, how to implement scoping, and how environments track variable values during evaluation.

---

## 🎯 Learning Goals

- Extend ASTs with variables and let bindings
- Understand the environment model of evaluation
- Implement variable lookup in environments
- Handle variable scoping correctly
- Understand shadowing and scope rules

---

## 📚 Theory: Variables and Environments

### Extending the AST

Previously our expressions were just arithmetic. Now we add:

```ocaml
type expr =
  | Int of int
  | Add of expr * expr
  | Sub of expr * expr
  | Mul of expr * expr
  | Div of expr * expr
  | Var of string              (* NEW: variable reference *)
  | Let of string * expr * expr  (* NEW: let x = e1 in e2 *)
```

**Examples:**
```ocaml
(* let x = 5 in x + 3 *)
Let ("x", Int 5, Add (Var "x", Int 3))

(* let x = 1 in let y = 2 in x + y *)
Let ("x", Int 1, 
  Let ("y", Int 2, 
    Add (Var "x", Var "y")))
```

### What is `let...in`?

The `let...in` expression creates a **local binding**:

```ocaml
let x = 5 in x + 3
```

Means: "Bind `x` to `5`, then evaluate `x + 3` in that context."

**Comparison with other languages:**
- **OCaml**: `let x = 5 in x + 3` (expression)
- **Haskell**: `let x = 5 in x + 3` (same!)
- **JavaScript**: `(() => { let x = 5; return x + 3 })()` (statement)
- **Python**: No direct equivalent (statements, not expressions)
- **Rust**: Similar with blocks: `{ let x = 5; x + 3 }`

**Key difference**: In OCaml/Haskell, `let...in` is an **expression** that returns a value. In most languages, variable declarations are **statements**.

### The Environment Model

An **environment** maps variable names to values:

```ocaml
type env = (string * int) list

(* Example environment *)
let env = [("x", 5); ("y", 3); ("z", 10)]
```

**Why a list?** Simple and supports shadowing naturally:
- Newer bindings prepend to the front
- Lookup finds the first match (most recent binding)

**Evaluation with environment:**
```ocaml
let rec eval env = function
  | Int n -> n
  | Add (e1, e2) -> eval env e1 + eval env e2
  | Var x -> lookup x env        (* NEW *)
  | Let (x, e1, e2) ->            (* NEW *)
      let v1 = eval env e1 in
      let env' = (x, v1) :: env in  (* Extend environment *)
      eval env' e2
```

### Variable Lookup

Looking up a variable in the environment:

```ocaml
let rec lookup x = function
  | [] -> failwith ("Unbound variable: " ^ x)
  | (y, v) :: rest ->
      if x = y then v
      else lookup x rest
```

**Example:**
```ocaml
lookup "x" [("x", 5); ("y", 3)]  (* Returns 5 *)
lookup "y" [("x", 5); ("y", 3)]  (* Returns 3 *)
lookup "z" [("x", 5); ("y", 3)]  (* Error: unbound *)
```

### Scoping and Shadowing

**Shadowing** occurs when an inner binding has the same name as an outer one:

```ocaml
(* let x = 1 in let x = 2 in x *)
Let ("x", Int 1,
  Let ("x", Int 2,
    Var "x"))
```

Evaluation:
1. Bind `x` to `1`: `env = [("x", 1)]`
2. Bind `x` to `2`: `env' = [("x", 2); ("x", 1)]`
3. Lookup `x` finds `2` (first match)
4. Result: `2`

The inner `x` **shadows** the outer `x`. The outer `x` is still in the environment but unreachable.

**Comparison:**
- **OCaml/Haskell**: Shadowing is allowed and common
- **Rust**: Shadowing allowed with `let`
- **Java/C**: Can't shadow in same scope (compile error)
- **JavaScript**: `let` can't shadow in same scope (error)

### Immutable Environments

Environments are **immutable** in our implementation:
- Creating a new binding doesn't modify the old environment
- It creates a new environment with the binding prepended

```ocaml
let env1 = [("x", 5)]
let env2 = ("y", 3) :: env1  (* env1 unchanged! *)
```

This is **persistent data structures**—old versions remain accessible.

---

## 📝 Your Task

Implement an evaluator with variables and `let` bindings in `lib/env_eval.ml`.

### Expression Type

```ocaml
type expr =
  | Int of int
  | Add of expr * expr
  | Sub of expr * expr
  | Mul of expr * expr
  | Div of expr * expr
  | Var of string
  | Let of string * expr * expr
```

### Environment Type

```ocaml
type env = (string * int) list
```

### Functions to Implement

#### 1. `lookup : string -> env -> int`

Look up a variable in the environment.

**Examples:**
```ocaml
lookup "x" [("x", 5)] = 5
lookup "y" [("x", 5); ("y", 3)] = 3
lookup "z" [("x", 5)] (* raises exception or error *)
```

#### 2. `eval : env -> expr -> int`

Evaluate an expression in an environment.

**Examples:**
```ocaml
eval [] (Int 42) = 42
eval [("x", 5)] (Var "x") = 5
eval [] (Let ("x", Int 5, Add (Var "x", Int 3))) = 8
eval [("x", 1)] (Let ("x", Int 2, Var "x")) = 2  (* shadowing *)
```

#### 3. `expr_to_string : expr -> string`

Convert expression to string (including variables and let).

**Examples:**
```ocaml
expr_to_string (Var "x") = "x"
expr_to_string (Let ("x", Int 5, Var "x")) = "let x = 5 in x"
```

---

## 🏗️ Building and Running

```bash
dune build
dune test
dune utop
```

In utop:
```ocaml
open Env_eval;;

(* let x = 5 in x + 3 *)
let e1 = Let ("x", Int 5, Add (Var "x", Int 3));;
eval [] e1;;  (* 8 *)

(* let x = 1 in let y = 2 in x + y *)
let e2 = Let ("x", Int 1, 
           Let ("y", Int 2, 
             Add (Var "x", Var "y")));;
eval [] e2;;  (* 3 *)

(* Shadowing: let x = 1 in let x = 2 in x *)
let e3 = Let ("x", Int 1, 
           Let ("x", Int 2, 
             Var "x"));;
eval [] e3;;  (* 2 *)
```

---

## 💡 Common Mistakes

### Mistake 1: Forgetting to Extend Environment

```ocaml
(* WRONG - doesn't extend environment *)
let eval env = function
  | Let (x, e1, e2) ->
      let v1 = eval env e1 in
      eval env e2  (* env unchanged! x not bound! *)

(* RIGHT *)
let eval env = function
  | Let (x, e1, e2) ->
      let v1 = eval env e1 in
      let env' = (x, v1) :: env in
      eval env' e2
```

### Mistake 2: Evaluating e1 in Extended Environment

```ocaml
(* WRONG - let x = x + 1 in ... would use x in e1! *)
let eval env = function
  | Let (x, e1, e2) ->
      let env' = (x, ???) :: env in  (* Don't know value yet! *)
      let v1 = eval env' e1 in  (* WRONG *)
      eval env' e2

(* RIGHT - evaluate e1 in current environment first *)
let eval env = function
  | Let (x, e1, e2) ->
      let v1 = eval env e1 in     (* Use current env *)
      let env' = (x, v1) :: env in
      eval env' e2
```

### Mistake 3: Wrong Lookup Order

```ocaml
(* WRONG - finds oldest binding *)
let rec lookup x = function
  | [] -> failwith "unbound"
  | (y, v) :: rest ->
      if x = y then v
      else lookup x rest  (* Correct! First match wins *)

(* This is actually correct—the list order matters:
   prepending new bindings means first match is newest *)
```

### Mistake 4: Modifying Environment In-Place

```ocaml
(* WRONG - trying to mutate (won't work in OCaml anyway) *)
let eval env e =
  env := ("x", 5) :: !env  (* OCaml doesn't work this way *)

(* RIGHT - create new environment *)
let env' = ("x", 5) :: env
```

---

## 🎓 Going Deeper

### Static vs Dynamic Scoping

Our implementation uses **lexical (static) scoping**: variable bindings are determined by the program structure.

**Lexical scoping:**
```ocaml
let x = 1 in
let f = fun y -> x + y in
let x = 2 in
f 10  (* Returns 11, uses x = 1 *)
```

**Dynamic scoping** (not used in modern languages):
```
Would use x = 2 (most recent binding at call time)
```

### Environment vs Substitution

Two models for `let`:

**Substitution** (conceptual):
```ocaml
let x = 5 in x + 3
→ (5) + 3  (* substitute 5 for x *)
→ 8
```

**Environment** (our implementation):
```ocaml
let x = 5 in x + 3
→ eval [("x", 5)] (x + 3)
→ lookup "x" [("x", 5)] + 3
→ 5 + 3
→ 8
```

Environments are more efficient (no AST traversal for substitution).

### Closures (Coming Later)

Functions that capture their environment are **closures**:
```ocaml
let x = 5 in
let f = fun y -> x + y in
f 3  (* f "closes over" x *)
```

We'll implement closures in later modules!

---

## 🚀 Ready to Code!

Open `lib/env_eval.ml` and implement variable lookup and environment-based evaluation. Remember:
- Extend environment for `Let`
- Look up variables in environment
- Handle shadowing correctly (first match wins)

Good luck! 🎉

