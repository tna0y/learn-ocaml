# Task 2: Functions and Recursion

Welcome to Task 2! Now that you've mastered the basics, it's time to dive into one of the most fundamental patterns in functional programming: **recursion**. In OCaml, recursion isn't just a technique—it's *the* primary way to process data and implement iteration.

By the end of this task, you'll understand how to write recursive functions, why tail recursion matters, and how to use the accumulator pattern for efficient computation.

---

## 🎯 Learning Goals

- Master the `let rec` syntax for recursive functions
- Understand the difference between normal and tail recursion
- Learn the accumulator pattern for tail-recursive functions
- Recognize stack overflow risks and how to avoid them
- Write efficient recursive implementations of classic algorithms

---

## 📚 Theory: Recursion in OCaml

### The `let rec` Keyword

In OCaml, to define a recursive function (one that calls itself), you must use `let rec` instead of `let`:

```ocaml
let rec factorial n =
  if n <= 1 then 1
  else n * factorial (n - 1)
```

**Why the `rec` keyword?**

In most languages, functions can call themselves automatically:
- **C**: `int factorial(int n) { return n <= 1 ? 1 : n * factorial(n-1); }`
- **Python**: `def factorial(n): return 1 if n <= 1 else n * factorial(n-1)`
- **Rust**: Same pattern

But in OCaml, `let` bindings are evaluated immediately, and the name being defined isn't in scope during evaluation. The `rec` keyword explicitly tells OCaml: "This name should be available inside its own definition."

**Comparison:**
- **Haskell**: All functions can be recursive by default (no keyword needed)
- **OCaml**: Must explicitly use `let rec`
- **Rust**: Must use `fn` (functions are recursive by default)

### Normal Recursion: Simple but Dangerous

Here's a straightforward recursive factorial:

```ocaml
let rec factorial n =
  if n <= 1 then 1
  else n * factorial (n - 1)
```

**What happens when you call `factorial 5`?**

```
factorial 5
= 5 * factorial 4
= 5 * (4 * factorial 3)
= 5 * (4 * (3 * factorial 2))
= 5 * (4 * (3 * (2 * factorial 1)))
= 5 * (4 * (3 * (2 * 1)))
= 5 * (4 * (3 * 2))
= 5 * (4 * 6)
= 5 * 24
= 120
```

Notice how the computation **builds up a chain of pending multiplications** before collapsing back. Each recursive call requires stack space to remember "what to do after the recursive call returns."

**The Problem:** Try `factorial 100000` and you'll get a stack overflow! Each call consumes stack space, and deep recursion exhausts it.

### Tail Recursion: The Solution

A function is **tail-recursive** if the recursive call is the *last operation* the function performs. No pending operations after the call.

```ocaml
let rec factorial_tail n acc =
  if n <= 1 then acc
  else factorial_tail (n - 1) (n * acc)

let factorial n = factorial_tail n 1
```

**What happens when you call `factorial 5`?**

```
factorial 5
= factorial_tail 5 1
= factorial_tail 4 5       (* 5 * 1 *)
= factorial_tail 3 20      (* 4 * 5 *)
= factorial_tail 2 60      (* 3 * 20 *)
= factorial_tail 1 120     (* 2 * 60 *)
= 120                      (* n <= 1, return acc *)
```

**No pending operations!** Each call completes immediately with the result of the next call. The OCaml compiler can optimize this into a loop—**no stack growth**.

**Comparison with other languages:**
- **Scheme/Lisp**: Guaranteed tail call optimization
- **OCaml**: Guaranteed tail call optimization for tail-recursive calls
- **Rust**: No guaranteed tail call optimization (must use explicit loops)
- **C**: Depends on compiler optimization level
- **Python**: No tail call optimization (recursion is limited)

### The Accumulator Pattern

The key to tail recursion is the **accumulator**: a parameter that carries the "result so far."

**Pattern:**
```ocaml
let rec loop n acc =
  if base_case then acc           (* return accumulated result *)
  else loop (n - 1) (update acc)  (* tail call with updated accumulator *)
```

Think of the accumulator as a state variable in an imperative loop:
```python
# Imperative (Python)
acc = 1
for i in range(n, 0, -1):
    acc = acc * i
return acc
```

```ocaml
(* Functional (OCaml) *)
let rec loop i acc =
  if i <= 0 then acc
  else loop (i - 1) (acc * i)
```

The accumulator replaces mutable state!

### Conditional Expressions in OCaml

OCaml uses `if ... then ... else ...`:

```ocaml
let max x y =
  if x > y then x else y
```

**Important differences from other languages:**
- **`else` is mandatory** when the `then` branch returns a value (everything is an expression!)
- **No braces needed** — just expressions
- **Everything is an expression** — `if` returns a value

**Comparison:**
- **C**: `int max = (x > y) ? x : y;` (ternary) or `if (x > y) { return x; } else { return y; }`
- **Python**: `max = x if x > y else y`
- **Rust**: `let max = if x > y { x } else { y };`
- **OCaml**: `let max = if x > y then x else y`

### Multiple Recursive Functions

You can define mutually recursive functions with `let rec ... and ...`:

```ocaml
let rec is_even n =
  if n = 0 then true
  else is_odd (n - 1)

and is_odd n =
  if n = 0 then false
  else is_even (n - 1)
```

---

## 📊 Performance: Stack vs Tail Recursion

| Approach | Stack Usage | Can Handle Large Inputs? | Code Clarity |
|----------|-------------|-------------------------|--------------|
| **Normal Recursion** | O(n) | ❌ Stack overflow | ✅ Very clear |
| **Tail Recursion** | O(1) | ✅ Optimized to loop | ⚠️ Needs accumulator |

