# Task 8: Parser (Recursive Descent)

Welcome to Task 8! In Task 7, you learned how to work with ASTs. But how do we *create* ASTs from text? That's where **parsing** comes in.

By the end of this task, you'll understand how to build a parser from scratch using recursive descent, handle operator precedence, and report errors gracefully.

---

## 🎯 Learning Goals

- Understand the role of parsers in compilers
- Implement recursive descent parsing
- Handle operator precedence correctly
- Use `result` types for parser errors
- Parse expressions like `"1 + 2 * (3 - 4)"` into ASTs

---

## 📚 Theory: Parsing

### What is Parsing?

**Parsing** converts text into structured data (AST):

```
Input:  "1 + 2 * 3"
Output: Add (Int 1, Mul (Int 2, Int 3))
```

The complete compiler pipeline:
```
"1 + 2 * 3"  →  Lexer  →  Tokens  →  Parser  →  AST  →  Evaluator  →  6
```

For this task, we'll combine lexing and parsing into one phase (a simplified approach).

### Recursive Descent Parsing

**Recursive descent** is a top-down parsing technique where each grammar rule becomes a function.

**Grammar for arithmetic expressions:**
```
expr   ::= term (('+' | '-') term)*
term   ::= factor (('*' | '/') factor)*
factor ::= number | '(' expr ')'
```

**Key insight:** This grammar encodes precedence!
- `expr` has lowest precedence (+ and -)
- `term` has higher precedence (* and /)
- `factor` has highest precedence (numbers and parentheses)

**Example parse of `1 + 2 * 3`:**
```
expr
├─ term          → 1
├─ '+'
└─ term
   ├─ factor     → 2
   ├─ '*'
   └─ factor     → 3
```

Result: `Add (Int 1, Mul (Int 2, Int 3))` ✓

### Grammar to Functions

Each grammar rule becomes a function:

```ocaml
(* expr ::= term (('+' | '-') term)* *)
let rec parse_expr input = ...

(* term ::= factor (('*' | '/') factor)* *)
and parse_term input = ...

(* factor ::= number | '(' expr ')' *)
and parse_factor input = ...
```

Notice `let rec ... and ...` for mutual recursion!

### Handling Input

We'll use a simple approach: strings with position tracking.

```ocaml
type parser_state = {
  input: string;
  pos: int;
}
```

Helper functions:
- `peek`: Look at current character without consuming
- `advance`: Move to next character
- `skip_whitespace`: Skip spaces
- `parse_int`: Parse an integer

### Error Handling with result

Parsers can fail! Use `result` for errors:

```ocaml
type error = string  (* Simple error messages for now *)

let parse_expr input =
  match ... with
  | Ok ast -> Ok ast
  | Error msg -> Error msg
```

**Example errors:**
- `"Expected ')'"` at position 5
- `"Unexpected character 'x'"` at position 3
- `"Expected number"` at position 0

### Operator Precedence

Why does the grammar work?

```
Input: "1 + 2 * 3"

parse_expr calls parse_term:
  parse_term sees "1", returns Int 1
parse_expr sees "+", continues:
  parse_term for "2 * 3":
    parse_factor sees "2", returns Int 2
    sees "*", continues
    parse_factor sees "3", returns Int 3
    returns Mul (Int 2, Int 3)
parse_expr returns Add (Int 1, Mul (Int 2, Int 3))
```

The structure of recursive calls enforces precedence!

---

## 📝 Your Task

Implement a parser for arithmetic expressions in `lib/parser.ml`.

### Expression Type

Reuse from Task 7:
```ocaml
type expr =
  | Int of int
  | Add of expr * expr
  | Sub of expr * expr
  | Mul of expr * expr
  | Div of expr * expr
```

### Functions to Implement

#### 1. `parse : string -> (expr, string) result`

Main parsing function. Parse a string to an AST.

**Examples:**
```ocaml
parse "42" = Ok (Int 42)
parse "1 + 2" = Ok (Add (Int 1, Int 2))
parse "1 + 2 * 3" = Ok (Add (Int 1, Mul (Int 2, Int 3)))
parse "(1 + 2) * 3" = Ok (Mul (Add (Int 1, Int 2), Int 3))
parse "2 * (3 + 4)" = Ok (Mul (Int 2, Add (Int 3, Int 4)))
parse "1 + " = Error "Expected number or '('"
parse "1 +" = Error "Expected number or '('"
```

