# Task 13: Ecosystem I - Dependencies, Tests, and Formatting

Welcome to Task 13, the first task in Module E! Unlike previous tasks, **you will build this project from scratch**. This task teaches you the real-world OCaml development workflow: creating projects, managing dependencies, setting up isolated environments, writing comprehensive tests, and formatting code professionally.

By the end of this task, you'll understand how to set up a complete OCaml project using industry-standard tools and practices.

---

## 🎯 Learning Goals

- Create OCaml projects with `dune` from scratch
- Manage dependencies with `opam`
- Set up isolated development environments (opam switches)
- Write module interfaces (`.mli` files)
- Organize code into separate modules/libraries
- Write unit tests with `alcotest`
- Write property-based tests with `qcheck`
- Format code automatically with `ocamlformat`
- Understand module dependencies and project structure

---

## 📚 Theory: The OCaml Ecosystem

### Project Structure

A typical OCaml project with multiple libraries:
```
project_name/
├── dune-project          # Project metadata
├── project_name.opam     # Dependency specification (auto-generated)
├── lib_name1/            # First library
│   ├── dune              # Build config for this library
│   ├── module1.ml
│   └── module1.mli       # Interface (signature)
├── lib_name2/            # Second library
│   ├── dune
│   ├── module2.ml
│   └── module2.mli
├── bin/                  # Executables
│   ├── dune
│   └── main.ml
└── test/                 # Tests
    ├── dune
    └── test_project.ml
```

### The Tools

**dune** - Build system
- Compiles OCaml code
- Manages dependencies between modules and libraries
- Runs tests
- Generates documentation

**opam** - Package manager
- Installs OCaml libraries
- Manages multiple OCaml versions (switches)
- Handles dependencies automatically

**alcotest** - Unit testing framework
- Write test cases with assertions
- Group tests into suites
- Clear error reporting

**qcheck** - Property-based testing
- Generate random test inputs
- Verify properties hold for all inputs
- Find edge cases automatically

**ocamlformat** - Code formatter
- Enforces consistent style
- Automatic formatting
- Configurable rules

### Opam Switches

An **opam switch** is an isolated OCaml environment:

```bash
# Create a new switch (uses current default OCaml version)
opam switch create calculator

# Or specify a version if needed
opam switch create calculator 5.1.0

# Each switch has its own:
# - OCaml compiler version
# - Installed packages
# - Configuration
```

**Why use switches?**
- Different projects may need different OCaml versions
- Isolate dependencies (like Python virtualenv or Node nvm)
- Experiment without breaking other projects

### Module Interfaces (.mli files)

An `.mli` file defines a module's **public interface**:

```ocaml
(* parser.mli - What users can see *)
type expr = Int of int | Add of expr * expr
val parse : string -> (expr, string) result
```

The `.ml` file contains the **implementation**:

```ocaml
(* parser.ml - Implementation details *)
type expr = Int of int | Add of expr * expr

(* Helper functions - not visible outside *)
let is_digit c = c >= '0' && c <= '9'

(* Public function *)
let parse s = ...
```

**Benefits:**
- Hide implementation details
- Document public API
- Enable separate compilation
- Catch interface violations at compile time

### Multi-Library Projects

Large projects often split into multiple libraries:

```
calculator/
├── ast/          # Shared type definitions
├── parser/       # Parsing logic (depends on ast)
├── evaluator/    # Evaluation logic (depends on ast)
└── calculator/   # High-level API (depends on all)
```

Each library has its own `dune` file specifying dependencies.

### Property-Based Testing

**Unit tests** check specific cases:
```ocaml
let test_addition () =
  Alcotest.(check int) "2 + 3 = 5" 5 (calculate "2 + 3")
```

**Property tests** check general properties:
```ocaml
let test_parse_int_property =
  QCheck.Test.make ~count:100 
    (QCheck.small_int)
    (fun n ->
      let s = string_of_int n in
      calculate s = n)
```

QCheck generates 100 random integers and verifies the property holds!

### Code Formatting

**ocamlformat** ensures consistent style:

```bash
# Format all files in project
dune build @fmt --auto-promote
```

**Configuration** (`.ocamlformat` file):
```
profile = default
margin = 100
```

