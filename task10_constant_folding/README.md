# Task 10: Constant Folding and Simple Algebraic Simplifications

Welcome to Task 10, the first task in Module C! You've mastered building ASTs and evaluating them—now it's time to learn **AST transformations**. This is where compilers get interesting: you'll rewrite expressions to make them simpler or faster, while preserving their meaning.

By the end of this task, you'll understand constant folding, algebraic simplifications, and the principle of **semantic equivalence**—the foundation of compiler optimizations.

---

## 🎯 Learning Goals

- Understand AST transformations as tree rewriting
- Implement constant folding (compile-time evaluation)
- Apply algebraic simplifications (identity laws)
- Preserve semantic equivalence (`eval e == eval (transform e)`)
- Master structural recursion on ASTs
- Understand the immutability of transformations

---

## 📚 Theory: AST Transformations

### What is a Transformation?

An **AST transformation** is a function `expr -> expr` that rewrites an expression tree:

```ocaml
val transform : expr -> expr
```

**Key property**: The transformation should preserve **semantic equivalence**:
```ocaml
eval (transform e) = eval e  (* for all e *)
```

The output might look different, but it means the same thing.

**Comparison with other languages:**
- **Rust**: AST visitors and rewriters in the compiler
- **Python**: AST module for code transformations
- **C/C++**: Clang AST matchers and rewriters
- **Haskell**: Structural recursion on algebraic types

### Why Transform ASTs?

**Optimization**: Make code faster without changing behavior
```ocaml
(* Before *)
let x = 2 + 3 * 4 in x + 0

(* After optimization *)
let x = 14 in x
```

**Normalization**: Convert to a standard form for easier analysis
```ocaml
(* Before *)
x * 0

(* After *)
0  (* always zero, no need to compute x *)
```

**Preparation**: Simplify before later compilation stages

### Constant Folding

**Constant folding** evaluates constant expressions at compile time:

```ocaml
(* Input expression *)
Add (Int 2, Mul (Int 3, Int 4))

(* After constant folding *)
Int 14
```

Why? Computing `2 + 3 * 4` at compile time means we don't have to do it at runtime!

**Example in real compilers:**
```c
// C code
int x = 2 + 3 * 4;

// After constant folding (in compiled code)
int x = 14;
```

**Implementation strategy:**
1. Recursively fold sub-expressions
2. If both operands are constants, compute the result
3. Otherwise, keep the operation

```ocaml
let rec fold_constants = function
  | Add (Int a, Int b) -> Int (a + b)  (* Fold! *)
  | Add (e1, e2) ->                     (* Recurse *)
      Add (fold_constants e1, fold_constants e2)
  | ...
```

### Algebraic Simplifications

**Algebraic laws** let us simplify expressions based on mathematical properties:

**Identity laws:**
```ocaml
x + 0 = x
x - 0 = x
x * 1 = x
x / 1 = x
0 + x = x
1 * x = x
```

**Absorption laws:**
```ocaml
x * 0 = 0
0 * x = 0
```

**Examples:**
```ocaml
(* Before *)
Add (Var "x", Int 0)

(* After *)
Var "x"

(* Before *)
Mul (Var "x", Int 0)

(* After *)
Int 0
```

**Why simplify?** Fewer operations = faster code!

### Combining Transformations

You can **compose** transformations:

```ocaml
(* Input *)
Add (Mul (Int 2, Int 3), Int 0)

(* After constant folding *)
Add (Int 6, Int 0)

(* After algebraic simplification *)
Int 6
```

The order matters! Usually:
1. Fold constants first (creates more opportunities for simplification)
2. Apply algebraic laws
3. Repeat if needed (fixed-point iteration)

### Structural Recursion Pattern

All AST transformations follow this pattern:

```ocaml
let rec transform = function
  | Int n -> Int n  (* Leaves unchanged *)
  | Add (e1, e2) ->
      let e1' = transform e1 in  (* Transform children *)
      let e2' = transform e2 in
      (* Apply transformation logic *)
      match (e1', e2') with
      | (Int a, Int b) -> Int (a + b)  (* Constant fold *)
      | (e, Int 0) -> e                 (* Simplify x + 0 *)
      | (Int 0, e) -> e                 (* Simplify 0 + x *)
      | _ -> Add (e1', e2')            (* Keep as is *)
  | ...
```