### Implementation Strategy

1. **Start simple**: Parse just integers
2. **Add operators**: Handle +, -, *, /
3. **Handle precedence**: Use expr/term/factor structure
4. **Add parentheses**: Allow grouping
5. **Error handling**: Return helpful error messages

**Suggested helper functions:**
```ocaml
(* Skip whitespace at current position *)
val skip_ws : string -> int -> int

(* Parse an integer starting at position *)
val parse_int : string -> int -> (int * int, string) result

(* Parse a factor (number or parenthesized expression) *)
val parse_factor : string -> int -> (expr * int, string) result

(* Parse a term (multiplication/division) *)
val parse_term : string -> int -> (expr * int, string) result

(* Parse an expression (addition/subtraction) *)
val parse_expr : string -> int -> (expr * int, string) result
```

Each function returns `(result * new_position)` or an error.

---

## 🏗️ Building and Running

```bash
dune build
dune test
dune utop
```

In utop:
```ocaml
open Parser;;

parse "42";;
parse "1 + 2";;
parse "1 + 2 * 3";;
parse "(1 + 2) * 3";;
parse "2 * (3 + 4) - 5";;

(* Try invalid inputs *)
parse "1 +";;
parse "* 2";;
parse "(1 + 2";;
```

---

## 💡 Common Mistakes

### Mistake 1: Wrong Precedence

```ocaml
(* WRONG — parses "1 + 2 * 3" as "(1 + 2) * 3" *)
let rec parse_expr input pos =
  (* Handles * before + — backwards! *)
  ...

(* RIGHT — expr handles + and -, term handles * and / *)
let rec parse_expr input pos =
  parse_term input pos  (* Delegate to higher precedence first *)
```

### Mistake 2: Not Consuming Input

```ocaml
(* WRONG — infinite loop! *)
let rec parse_expr input pos =
  let (left, pos') = parse_term input pos in
  parse_expr input pos'  (* Still at same position! *)

(* RIGHT — check for operator first *)
let rec parse_expr input pos =
  let (left, pos') = parse_term input pos in
  if peek input pos' = '+' then
    parse_expr input (pos' + 1)  (* Consume the '+' *)
  else
    (left, pos')
```

### Mistake 3: Forgetting Whitespace

```ocaml
(* Input: "1 + 2" with spaces *)

(* WRONG — fails on spaces *)
if input.[pos] = '+' then ...

(* RIGHT — skip whitespace first *)
let pos = skip_ws input pos in
if pos < String.length input && input.[pos] = '+' then ...
```

### Mistake 4: Poor Error Messages

```ocaml
(* BAD *)
Error "Parse error"

(* BETTER *)
Error (Printf.sprintf "Expected number at position %d" pos)

(* BEST *)
Error (Printf.sprintf "Expected number or '(' at position %d, got '%c'" 
  pos input.[pos])
```

---

## 🎓 Going Deeper

### Why Recursive Descent?

**Pros:**
- Easy to understand and implement
- Each grammar rule = one function
- Good error messages possible
- No external tools needed

**Cons:**
- Can't handle left recursion directly
- Can be slow for complex grammars
- Manual precedence handling

**Alternatives:**
- **Parser combinators** (Parsec, Angstrom in OCaml)
- **Parser generators** (yacc, menhir)
- **PEG parsers** (Parsing Expression Grammars)

### Left vs Right Associativity

Our grammar makes operators left-associative:
```
"1 - 2 - 3" → Sub (Sub (Int 1, Int 2), Int 3) → (1 - 2) - 3 = -4
```

Right-associative would be:
```
"1 - 2 - 3" → Sub (Int 1, Sub (Int 2, Int 3)) → 1 - (2 - 3) = 2
```

For -, left-associative is correct!

### The Role of Lexing

We skipped lexing (tokenization) and parse characters directly. Real parsers have:

```
Text → Lexer → Tokens → Parser → AST
```

**Lexer** converts `"1 + 2"` to `[INT 1, PLUS, INT 2]`
**Parser** builds AST from tokens

Separating these makes parsers cleaner.

---

## 🚀 Ready to Code!

Open `lib/parser.ml` and implement your recursive descent parser. Start with parsing integers, then add operators one at a time, and finally handle parentheses.

Remember:
- expr → term → factor (precedence order)
- Skip whitespace liberally
- Return helpful error messages
- Test incrementally!

Good luck! 🎉

