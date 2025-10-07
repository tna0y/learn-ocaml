# Task 12: Toy Stack Machine and Compilation

Welcome to Task 12, the first task in Module D! You've mastered AST transformations—now it's time to **compile** expressions to executable code. This task introduces **stack-based execution**, the foundation of most real-world virtual machines including the JVM, Python bytecode, and WebAssembly.

By the end of this task, you'll understand how stack machines work, how to compile high-level expressions to low-level instructions, and why this architecture is so popular for VMs.

---

## 🎯 Learning Goals

- Understand stack-based execution model
- Learn how stack machines differ from tree-based evaluation
- Implement a compiler from expressions to bytecode
- Work with instruction sequences
- Handle variables through LOAD/STORE operations
- Verify compilation correctness through testing
- Understand the bridge to real VMs (WebAssembly)

---

## 📚 Theory: Stack Machines

### What is a Stack Machine?

A **stack machine** is a computational model that uses a stack as the primary data structure:

```
Stack (grows upward):
┌─────┐
│  5  │ ← Top of stack
├─────┤
│  3  │
├─────┤
│  1  │
└─────┘
```

**Operations:**
- **PUSH n**: Push value `n` onto the stack
- **ADD**: Pop two values, push their sum
- **SUB**: Pop two values, push their difference
- **MUL**: Pop two values, push their product
- **DIV**: Pop two values, push their quotient

**Comparison with other models:**
- **Register machine** (x86, ARM): Operations use named registers
- **Stack machine** (JVM, WASM): Operations use a stack
- **Tree evaluation** (our previous tasks): Recursively evaluate AST nodes

### Why Stack Machines?

**Advantages:**
1. **Simple to implement**: No need to manage registers
2. **Compact code**: Instructions are simple (often single byte)
3. **Easy to compile to**: Natural mapping from expressions
4. **Portable**: Same bytecode runs on any platform
5. **Secure**: Limited operations, easy to sandbox

**Real-world stack machines:**
- **Java Virtual Machine (JVM)**: Java bytecode
- **Python**: CPython bytecode (`.pyc` files)
- **WebAssembly (WASM)**: Modern web VM
- **Ethereum VM**: Smart contract execution
- **Forth**: Stack-based programming language

### Stack Machine Execution Model

**Example: Computing `2 + 3`**

```
Instructions:        Stack State:
--------------       ------------
PUSH 2              [2]
PUSH 3              [2, 3]
ADD                 [5]         ← result!
```

**Step-by-step:**
1. `PUSH 2`: Put 2 on the stack → `[2]`
2. `PUSH 3`: Put 3 on the stack → `[2, 3]`
3. `ADD`: Pop 3 and 2, compute 2 + 3 = 5, push 5 → `[5]`

**Example: Computing `(2 + 3) * 4`**

```
Instructions:        Stack State:
--------------       ------------
PUSH 2              [2]
PUSH 3              [2, 3]
ADD                 [5]
PUSH 4              [5, 4]
MUL                 [20]        ← result!
```

### Postfix Notation Connection

Stack machine code is essentially **Reverse Polish Notation (RPN)**:

```
Infix:    (2 + 3) * 4
Postfix:  2 3 + 4 *
Stack:    PUSH 2; PUSH 3; ADD; PUSH 4; MUL
```

This is the same notation used by old HP calculators!

### Our Instruction Set

```ocaml
type instr =
  | PUSH of int        (* Push constant onto stack *)
  | ADD                (* Pop y, pop x, push x + y *)
  | SUB                (* Pop y, pop x, push x - y *)
  | MUL                (* Pop y, pop x, push x * y *)
  | DIV                (* Pop y, pop x, push x / y *)
  | LOAD of string     (* Load variable from environment, push onto stack *)
  | STORE of string    (* Pop value, store in environment *)
```

**Note on order:** For SUB and DIV, we pop `y` then `x`, and compute `x - y` or `x / y`:
```
Stack: [x, y]  (y on top)
SUB pops y, then x
Computes: x - y
```

### Variables and Environment

Variables are stored in an **environment** (like in Task 9):

```ocaml
type vm_env = (string * int) list
```

**LOAD** retrieves a variable's value:
```
Environment: [("x", 5)]
LOAD "x"  →  pushes 5 onto stack
```

**STORE** saves a value to a variable:
```
Stack: [10]
Environment: []
STORE "x"  →  Environment: [("x", 10)], Stack: []
```

### Compiling Expressions

**Simple expression:** `Add (Int 2, Int 3)`

```ocaml
PUSH 2
PUSH 3
ADD
```