---

## 📝 Your Task

Build a **calculator project** from scratch with four separate libraries that parse and evaluate arithmetic expressions.

### Part 1: Project Setup

#### Step 1: Create Opam Switch

```bash
cd task13_ecosystem
opam switch create calculator
eval $(opam env)
```

This creates an isolated environment for this project using your current OCaml version.

#### Step 2: Initialize Dune Project

```bash
dune init project calculator
```

This creates the basic structure with `dune-project` file.

#### Step 3: Install Dependencies

```bash
opam install dune alcotest qcheck ocamlformat
```

**Required dependencies:**
- `dune` - build system
- `alcotest` - unit testing
- `qcheck` - property testing
- `ocamlformat` - code formatting

### Part 2: Create Library Structure

Create four separate libraries in your project:

```bash
mkdir -p ast parser evaluator calculator
```

Each directory will be a separate library.

### Part 3: Implement Libraries

#### Library 1: `ast` - Shared Type Definitions

**Purpose:** Define the expression AST type that all other libraries depend on

**Files to create:**
- `ast/dune`
- `ast/ast.ml`
- `ast/ast.mli`

**ast/dune:**
```lisp
(library
 (name ast))
```

**ast/ast.mli:**
```ocaml
(** Abstract Syntax Tree for arithmetic expressions *)

type expr =
  | Int of int
  | Add of expr * expr
  | Sub of expr * expr
  | Mul of expr * expr
  | Div of expr * expr
```

**ast/ast.ml:**
```ocaml
type expr =
  | Int of int
  | Add of expr * expr
  | Sub of expr * expr
  | Mul of expr * expr
  | Div of expr * expr
```

#### Library 2: `parser` - String to AST

**Purpose:** Parse strings into expression ASTs

**Files to create:**
- `parser/dune`
- `parser/parser.ml`
- `parser/parser.mli`

**parser/dune:**
```lisp
(library
 (name parser)
 (libraries ast))
```

**parser/parser.mli:**

You must create this interface that exposes only the public API:

```ocaml
(** Parse string to expression AST *)
val parse : string -> (Ast.expr, string) result
(** Parse string into expression.
    Returns Ok expr on success, Error msg on parse failure. *)
```

**parser/parser.ml:**

Implementation provided - copy this:

```ocaml
(** Helper: skip whitespace *)
let skip_whitespace s pos =
  let rec skip p =
    if p >= String.length s then p
    else match s.[p] with
      | ' ' | '\t' | '\n' | '\r' -> skip (p + 1)
      | _ -> p
  in
  skip pos

(** Helper: check if character is digit *)
let is_digit c = c >= '0' && c <= '9'

(** Helper: parse integer at position *)
let parse_int s pos =
  let pos = skip_whitespace s pos in
  if pos >= String.length s then
    Error ("Expected number at position " ^ string_of_int pos)
  else
    let start = pos in
    let rec parse_digits p =
      if p >= String.length s || not (is_digit s.[p]) then p
      else parse_digits (p + 1)
    in
    let end_pos = parse_digits pos in
    if end_pos = start then
      Error ("Expected number at position " ^ string_of_int pos)
    else
      let num_str = String.sub s start (end_pos - start) in
      Ok (int_of_string num_str, end_pos)

(** Parse expression with operator precedence *)
let parse s =
  let rec parse_expr s pos =
    parse_term s pos
  
  and parse_term s pos =
    match parse_factor s pos with
    | Error e -> Error e
    | Ok (left, pos) ->
        let pos = skip_whitespace s pos in
        if pos >= String.length s then Ok (left, pos)
        else match s.[pos] with
          | '+' ->
              (match parse_term s (pos + 1) with
               | Error e -> Error e
               | Ok (right, pos) -> Ok (Ast.Add (left, right), pos))
          | '-' ->
              (match parse_term s (pos + 1) with
               | Error e -> Error e
               | Ok (right, pos) -> Ok (Ast.Sub (left, right), pos))
          | _ -> Ok (left, pos)
  
  and parse_factor s pos =
    match parse_primary s pos with
    | Error e -> Error e
    | Ok (left, pos) ->
        let pos = skip_whitespace s pos in
        if pos >= String.length s then Ok (left, pos)
        else match s.[pos] with
          | '*' ->
              (match parse_factor s (pos + 1) with
               | Error e -> Error e
               | Ok (right, pos) -> Ok (Ast.Mul (left, right), pos))
          | '/' ->
              (match parse_factor s (pos + 1) with
               | Error e -> Error e
               | Ok (right, pos) -> Ok (Ast.Div (left, right), pos))
          | _ -> Ok (left, pos)
  
  and parse_primary s pos =
    let pos = skip_whitespace s pos in
    if pos >= String.length s then
      Error ("Unexpected end of input at position " ^ string_of_int pos)
    else match s.[pos] with
      | '(' ->
          (match parse_expr s (pos + 1) with
           | Error e -> Error e
           | Ok (expr, pos) ->
               let pos = skip_whitespace s pos in
               if pos >= String.length s || s.[pos] <> ')' then
                 Error ("Expected ')' at position " ^ string_of_int pos)
               else
                 Ok (expr, pos + 1))
      | _ ->
          (match parse_int s pos with
           | Error e -> Error e
           | Ok (n, pos) -> Ok (Ast.Int n, pos))
  in
  match parse_expr s 0 with
  | Error e -> Error e
  | Ok (expr, pos) ->
      let pos = skip_whitespace s pos in
      if pos < String.length s then
        Error ("Unexpected character at position " ^ string_of_int pos)
      else
        Ok expr
```