**Key steps:**
1. **Recurse first**: Transform sub-expressions
2. **Pattern match**: Check for opportunities to simplify
3. **Apply rules**: Constant folding, algebraic laws
4. **Rebuild or simplify**: Return simplified or reconstructed tree

### Immutability

Transformations create **new trees**, they don't modify the old one:

```ocaml
let e = Add (Int 2, Int 3)
let e' = transform e

(* e is unchanged! *)
(* e' is a new tree *)
```

This is **persistent data structures** again—old versions remain valid.

### Interaction with Variables

Variables complicate things:

```ocaml
(* Can fold *)
Add (Int 2, Int 3)  →  Int 5

(* Can't fold (don't know x's value) *)
Add (Var "x", Int 3)  →  Add (Var "x", Int 3)

(* Can simplify *)
Add (Var "x", Int 0)  →  Var "x"
Mul (Var "x", Int 0)  →  Int 0
```

**Rule**: Only fold when both operands are constants.

### Let Bindings

For `Let` expressions, transform recursively:

```ocaml
(* Input *)
Let ("x", Add (Int 2, Int 3), Add (Var "x", Int 0))

(* After transformation *)
Let ("x", Int 5, Var "x")
```

Transform both the binding expression and the body.

---

## 📝 Your Task

Implement constant folding and algebraic simplifications in `lib/const_fold.ml`.

### Expression Type

You'll use the same `expr` type from Task 9:

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

### Function to Implement

#### `const_fold : expr -> expr`

Apply constant folding and algebraic simplifications.

**Constant folding rules:**
- `Int a + Int b → Int (a + b)`
- `Int a - Int b → Int (a - b)`
- `Int a * Int b → Int (a * b)`
- `Int a / Int b → Int (a / b)` (if b ≠ 0)

**Algebraic simplification rules:**
- `x + 0 → x` and `0 + x → x`
- `x - 0 → x`
- `x * 0 → 0` and `0 * x → 0`
- `x * 1 → x` and `1 * x → x`
- `x / 1 → x`

**For Let bindings:**
- Transform both the bound expression and the body
- `Let (x, e1, e2) → Let (x, const_fold e1, const_fold e2)`

**Examples:**
```ocaml
const_fold (Add (Int 2, Int 3)) = Int 5
const_fold (Add (Var "x", Int 0)) = Var "x"
const_fold (Mul (Var "x", Int 0)) = Int 0
const_fold (Add (Mul (Int 2, Int 3), Int 0)) = Int 6
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
open Const_fold;;

(* Constant folding *)
const_fold (Add (Int 2, Int 3));;
(* Int 5 *)

(* Algebraic simplification *)
const_fold (Add (Var "x", Int 0));;
(* Var "x" *)

(* Composition *)
const_fold (Add (Mul (Int 2, Int 3), Int 0));;
(* Int 6 *)

(* With let *)
const_fold (Let ("x", Add (Int 2, Int 3), Add (Var "x", Int 0)));;
(* Let ("x", Int 5, Var "x") *)
```

---

## 💡 Implementation Strategy

### Step 1: Handle Integers and Variables

```ocaml
let rec const_fold = function
  | Int n -> Int n          (* Constants unchanged *)
  | Var x -> Var x          (* Variables unchanged *)
  | ...
```

### Step 2: Addition with All Rules

```ocaml
| Add (e1, e2) ->
    let e1' = const_fold e1 in  (* Recurse first! *)
    let e2' = const_fold e2 in
    match (e1', e2') with
    | (Int a, Int b) -> Int (a + b)  (* Constant folding *)
    | (e, Int 0) -> e                 (* x + 0 = x *)
    | (Int 0, e) -> e                 (* 0 + x = x *)
    | _ -> Add (e1', e2')            (* Keep as is *)
```