**With variables:** `Add (Var "x", Int 3)`

```ocaml
LOAD "x"    (* Load x's value *)
PUSH 3
ADD
```

**With let binding:** `Let ("x", Int 5, Add (Var "x", Int 3))`

```ocaml
PUSH 5      (* Evaluate bound expression *)
STORE "x"   (* Store in environment *)
LOAD "x"    (* Evaluate body: load x *)
PUSH 3
ADD
```

### Compilation Strategy

**General pattern:**
1. **Compile left operand** → produces code that leaves result on stack
2. **Compile right operand** → produces code that leaves result on stack
3. **Apply operation** → single instruction that combines top two stack values

```ocaml
let rec compile = function
  | Int n -> [PUSH n]
  | Add (e1, e2) ->
      compile e1        (* Code for e1 *)
      @ compile e2      (* Code for e2 *)
      @ [ADD]           (* Combine *)
  | Var x -> [LOAD x]
  | Let (x, e1, e2) ->
      compile e1        (* Compute binding value *)
      @ [STORE x]       (* Save to environment *)
      @ compile e2      (* Evaluate body *)
```

**Example compilation:** `Mul (Add (Int 2, Int 3), Int 4)`

```
compile (Add (Int 2, Int 3))  →  [PUSH 2; PUSH 3; ADD]
compile (Int 4)               →  [PUSH 4]
Final:                           [PUSH 2; PUSH 3; ADD; PUSH 4; MUL]
```

### The Interpreter (Provided)

We provide a VM interpreter that executes instructions:

```ocaml
val execute : instr list -> vm_env -> int
```

**Execution loop:**
1. Start with empty stack and given environment
2. For each instruction:
   - Update stack and/or environment
3. Return final stack top

**Your task:** Write the compiler. We'll test it by comparing:
```ocaml
eval env expr = execute (compile expr) env
```

Both should produce the same result!

---

## 📝 Your Task

Implement a compiler from expressions to stack machine instructions in `lib/stack_compiler.ml`.

### Expression Type

Same as previous tasks:

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

### Instruction Type

```ocaml
type instr =
  | PUSH of int
  | ADD
  | SUB
  | MUL
  | DIV
  | LOAD of string
  | STORE of string
```

### Function to Implement

#### `compile : expr -> instr list`

Compile an expression to a list of instructions.

**Examples:**
```ocaml
compile (Int 42) = [PUSH 42]

compile (Add (Int 2, Int 3)) = [PUSH 2; PUSH 3; ADD]

compile (Mul (Add (Int 2, Int 3), Int 4)) =
  [PUSH 2; PUSH 3; ADD; PUSH 4; MUL]

compile (Var "x") = [LOAD "x"]

compile (Let ("x", Int 5, Add (Var "x", Int 3))) =
  [PUSH 5; STORE "x"; LOAD "x"; PUSH 3; ADD]
```

---

## 🏗️ Building and Running

```bash
dune build
dune test
dune exec task12_stack_machine
```

In utop:
```ocaml
open Stack_compiler;;

(* Compile simple expression *)
let code = compile (Add (Int 2, Int 3));;
(* [PUSH 2; PUSH 3; ADD] *)

(* Execute it *)
execute code [];;
(* 5 *)

(* With variables *)
let code2 = compile (Let ("x", Int 10, Mul (Var "x", Int 2)));;
execute code2 [];;
(* 20 *)

(* Debug execution *)
execute_debug code2 [];;
(* Shows step-by-step execution *)
```

---

## 💡 Implementation Strategy

### Step 1: Handle Constants

```ocaml
let rec compile = function
  | Int n -> [PUSH n]
  | ...
```

### Step 2: Binary Operations

```ocaml
| Add (e1, e2) ->
    compile e1        (* Left operand code *)
    @ compile e2      (* Right operand code *)
    @ [ADD]           (* Operation *)
```

Apply same pattern to `Sub`, `Mul`, `Div`.

### Step 3: Variables

```ocaml
| Var x -> [LOAD x]
```

### Step 4: Let Bindings

```ocaml
| Let (x, e1, e2) ->
    compile e1        (* Compute binding value *)
    @ [STORE x]       (* Store in environment *)
    @ compile e2      (* Evaluate body *)
```

**Critical:** The `STORE` instruction pops the value from the stack and saves it to the environment.

---

## 💡 Common Mistakes

### Mistake 1: Wrong Operand Order

```ocaml
(* WRONG - reversed operands *)
| Sub (e1, e2) ->
    compile e2 @ compile e1 @ [SUB]

(* RIGHT - left operand first *)
| Sub (e1, e2) ->
    compile e1 @ compile e2 @ [SUB]
```