#### Library 3: `evaluator` - Evaluate AST

**Purpose:** Evaluate expressions to integers

**Files to create:**
- `evaluator/dune`
- `evaluator/evaluator.ml`
- `evaluator/evaluator.mli`

**evaluator/dune:**
```lisp
(library
 (name evaluator)
 (libraries ast))
```

**evaluator/evaluator.mli:**

You must create this interface:

```ocaml
(** Evaluate expression to integer *)
val eval : Ast.expr -> int
(** Evaluate expression and return result.
    Raises Division_by_zero if dividing by zero. *)
```

**evaluator/evaluator.ml:**

Implementation provided - copy this:

```ocaml
(** Evaluate expression to integer *)
let rec eval = function
  | Ast.Int n -> n
  | Ast.Add (e1, e2) -> eval e1 + eval e2
  | Ast.Sub (e1, e2) -> eval e1 - eval e2
  | Ast.Mul (e1, e2) -> eval e1 * eval e2
  | Ast.Div (e1, e2) -> eval e1 / eval e2
```

#### Library 4: `calculator` - High-Level API

**Purpose:** Combine parsing and evaluation into a simple API

**Files to create:**
- `calculator/dune`
- `calculator/calculator.ml`
- `calculator/calculator.mli`

**calculator/dune:**
```lisp
(library
 (name calculator)
 (libraries ast parser evaluator))
```

**calculator/calculator.mli:**

You must create this interface:

```ocaml
(** Calculate result from string expression *)
val calculate : string -> int
(** Parse and evaluate string expression.
    Returns the computed result.
    Raises Failure on parse error or Division_by_zero on division by zero. *)
```

**calculator/calculator.ml:**

You must implement from scratch:

```ocaml
let calculate s =
  match Parser.parse s with
  | Ok expr -> Evaluator.eval expr
  | Error msg -> failwith msg
```

### Part 4: Write Comprehensive Tests

Create `test/test_calculator.ml` with comprehensive tests.

**test/dune:**
```lisp
(test
 (name test_calculator)
 (libraries ast parser evaluator calculator alcotest qcheck))
```

#### Required Unit Tests (using Alcotest)

Write **at least 15 unit tests** covering:

**Parser tests (≥5):**
1. Simple integer: `parse "42"`
2. Addition: `parse "1 + 2"`
3. Complex nested: `parse "1 + 2 * 3"`
4. Parentheses: `parse "(1 + 2) * 3"`
5. Error case: `parse "abc"` should return Error

**Evaluator tests (≥5):**
1. Simple integer: `eval (Int 42)`
2. Addition: `eval (Add (Int 1, Int 2))`
3. Subtraction: `eval (Sub (Int 5, Int 3))`
4. Multiplication: `eval (Mul (Int 2, Int 3))`
5. Division: `eval (Div (Int 6, Int 2))`
6. Nested: `eval (Mul (Add (Int 1, Int 2), Int 3))`

