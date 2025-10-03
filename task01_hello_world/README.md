# Task 1: Hello, World! + Build and I/O

Welcome to your first OCaml task! This is where your journey begins. By the end of this exercise, you'll understand the basics of OCaml syntax, how to build and run OCaml programs, and how to handle simple input/output operations.

---

## 🎯 Learning Goals

- Understand basic OCaml syntax and the `let` binding
- Learn about immutability by default
- Master simple I/O operations in OCaml
- Get comfortable with the OCaml build system (`dune`)
- Write your first working OCaml program

---

## 📚 Theory: OCaml Fundamentals

### The `let` Binding: Your New Friend

In OCaml, you define values (not variables!) using the `let` keyword:

```ocaml
let greeting = "Hello"
```

**Wait, what's the difference between a value and a variable?**

In most languages you know:
- **C**: `char *greeting = "Hello";` — you can reassign: `greeting = "Goodbye";`
- **Python**: `greeting = "Hello"` — you can reassign: `greeting = "Goodbye"`
- **Rust (mut)**: `let mut greeting = "Hello";` — you can reassign with `mut`

In OCaml (and Haskell):
- **OCaml**: `let greeting = "Hello"` — **immutable by default**. You cannot reassign.
- Think of it like **Rust's `let` without `mut`** or **C's `const`** (but more strictly enforced).

This immutability is a core principle of functional programming. Once you bind a value to a name, that binding doesn't change. If you need a different value, you create a new binding (possibly shadowing the old one).

### Functions: First-Class Citizens

In OCaml, functions are values just like integers or strings. Here's how you define them:

```ocaml
let add x y = x + y
```

This looks different from C or Python! Let's compare:

| Language | Function Definition |
|----------|---------------------|
| **C** | `int add(int x, int y) { return x + y; }` |
| **Python** | `def add(x, y): return x + y` |
| **Rust** | `fn add(x: i32, y: i32) -> i32 { x + y }` |
| **Haskell** | `add x y = x + y` |
| **OCaml** | `let add x y = x + y` |

Notice:
- **No explicit type annotations needed** — OCaml infers that `add : int -> int -> int`
- **No `return` keyword** — the last expression is automatically returned
- **No braces or indentation requirements** — just clean, mathematical notation

### The Unit Type: OCaml's "void"

When a function doesn't return a meaningful value (like printing to the screen), it returns `unit`, written as `()`.

```ocaml
let greet () = print_endline "Hello!"
```

Think of `()` as:
- **C**: `void` return type
- **Python**: `None`
- **Rust**: `()` (exactly the same!)
- **Haskell**: `()` (exactly the same!)

### Basic I/O Operations

OCaml provides simple functions for input/output:

#### Output Functions

```ocaml
print_string "Hello"      (* prints without newline *)
print_endline "Hello"     (* prints with newline, like puts in C or print in Python *)
```

**Comparison with other languages:**
- **C**: `printf("Hello\n");` or `puts("Hello");`
- **Python**: `print("Hello")`
- **Rust**: `println!("Hello");`
- **OCaml**: `print_endline "Hello"`

Notice: **No parentheses needed around the argument!** In OCaml, function application is just `function argument`, not `function(argument)`. Parentheses are only needed for grouping.

#### Input Functions

```ocaml
read_line ()              (* reads a line from stdin, returns a string *)
```

This is equivalent to:
- **C**: `fgets(buffer, size, stdin)` (but safer!)
- **Python**: `input()` (Python 3) or `raw_input()` (Python 2)
- **Rust**: `stdin().read_line(&mut buffer)`

**Important:** `read_line` takes `()` as an argument because it's a function with side effects (reading from the external world). This distinguishes it from pure functions.

### String Concatenation

OCaml uses `^` for string concatenation:

```ocaml
let greeting = "Hello, " ^ "World!"
```

**Comparison:**
- **C**: `strcat(dest, src)` (requires manual buffer management!)
- **Python**: `"Hello, " + "World!"` or `"Hello, " "World!"`
- **Rust**: `format!("Hello, {}", "World!")` or `"Hello, ".to_string() + "World!"`
- **Haskell**: `"Hello, " ++ "World!"`
- **OCaml**: `"Hello, " ^ "World!"`

### The Main Entry Point

In OCaml, the entry point is typically written as:

```ocaml
let () = ...
```

This might look strange! Here's what's happening:

```ocaml
let () = print_endline "Hello"
```

This means: "Bind the result of `print_endline "Hello"` to `()`. Since `print_endline` returns `()` (unit), this is a pattern match that ensures the expression is of type `unit`. It's OCaml's idiomatic way of saying "execute this for its side effects."

**Think of it as:**
- **C**: `int main() { ... }`
- **Python**: `if __name__ == "__main__": ...`
- **Rust**: `fn main() { ... }`
- **OCaml**: `let () = ...`

---

## 🔧 Project Structure

When you run `dune init proj`, you get this structure:

```
task01_hello_world/
├── bin/
│   ├── dune          # build configuration for the executable
│   └── main.ml       # your main program (YOU IMPLEMENT THIS)
├── test/
│   ├── dune          # build configuration for tests
│   └── test_task01_hello_world.ml  # tests (already written)
├── dune-project      # project-level configuration
└── README.md         # this file
```

### What Goes Where?

- **`bin/main.ml`**: Your executable program. This is what runs when you type `dune exec`.
- **`test/test_*.ml`**: Test files that verify your implementation works correctly.
- **`dune` files**: Build configuration. Tells `dune` how to compile your code.
- **`dune-project`**: Project metadata and dependencies.

---

## 📝 Your Task

Implement a program in `bin/main.ml` that:

1. **Prints** `"Hello, World!"` to the console
2. **Reads** a name from standard input
3. **Prints** `Hello, <name>!` where `<name>` is what the user entered

### Example Interaction

```
$ dune exec task01_hello_world
Hello, World!
Alice
Hello, Alice!
```

### Implementation Hints

You'll need:
1. `print_endline` to print with a newline
2. `read_line ()` to read input (don't forget the `()` argument!)
3. `^` to concatenate strings
4. `let () = ...` to create your entry point

**Remember:** In OCaml, you don't need parentheses for function calls. `read_line ()` calls `read_line` with the unit argument. `print_endline "Hello"` calls `print_endline` with the string argument.

---

## 🏗️ Building and Running

### Build Your Program

```bash
dune build
```

This compiles your OCaml code. If there are syntax errors, you'll see them here.

### Run Your Program

```bash
dune exec task01_hello_world
```

This builds (if needed) and runs your program.

### Run Tests

```bash
dune test
```

This runs the test suite to verify your implementation is correct.

### Clean Build Artifacts

```bash
dune clean
```

This removes all compiled files. Useful when you want a fresh start.

---

## 🧪 Understanding the Tests

The tests verify that your program:
1. Outputs "Hello, World!" first
2. Then outputs the personalized greeting based on input

The tests use a technique called **I/O redirection** to:
- Provide simulated input to your program
- Capture the output your program produces
- Compare it against expected results

You don't need to modify the tests — just make sure your implementation passes them!

---

## 💡 Common Mistakes and How to Avoid Them

### Mistake 1: Forgetting Parentheses with `read_line`

```ocaml
(* WRONG *)
let name = read_line

(* RIGHT *)
let name = read_line ()
```

`read_line` is a function that takes `()` as an argument. Without `()`, you're not calling the function, you're just referring to it!

### Mistake 2: Using `print` Instead of `print_endline`

```ocaml
(* This exists but doesn't add a newline *)
print_string "Hello"

(* This adds a newline, which is usually what you want *)
print_endline "Hello"
```

### Mistake 3: Trying to Reassign Values

```ocaml
(* WRONG — this will give a type error *)
let name = "Alice"
name = "Bob"  (* This is comparison, not assignment! *)

(* In OCaml, you don't reassign. You create new bindings. *)
```

### Mistake 4: String Concatenation with `+`

```ocaml
(* WRONG *)
"Hello" + "World"  (* + is for integers! *)

(* RIGHT *)
"Hello" ^ "World"  (* ^ is for strings *)
```

---

## 🎓 Going Deeper (Optional Reading)

### Why Immutability?

Immutable values make programs easier to reason about:
- No spooky action at a distance (one function can't modify data another function relies on)
- Better for concurrent programming (no race conditions on shared state)
- Compiler optimizations (the compiler knows values don't change)

### The Type System is Watching

OCaml has a powerful type system that catches errors at compile time:

```ocaml
let x = 42
let y = "Hello" ^ x  (* TYPE ERROR: can't concatenate string and int *)
```

This error is caught **before you run your program**. No runtime surprises!

Compare to Python:
```python
x = 42
y = "Hello" + x  # Runtime error: TypeError
```

### The REPL (Read-Eval-Print Loop)

You can experiment with OCaml interactively:

```bash
$ ocaml
        OCaml version 4.14.0

# let greeting = "Hello";;
val greeting : string = "Hello"

# print_endline greeting;;
Hello
- : unit = ()
```

The REPL is great for testing small snippets!

---

## ✅ Checklist

Before moving to the next task, make sure you can:

- [ ] Write a basic OCaml program with `let` bindings
- [ ] Use `print_endline` for output
- [ ] Use `read_line ()` for input
- [ ] Concatenate strings with `^`
- [ ] Build and run programs with `dune build` and `dune exec`
- [ ] Run tests with `dune test`
- [ ] Understand that values are immutable by default
- [ ] Understand that the last expression is automatically returned

---

## 🚀 Ready to Code!

Now open `bin/main.ml` and implement your solution. Remember:
- Start simple
- Test early and often with `dune exec`
- Use `dune test` to verify correctness
- Don't be afraid to experiment!

Good luck! 🎉