For `Sub (Int 10, Int 3)`:
- Correct: `[PUSH 10; PUSH 3; SUB]` → 10 - 3 = 7
- Wrong: `[PUSH 3; PUSH 10; SUB]` → 3 - 10 = -7

### Mistake 2: Forgetting to Concatenate

```ocaml
(* WRONG - returns nested list *)
| Add (e1, e2) ->
    [compile e1; compile e2; [ADD]]

(* RIGHT - flatten with @ *)
| Add (e1, e2) ->
    compile e1 @ compile e2 @ [ADD]
```

### Mistake 3: STORE After Body

```ocaml
(* WRONG - stores after evaluating body *)
| Let (x, e1, e2) ->
    compile e1 @ compile e2 @ [STORE x]

(* RIGHT - store before body *)
| Let (x, e1, e2) ->
    compile e1 @ [STORE x] @ compile e2
```

The binding must be available when evaluating the body!

### Mistake 4: Not Understanding Stack Order

Remember: **Last pushed is first popped**

```
PUSH 10   →  [10]
PUSH 3    →  [10, 3]     (3 on top)
SUB       →  pops 3, pops 10, computes 10 - 3 → [7]
```

---

## 🎓 Going Deeper

### Stack Underflow and Overflow

Real VMs check for:
- **Stack underflow**: Popping from empty stack
- **Stack overflow**: Stack too large

Our simple VM doesn't check these, but production VMs do!

### Register Allocation

After stack machines, compilers often perform **register allocation**:
- Assign stack slots to physical CPU registers
- Minimize memory access for speed

### JIT Compilation

Modern VMs use **Just-In-Time (JIT) compilation**:
1. Start with interpreter (like our `execute`)
2. Profile which code runs frequently
3. Compile hot code to native machine code
4. Huge speedup!

Examples: JVM HotSpot, V8 (JavaScript), PyPy

### WebAssembly Connection

Our toy VM is very similar to WASM:

**Our VM:**
```
PUSH 2
PUSH 3
ADD
```

**WASM (.wat format):**
```wasm
i32.const 2
i32.const 3
i32.add
```

Almost identical! Task 14 will compile to real WASM.

### Static Single Assignment (SSA)

Our `STORE` can overwrite variables. SSA form forbids this:

```
(* Our IR: can reuse names *)
PUSH 5
STORE x
PUSH 10
STORE x    (* Overwrites x *)

(* SSA: unique names *)
PUSH 5
STORE x_1
PUSH 10
STORE x_2  (* Different name *)
```

LLVM and many modern compilers use SSA!

### Optimization Opportunities

After compiling to instructions, we can optimize:

**Pattern matching:**
```
PUSH 2
PUSH 3
ADD
PUSH 0
ADD
```

Can optimize away the `+ 0`:
```
PUSH 2
PUSH 3
ADD
```

This is **peephole optimization** - looking for patterns to optimize.

### Type Safety

Our VM is untyped (everything is `int`). Real VMs track types:

**Typed stack machine:**
```
PUSH : ∀t. t → Stack → Stack[t]
ADD  : Stack[Int, Int] → Stack[Int]
```

Type systems prevent runtime errors!

### Comparison with Tree Walking

**Tree walking (Task 9):**
```ocaml
let rec eval env = function
  | Add (e1, e2) -> eval env e1 + eval env e2
```

**Stack machine (Task 12):**
```ocaml
let rec compile = function
  | Add (e1, e2) -> compile e1 @ compile e2 @ [ADD]

execute [PUSH 2; PUSH 3; ADD] []
```

**Trade-offs:**
- Tree walking: Simple, direct, good for small programs
- Stack machine: Efficient, cacheable bytecode, good for distribution

### Debugging Execution

We provide `execute_debug` which shows each step:

```ocaml
execute_debug [PUSH 2; PUSH 3; ADD] []
```

Output:
```
Step 0: PUSH 2
  Stack: [2]
  Env: []

Step 1: PUSH 3
  Stack: [2, 3]
  Env: []

Step 2: ADD
  Stack: [5]
  Env: []

Result: 5
```

This is invaluable for understanding and debugging!

---

## 🚀 Ready to Code!

Open `lib/stack_compiler.ml` and implement the compiler. Remember:
- **Compile recursively** (structural recursion on AST)
- **Left then right** for binary operations
- **Concatenate instruction lists** with `@`
- **STORE before body** for Let bindings
- **Test by comparing** with `eval`

This is where your expressions come alive as executable code! 🎉

Good luck!