**Calculator tests (≥5):**
1. Simple: `calculate "42"`
2. Addition: `calculate "1 + 2"`
3. Complex: `calculate "1 + 2 * 3"`
4. Parentheses: `calculate "(1 + 2) * 3"`
5. Whitespace: `calculate "  1  +  2  "`

#### Required Property Tests (using QCheck)

Write **at least 3 property-based tests**:

1. **Parse-calculate integers:**
   ```ocaml
   (* Property: parsing and calculating an int should work *)
   let test_parse_int_property () =
     let test = QCheck.Test.make ~count:100 
       QCheck.small_int
       (fun n ->
         let s = string_of_int n in
         Calculator.calculate s = n)
     in
     QCheck.Test.check_exn test
   ```

2. **Evaluation correctness:**
   ```ocaml
   (* Property: Int n evaluates to n *)
   let test_eval_int_property () =
     let test = QCheck.Test.make ~count:100
       QCheck.small_int
       (fun n -> Evaluator.eval (Ast.Int n) = n)
     in
     QCheck.Test.check_exn test
   ```

3. **Addition commutativity:**
   ```ocaml
   (* Property: a + b = b + a *)
   let test_add_commutative () =
     let test = QCheck.Test.make ~count:100
       QCheck.(pair small_int small_int)
       (fun (a, b) ->
         let e1 = Ast.Add (Ast.Int a, Ast.Int b) in
         let e2 = Ast.Add (Ast.Int b, Ast.Int a) in
         Evaluator.eval e1 = Evaluator.eval e2)
     in
     QCheck.Test.check_exn test
   ```

**Example test structure:**