### Step 3: Other Operations

Apply similar pattern to `Sub`, `Mul`, `Div`:
- Recurse first
- Pattern match on results
- Apply constant folding if both are `Int`
- Apply algebraic laws
- Otherwise rebuild the operation

### Step 4: Let Bindings

```ocaml
| Let (x, e1, e2) ->
    Let (x, const_fold e1, const_fold e2)
```

Simple: just transform both parts!

---

## 💡 Common Mistakes

### Mistake 1: Not Recursing First

```ocaml
(* WRONG - doesn't transform children *)
let const_fold = function
  | Add (Int a, Int b) -> Int (a + b)
  | Add (e1, e2) -> Add (e1, e2)  (* Children not transformed! *)

(* RIGHT *)
let rec const_fold = function
  | Add (e1, e2) ->
      let e1' = const_fold e1 in
      let e2' = const_fold e2 in
      (* Then pattern match on e1', e2' *)
```

### Mistake 2: Wrong Pattern Match Order

```ocaml
(* WRONG - Int case never matches because Add matches first *)
let rec const_fold = function
  | Add (e1, e2) -> Add (const_fold e1, const_fold e2)
  | Add (Int a, Int b) -> Int (a + b)  (* Unreachable! *)

(* RIGHT - use nested match after recursion *)
let rec const_fold = function
  | Add (e1, e2) ->
      let e1' = const_fold e1 in
      let e2' = const_fold e2 in
      match (e1', e2') with
      | (Int a, Int b) -> Int (a + b)
      | ...
```

### Mistake 3: Forgetting Some Simplifications

```ocaml
(* Incomplete - forgets 0 + x = x *)
match (e1', e2') with
| (Int a, Int b) -> Int (a + b)
| (e, Int 0) -> e       (* x + 0 = x ✓ *)
| _ -> Add (e1', e2')  (* Missing: 0 + x = x ✗ *)
```

Make sure to handle both `x + 0` and `0 + x`!

### Mistake 4: Breaking Semantics

```ocaml
(* WRONG - changes meaning! *)
match (e1', e2') with
| (Var x, Var y) when x = y -> Mul (Int 2, Var x)  (* x + x ≠ 2 * x semantically different! *)

(* Our task doesn't ask for this, and it's subtle *)
```

Only apply transformations you're sure are correct!

---

## 🎓 Going Deeper

### Fixed-Point Iteration

Sometimes one pass isn't enough:

```ocaml
(* Input *)
Add (Add (Int 1, Int 2), Int 0)

(* After one pass *)
Add (Int 3, Int 0)

(* After another pass *)
Int 3
```

A **fixed-point** optimizer runs until nothing changes:

```ocaml
let rec fix f x =
  let x' = f x in
  if x' = x then x else fix f x'

let optimize e = fix const_fold e
```

### Correctness

How do we know transformations are correct?

**Property**: `eval (const_fold e) = eval e`

This is testable! Property-based testing (Task 13) will verify this automatically.

### Dead Code Elimination

If we know `x` is unused, we can eliminate it:

```ocaml
(* Before *)
Let ("x", expensive_computation, y)  (* x not used in y *)

(* After *)
y
```

This is **dead code elimination**—removing unused computations.

### Strength Reduction

Replace expensive operations with cheaper ones:

```ocaml
x * 2  →  x + x   (* Shift instead of multiply *)
x / 2  →  x >> 1  (* Bit shift *)
```

### Common Subexpression Elimination (CSE)

Reuse computed values:

```ocaml
(* Before *)
(x + y) * 2 + (x + y) * 3

(* After introducing let *)
let t = x + y in t * 2 + t * 3
```

This avoids computing `x + y` twice!

---

## 🚀 Ready to Code!

Open `lib/const_fold.ml` and implement constant folding with algebraic simplifications. Remember:
- **Recurse first** (transform children)
- **Pattern match** on results
- **Apply rules** (constant folding and algebraic laws)
- **Preserve semantics** (`eval` should give same result)

Good luck! 🎉

