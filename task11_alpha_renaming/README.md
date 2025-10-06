# Task 11: Alpha-Renaming and Shadow Elimination

Welcome to Task 11, the second task in Module C! In Task 10, you learned to optimize expressions through constant folding. Now you'll tackle a different kind of transformation: **alpha-renaming**, which ensures every variable has a unique name, eliminating shadowing.

This is crucial for later compiler stages like closure conversion, code generation, and optimization passes that need to track variables without ambiguity.

By the end of this task, you'll understand variable scoping, name hygiene, fresh variable generation, and how to systematically eliminate shadowing.

---

## 🎯 Learning Goals

- Understand alpha-renaming and alpha-equivalence
- Implement fresh variable name generation
- Eliminate variable shadowing systematically
- Preserve semantic equivalence under renaming
- Understand why unique names matter for compilation
- Master stateful computations (mutable counters) in a functional context

---

## 📚 Theory: Alpha-Renaming and Shadowing

### What is Shadowing?

**Shadowing** occurs when an inner binding uses the same name as an outer binding:

```ocaml
let x = 1 in
let x = 2 in
x
```

The inner `x` **shadows** the outer `x`. The outer `x` still exists in the environment but is unreachable.

**In our AST:**
```ocaml
Let ("x", Int 1,
  Let ("x", Int 2,
    Var "x"))
```

Evaluates to `2` because inner `x` shadows outer `x`.

### Why is Shadowing a Problem?

For humans, shadowing is manageable. For compilers, it complicates things:

1. **Code generation**: Which `x` does this variable reference?
2. **Optimization**: Can't reorder bindings if names clash
3. **Closure conversion**: Need to track which variables are captured
4. **SSA form**: Static Single Assignment requires unique names

**Solution**: **Alpha-renaming** - give every binding a unique name.

### What is Alpha-Renaming?

**Alpha-renaming** is the process of renaming variables to eliminate shadowing while preserving semantics.

**Before:**
```ocaml
let x = 1 in
let x = 2 in
x
```

**After:**
```ocaml
let x_0 = 1 in
let x_1 = 2 in
x_1
```

Now every variable has a unique name!

### Alpha-Equivalence

Two expressions are **alpha-equivalent** if they differ only in variable names:

```ocaml
(* These are alpha-equivalent *)
let x = 5 in x + x
let y = 5 in y + y
let z = 5 in z + z
```

All three have the same meaning, just different names.

**Comparison with other languages:**
- **Lambda calculus**: `λx.x` ≡ `λy.y` (alpha-equivalence is fundamental)
- **Haskell**: Renaming bound variables doesn't change meaning
- **C/C++**: Variable renaming preserves semantics (as long as no name collisions)
- **SSA in LLVM**: Every variable assigned exactly once (unique names)

### Fresh Variable Generation

To eliminate shadowing, we need **fresh names** - names that haven't been used before.

**Strategy: Counter-based generation**
```ocaml
let counter = ref 0

let fresh_var base =
  let n = !counter in
  counter := n + 1;
  Printf.sprintf "%s_%d" base n
```

Each call to `fresh_var "x"` produces a new name: `x_0`, `x_1`, `x_2`, ...

**Mutable state in OCaml:**
```ocaml
let x = ref 0      (* Create mutable reference *)
let y = !x         (* Dereference: y = 0 *)
x := 5             (* Update: x now points to 5 *)
```

This is like pointers in C or references in Rust.

### The Algorithm

**Alpha-renaming algorithm:**
1. Maintain a **renaming environment** mapping old names to new names
2. When encountering a binding (`Let`):
   - Generate a fresh name
   - Add mapping: old name → fresh name
   - Recursively rename with updated environment
3. When encountering a variable (`Var`):
   - Look up the variable in the renaming environment
   - Replace with the fresh name

**Example:**
```ocaml
(* Input *)
let x = 1 in
let x = x + 1 in
x

(* Step 1: Rename first x *)
let x_0 = 1 in
let x = x_0 + 1 in  (* First x renamed in body *)
x

(* Step 2: Rename second x *)
let x_0 = 1 in
let x_1 = x_0 + 1 in  (* Second x gets new name *)
x_1                    (* Reference updated *)
```

### Renaming Environment