**Rule of thumb:**
- For small inputs or tree-like structures: normal recursion is fine
- For linear recursion over large ranges: use tail recursion
- For lists/sequences in production code: always use tail recursion

---

## 📝 Your Task

Implement the following functions in `lib/recursion.ml`:

### 1. Factorial (Normal Recursion)

```ocaml
val fact : int -> int
```

Compute factorial using **normal recursion** (not tail-recursive).

**Examples:**
- `fact 0 = 1`
- `fact 5 = 120`
- `fact 10 = 3628800`

### 2. Factorial (Tail Recursion)

```ocaml
val fact_tail : int -> int
```

Compute factorial using **tail recursion** with an accumulator.

**Requirements:**
- Must be tail-recursive (use an accumulator)
- Should produce the same results as `fact`
- Should handle larger inputs without stack overflow

### 3. Fibonacci (Tail Recursion)

```ocaml
val fib : int -> int
```

Compute the nth Fibonacci number using **tail recursion**.

**Fibonacci sequence:** 0, 1, 1, 2, 3, 5, 8, 13, 21, ...
- `fib 0 = 0`
- `fib 1 = 1`
- `fib n = fib (n-1) + fib (n-2)` for n ≥ 2

**Requirements:**
- Must be tail-recursive (you'll need TWO accumulators!)
- Should efficiently compute large Fibonacci numbers

**Hint for Fibonacci:** The naive recursive approach is exponentially slow:
```ocaml
(* DON'T DO THIS — exponential time! *)
let rec fib_slow n =
  if n <= 1 then n
  else fib_slow (n - 1) + fib_slow (n - 2)
```

Instead, use two accumulators to track the last two Fibonacci numbers.

### Implementation Structure

You'll implement these in `lib/recursion.ml` and expose them through `lib/recursion.mli`. The interface file is already provided—it specifies what functions you need to implement.

---

## 🏗️ Building and Running

### Build Your Code

```bash
dune build
```

### Run Tests

```bash
dune test
```

The tests will verify:
- Correctness of factorial implementations (both versions)
- Correctness of Fibonacci implementation
- That tail-recursive versions can handle larger inputs

### Experiment in the REPL

```bash
dune utop
```

Then try:
```ocaml
open Recursion;;
fact 5;;
fact_tail 10;;
fib 10;;
```

---

## 💡 Common Mistakes and How to Avoid Them

### Mistake 1: Forgetting `rec`

```ocaml
(* WRONG — will give "Unbound value" error *)
let factorial n =
  if n <= 1 then 1
  else n * factorial (n - 1)

(* RIGHT *)
let rec factorial n =
  if n <= 1 then 1
  else n * factorial (n - 1)
```

### Mistake 2: Non-Tail Recursive Call

```ocaml
(* NOT tail-recursive — multiplication happens AFTER the recursive call *)
let rec fact n acc =
  if n <= 1 then acc
  else fact (n - 1) acc * n  (* BAD: pending multiplication *)

(* Tail-recursive — multiplication happens BEFORE the recursive call *)
let rec fact n acc =
  if n <= 1 then acc
  else fact (n - 1) (acc * n)  (* GOOD: no pending operations *)
```

### Mistake 3: Wrong Fibonacci Accumulator Logic

The trick with Fibonacci is tracking two consecutive values:
- `a` = F(n-2)
- `b` = F(n-1)

Each iteration: `(a, b)` becomes `(b, a + b)`

```ocaml
let rec fib_helper n a b =
  if n = 0 then a
  else if n = 1 then b
  else fib_helper (n - 1) b (a + b)

let fib n = fib_helper n 0 1
```

### Mistake 4: Missing `else` in Conditionals

```ocaml
(* WRONG — OCaml requires else when if returns a value *)
let rec fact n =
  if n <= 1 then 1
  (* missing else! *)

(* RIGHT *)
let rec fact n =
  if n <= 1 then 1
  else n * fact (n - 1)
```

---

## 🎓 Going Deeper (Optional Reading)

### Why Tail Call Optimization Matters

When a function makes a tail call, the compiler can **reuse the same stack frame**:

```ocaml
(* This becomes a loop internally *)
let rec loop n acc =
  if n = 0 then acc
  else loop (n - 1) (acc + n)
```

**Assembly-level insight:** Instead of `CALL` (push stack frame) + `RET` (pop stack frame), the compiler generates a `JMP` (jump) instruction—no stack overhead!

### Recursion vs Iteration

In imperative languages, you'd use loops:
```c
// C
int factorial(int n) {
    int result = 1;
    for (int i = n; i > 1; i--) {
        result *= i;
    }
    return result;
}
```

In OCaml, tail recursion **is** your loop:
```ocaml
(* OCaml *)
let factorial n =
  let rec loop i acc =
    if i <= 1 then acc
    else loop (i - 1) (acc * i)
  in
  loop n 1
```

The OCaml version compiles to essentially the same machine code as the C loop!

### When NOT to Use Tail Recursion

For naturally tree-shaped recursion, normal recursion is often clearer:
```ocaml
(* Tree depth — normal recursion is fine *)
type tree = Leaf | Node of tree * tree

let rec depth = function
  | Leaf -> 0
  | Node (left, right) -> 1 + max (depth left) (depth right)
```

Converting this to tail recursion would make it much less readable with minimal benefit (tree depth is typically logarithmic, not linear).

---

## 🚀 Ready to Code!

Open `lib/recursion.ml` and implement your solutions. Start with the simpler `fact`, then tackle `fact_tail`, and finally the more challenging `fib`.

Remember:
- Test frequently with `dune test`
- Experiment in `dune utop`
- Think about the accumulator as "state so far"
- Make sure your recursive call is the *last* operation for tail recursion

Good luck! 🎉