```ocaml
(* Example test file structure *)

(* Parser tests *)
let test_parse_int () =
  match Parser.parse "42" with
  | Ok (Ast.Int 42) -> ()
  | _ -> Alcotest.fail "Failed to parse 42"

let test_parse_add () =
  match Parser.parse "1 + 2" with
  | Ok (Ast.Add (Ast.Int 1, Ast.Int 2)) -> ()
  | _ -> Alcotest.fail "Failed to parse 1 + 2"

(* Evaluator tests *)
let test_eval_int () =
  Alcotest.(check int) "eval 42" 42 (Evaluator.eval (Ast.Int 42))

let test_eval_add () =
  let e = Ast.Add (Ast.Int 1, Ast.Int 2) in
  Alcotest.(check int) "eval 1 + 2" 3 (Evaluator.eval e)

(* Calculator tests *)
let test_calculate () =
  Alcotest.(check int) "calculate 1 + 2" 3 (Calculator.calculate "1 + 2")

(* Property tests *)
let test_parse_int_property () =
  let test = QCheck.Test.make ~count:100
    QCheck.small_int
    (fun n ->
      let s = string_of_int n in
      Calculator.calculate s = n)
  in
  QCheck.Test.check_exn test

(* Test suite *)
let () =
  let open Alcotest in
  run "Calculator" [
    "parser", [
      test_case "parse int" `Quick test_parse_int;
      test_case "parse add" `Quick test_parse_add;
      (* Add more parser tests... *)
    ];
    "evaluator", [
      test_case "eval int" `Quick test_eval_int;
      test_case "eval add" `Quick test_eval_add;
      (* Add more evaluator tests... *)
    ];
    "calculator", [
      test_case "calculate" `Quick test_calculate;
      (* Add more calculator tests... *)
    ];
    "properties", [
      test_case "parse int property" `Quick test_parse_int_property;
      (* Add more property tests... *)
    ];
  ]
```

### Part 5: Main Executable

Create `bin/main.ml`:

**bin/dune:**
```lisp
(executable
 (public_name calculator)
 (name main)
 (libraries calculator))
```

**bin/main.ml:**
```ocaml
let () =
  if Array.length Sys.argv < 2 then
    print_endline "Usage: calculator <expression>"
  else
    let expr = Sys.argv.(1) in
    try
      let result = Calculator.calculate expr in
      print_endline (string_of_int result)
    with
    | Failure msg -> 
        Printf.eprintf "Error: %s\n" msg;
        exit 1
    | Division_by_zero ->
        Printf.eprintf "Error: Division by zero\n" msg;
        exit 1
```

### Part 6: Code Formatting

#### Step 1: Create `.ocamlformat` configuration

Create `.ocamlformat` in project root:
```
profile = default
margin = 100
```

#### Step 2: Format your code

```bash
# Format all OCaml files
dune build @fmt --auto-promote
```

---

## 🏗️ Development Workflow

### 1. Build

```bash
dune build
```

### 2. Run Tests

```bash
dune test
```

### 3. Run Executable

```bash
dune exec calculator "2 + 3 * 4"
# Should output: 14
```

### 4. Format Code

```bash
dune build @fmt --auto-promote
```

### 5. Clean Build

```bash
dune clean
```

---

## ✅ Checklist

Your project is complete when:

- [ ] Opam switch created and activated
- [ ] Dependencies installed (alcotest, qcheck, ocamlformat)
- [ ] Four library directories created (ast, parser, evaluator, calculator)
- [ ] `ast/ast.ml` and `ast/ast.mli` created with expr type
- [ ] `parser/parser.ml` and `parser/parser.mli` created
- [ ] `evaluator/evaluator.ml` and `evaluator/evaluator.mli` created
- [ ] `calculator/calculator.ml` and `calculator/calculator.mli` implemented
- [ ] Each library has correct `dune` file with dependencies
- [ ] `test/test_calculator.ml` with ≥15 unit tests
- [ ] At least 3 property-based tests with QCheck
- [ ] `test/dune` configured with all libraries
- [ ] `bin/main.ml` executable created
- [ ] `bin/dune` configured
- [ ] `.ocamlformat` configuration file created
- [ ] All code formatted with `dune build @fmt --auto-promote`
- [ ] `dune build` succeeds
- [ ] `dune test` passes all tests
- [ ] `dune exec calculator "1 + 2"` works

---

## 📂 Expected Final Structure

```
task13_ecosystem/
├── .ocamlformat
├── dune-project
├── calculator.opam (auto-generated)
├── _opam/ (opam switch - auto-created)
├── ast/
│   ├── dune
│   ├── ast.ml
│   └── ast.mli
├── parser/
│   ├── dune
│   ├── parser.ml
│   └── parser.mli
├── evaluator/
│   ├── dune
│   ├── evaluator.ml
│   └── evaluator.mli
├── calculator/
│   ├── dune
│   ├── calculator.ml
│   └── calculator.mli
├── bin/
│   ├── dune
│   └── main.ml
└── test/
    ├── dune
    └── test_calculator.ml
```

---

## 💡 Common Mistakes and Tips

### Module Dependencies

Make sure your `dune` files correctly specify library dependencies:
- `parser` depends on `ast`
- `evaluator` depends on `ast`
- `calculator` depends on `ast`, `parser`, and `evaluator`
- `test` depends on all libraries plus `alcotest` and `qcheck`

### Type Consistency

The `Ast.expr` type must be used consistently across all libraries:
- Parser returns `Ast.expr`
- Evaluator takes `Ast.expr`
- Use `Ast.Int`, `Ast.Add`, etc. in pattern matching

### Interface Files

What to expose in `.mli` files:
- Types users need (but can be defined in ast library)
- Public functions with documentation
- **Do not** expose helper functions

### QCheck Integration

Wrap QCheck tests for Alcotest:
```ocaml
let test_property () =
  let test = QCheck.Test.make (* ... *) in
  QCheck.Test.check_exn test

(* Then add to suite *)
test_case "property name" `Quick test_property;
```

### Error Handling

The `calculate` function should:
- Use `Parser.parse` which returns `result`
- On parse error: raise `Failure` with error message
- On success: call `Evaluator.eval`
- Let division by zero propagate naturally

---

## 🚀 Ready to Build!

This is your first **real** OCaml project with proper module organization! You'll:
- Set up your development environment from scratch
- Organize code into separate libraries
- Manage inter-library dependencies
- Write comprehensive tests
- Use industry-standard formatting tools

Take your time, follow each step carefully, and enjoy building a complete multi-library project!

Good luck! 🎉