The **renaming environment** tracks name mappings:

```ocaml
type rename_env = (string * string) list

(* Example environment *)
[("x", "x_1"); ("y", "y_0")]
```

When we see `Var "x"`, we look it up:
- If found: replace with `"x_1"`
- If not found: keep original name (free variable)

### Handling Let Bindings

```ocaml
Let (x, e1, e2)
```

**Steps:**
1. Generate fresh name: `x_fresh = fresh_var x`
2. Rename `e1` in current environment: `e1' = rename env e1`
3. Extend environment: `env' = (x, x_fresh) :: env`
4. Rename `e2` in extended environment: `e2' = rename env' e2`
5. Return: `Let (x_fresh, e1', e2')`

**Critical**: We rename `e1` in the **current** environment (before extending), because the binding `x` is not in scope there!

### Example Walkthrough

```ocaml
(* Input *)
Let ("x", Int 10,
  Let ("x", Add (Var "x", Int 5),
    Var "x"))
```

**Renaming:**
```
Step 1: Process outer Let
  - Fresh name: x_0
  - Rename e1 = Int 10 in [] → Int 10
  - Extend env: [("x", "x_0")]
  - Rename e2 in [("x", "x_0")]...

Step 2: Process inner Let
  - Fresh name: x_1
  - Rename e1 = Add (Var "x", Int 5) in [("x", "x_0")]
    → Add (Var "x_0", Int 5)  (* x renamed to x_0 *)
  - Extend env: [("x", "x_1"); ("x", "x_0")]
  - Rename e2 = Var "x" in [("x", "x_1"); ...]
    → Var "x_1"  (* First match wins *)

Result:
Let ("x_0", Int 10,
  Let ("x_1", Add (Var "x_0", Int 5),
    Var "x_1"))
```

No more shadowing! Every variable has a unique name.

---

## 📝 Your Task

Implement alpha-renaming in `lib/alpha_rename.ml`.

### Expression Type

Same as Task 9 and 10:

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

### Types

```ocaml
type rename_env = (string * string) list
```

### Functions to Implement

#### 1. `fresh_var : string -> string`

Generate a fresh variable name based on the given base name.

**Implementation hint:** Use a mutable counter.

**Examples:**
```ocaml
fresh_var "x"  (* "x_0" *)
fresh_var "x"  (* "x_1" *)
fresh_var "y"  (* "y_2" *)
```

#### 2. `lookup_rename : string -> rename_env -> string`

Look up a variable in the renaming environment.

**Returns:** The renamed variable, or the original name if not found.

**Examples:**
```ocaml
lookup_rename "x" [("x", "x_0")]  (* "x_0" *)
lookup_rename "y" [("x", "x_0")]  (* "y" - not found, return original *)
```

#### 3. `alpha_rename : expr -> expr`

Rename all variables to eliminate shadowing.

**Examples:**
```ocaml
alpha_rename (Var "x")  (* Var "x" - unchanged *)

alpha_rename (Let ("x", Int 5, Var "x"))
(* Let ("x_0", Int 5, Var "x_0") *)

alpha_rename (Let ("x", Int 1, Let ("x", Int 2, Var "x")))
(* Let ("x_0", Int 1, Let ("x_1", Int 2, Var "x_1")) *)
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
open Alpha_rename;;

(* Simple renaming *)
alpha_rename (Let ("x", Int 5, Var "x"));;
(* Let ("x_0", Int 5, Var "x_0") *)

(* Shadowing elimination *)
alpha_rename (Let ("x", Int 1, Let ("x", Int 2, Var "x")));;
(* Let ("x_0", Int 1, Let ("x_1", Int 2, Var "x_1")) *)

(* Complex case *)
alpha_rename (Let ("x", Int 10, Let ("x", Add (Var "x", Int 5), Var "x")));;
(* Let ("x_0", Int 10, Let ("x_1", Add (Var "x_0", Int 5), Var "x_1")) *)
```

---

## 💡 Implementation Strategy

### Step 1: Fresh Variable Generation

```ocaml
let counter = ref 0

let fresh_var base =
  let n = !counter in
  counter := n + 1;
  Printf.sprintf "%s_%d" base n
```

### Step 2: Lookup in Renaming Environment

```ocaml
let rec lookup_rename x = function
  | [] -> x  (* Not found, return original *)
  | (y, y_new) :: rest ->
      if x = y then y_new else lookup_rename x rest
```

### Step 3: Alpha-Rename with Helper

```ocaml
let rec rename_expr env = function
  | Int n -> Int n
  | Var x -> Var (lookup_rename x env)
  | Add (e1, e2) -> Add (rename_expr env e1, rename_expr env e2)
  (* Similar for Sub, Mul, Div *)
  | Let (x, e1, e2) ->
      let x_fresh = fresh_var x in
      let e1' = rename_expr env e1 in        (* Current env *)
      let env' = (x, x_fresh) :: env in      (* Extend *)
      let e2' = rename_expr env' e2 in       (* Extended env *)
      Let (x_fresh, e1', e2')

let alpha_rename e =
  counter := 0;  (* Reset counter *)
  rename_expr [] e
```

---

## 💡 Common Mistakes

### Mistake 1: Renaming e1 in Extended Environment

```ocaml
(* WRONG *)
Let (x, e1, e2) ->
  let x_fresh = fresh_var x in
  let env' = (x, x_fresh) :: env in
  let e1' = rename_expr env' e1 in  (* WRONG! x not in scope in e1 *)
  let e2' = rename_expr env' e2 in
  Let (x_fresh, e1', e2')

(* RIGHT *)
Let (x, e1, e2) ->
  let x_fresh = fresh_var x in
  let e1' = rename_expr env e1 in      (* Current env *)
  let env' = (x, x_fresh) :: env in
  let e2' = rename_expr env' e2 in     (* Extended env *)
  Let (x_fresh, e1', e2')
```

### Mistake 2: Not Resetting Counter

```ocaml
(* If you don't reset counter, names keep increasing *)
alpha_rename e1;;  (* x_0, x_1, ... *)
alpha_rename e2;;  (* x_2, x_3, ... - continues from previous! *)
```

Solution: Reset counter at the start of `alpha_rename`.

### Mistake 3: Mutating Original Expression

```ocaml
(* OCaml doesn't allow this anyway, but conceptually *)
(* Don't modify the original tree, build a new one *)
```

### Mistake 4: Wrong Lookup

```ocaml
(* WRONG - uses first binding regardless of name *)
let lookup_rename x = function
  | (_, y_new) :: _ -> y_new  (* Forgets to check if x matches! *)
  | [] -> x

(* RIGHT *)
let rec lookup_rename x = function
  | [] -> x
  | (y, y_new) :: rest ->
      if x = y then y_new else lookup_rename x rest
```

---

## 🎓 Going Deeper

### Capture-Avoiding Substitution

Alpha-renaming is related to **capture-avoiding substitution** in lambda calculus:

```
(λx. λy. x) y  →  λz. y  (* Rename y to z to avoid capture *)
```

Without renaming, `y` would be "captured" by the inner `λy`.

### Static Single Assignment (SSA)

Modern compilers use **SSA form**, where every variable is assigned exactly once:

```c
// Before
x = 1;
x = x + 2;
x = x * 3;

// SSA form
x_1 = 1;
x_2 = x_1 + 2;
x_3 = x_2 * 3;
```

Alpha-renaming is a step toward SSA!

### De Bruijn Indices

An alternative to names: use **indices** to reference bindings:

```ocaml
(* Named *)
λx. λy. x

(* De Bruijn *)
λ. λ. 1  (* 1 refers to the 1st enclosing lambda *)
```

No names = no shadowing problems!

### Scope Graphs

Complex languages track scoping with **scope graphs** - data structures representing name visibility.

### Hygiene in Macros

Lisp macros use **hygienic macro expansion** to avoid variable capture:

```scheme
(define-syntax my-let
  (syntax-rules ()
    [(my-let x e body)
     ((lambda (x) body) e)]))
```

Hygienic macros automatically rename variables to avoid conflicts.

---

## 🚀 Ready to Code!

Open `lib/alpha_rename.ml` and implement alpha-renaming with fresh variable generation. Remember:
- **Generate fresh names** for each binding
- **Track renamings** in an environment
- **Rename e1 in current env**, e2 in extended env
- **Preserve semantics** (evaluation should give same result)

Good luck! 🎉

