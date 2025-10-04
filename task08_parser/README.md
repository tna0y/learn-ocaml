# Task 8: Parser (Recursive Descent)

Welcome to Task 8! In Task 7, you learned how to work with ASTs. But how do we *create* ASTs from text? That's where **parsing** comes in.

By the end of this task, you'll understand how to build a lexer and parser from scratch using recursive descent, handle operator precedence correctly, and report errors gracefully.

---

## 🎯 Learning Goals

- Understand the two phases: lexing (tokenization) and parsing
- Implement a lexer that converts text to tokens
- Implement recursive descent parsing
- Handle operator precedence through grammar structure
- Use the call stack for parenthesis tracking
- Implement left-associative operators
- Use `result` types for error handling

---

## 📚 Theory: From Text to AST

### The Big Picture

**Parsing** converts unstructured text into structured data (AST):

```
Input:  "1 + 2 * 3"
Output: Add (Int 1, Mul (Int 2, Int 3))
```

We'll implement this in **two phases**:

```
"1 + 2 * 3"  →  Lexer  →  Tokens  →  Parser  →  AST  →  Evaluator  →  6
```

**Why two phases?**
- **Lexer**: Handles low-level details (characters, whitespace, multi-digit numbers)
- **Parser**: Handles high-level structure (precedence, parentheses, AST building)
- **Separation of concerns**: Each phase has one job and does it well

---

## 🔤 Phase 1: Tokenization (Lexer)

### What is a Token?

A **token** is a meaningful unit in your language. Instead of working with individual characters like `'1'`, `' '`, `'+'`, we group them into logical units:

```ocaml
type token =
  | INT of int      (* Numbers: 42, -5, 123 *)
  | PLUS            (* + operator *)
  | MINUS           (* - operator *)
  | TIMES           (* * operator *)
  | DIV             (* / operator *)
  | LPAREN          (* ( *)
  | RPAREN          (* ) *)
  | EOF             (* End of input *)
```

**Example transformation:**
```
Input:  "1 + 2 * 3"
                ↓ Lexer
Tokens: [INT 1; PLUS; INT 2; TIMES; INT 3; EOF]
```

### Why Tokenize First?

| Aspect | Without Lexer | With Lexer |
|--------|--------------|------------|
| Whitespace | Call `skip_ws` everywhere | Handled once in lexer |
| Multi-char tokens | Parse `1`, then `2` → combine | Get `INT 12` directly |
| Errors | "Unexpected char 'x' at position 42" | "Invalid character 'x' at position 42" |
| Parser code | Messy, character-level logic | Clean, pattern match on tokens |
| Extensibility | Hard to add `==`, `<=` | Easy: just add token types |

### How the Lexer Works

The lexer loops through the input string, building a list of tokens:

```ocaml
let rec lex_helper s pos acc =
  (* 1. Skip whitespace *)
  let pos = skip_whitespace s pos in
  
  (* 2. Check if we're done *)
  if pos >= String.length s then
    Ok (List.rev (EOF :: acc))  (* Don't forget to reverse! *)
  
  (* 3. Match the current character *)
  else match s.[pos] with
  | '+' -> lex_helper s (pos + 1) (PLUS :: acc)
  | '*' -> lex_helper s (pos + 1) (TIMES :: acc)
  | '(' -> lex_helper s (pos + 1) (LPAREN :: acc)
  | '0'..'9' -> 
      (* Multi-digit number: keep reading while digits *)
      let (num, new_pos) = parse_integer s pos in
      lex_helper s new_pos (INT num :: acc)
  | '-' ->
      (* Could be minus operator OR negative number *)
      if pos + 1 < String.length s && is_digit s.[pos + 1] then
        let (num, new_pos) = parse_integer s pos in
        lex_helper s new_pos (INT num :: acc)
      else
        lex_helper s (pos + 1) (MINUS :: acc)
  | _ -> Error (Printf.sprintf "Invalid character '%c' at position %d" s.[pos] pos)
```

**Key insight:** Whitespace and character-level details are handled here, once. The parser never sees them!

---

## 🌳 Phase 2: Recursive Descent Parsing

Now that we have tokens, we need to build an AST. **Recursive descent** is a parsing technique where the structure of your code mirrors the structure of your grammar.

### The Grammar

Our grammar defines how expressions are structured:

```
expr   ::= term (('+' | '-') term)*
term   ::= factor (('*' | '/') factor)*
factor ::= INT | '(' expr ')'
```

**Reading the grammar:**
- `expr` is made of one or more `term`s separated by `+` or `-`
- `term` is made of one or more `factor`s separated by `*` or `/`
- `factor` is either a number or an expression in parentheses

### Grammar Encodes Precedence

Notice the hierarchy:
```
expr (lowest precedence)
  ↓ contains
term (medium precedence)
  ↓ contains
factor (highest precedence)
```

This structure **automatically** gives us correct precedence:
- When parsing `expr`, we first parse `term`
- When parsing `term`, we first parse `factor`
- So `factor` binds tightest, then `term` operators (`*`, `/`), then `expr` operators (`+`, `-`)

**Example:** `1 + 2 * 3`
```
expr
├─ term → 1
├─ '+'
└─ term
   ├─ factor → 2
   ├─ '*'
   └─ factor → 3
```
Result: `Add (Int 1, Mul (Int 2, Int 3))` ✓ (multiplication happens first!)

### Grammar Rules → Functions

Each grammar rule becomes a function. The functions are **mutually recursive** because `factor` can contain an `expr` (for parentheses):

```ocaml
(* expr ::= term (('+' | '-') term)* *)
let rec parse_expr tokens = ...

(* term ::= factor (('*' | '/') factor)* *)
and parse_term tokens = ...

(* factor ::= INT | '(' expr ')' *)
and parse_factor tokens = ...
```

Notice `let rec ... and ...` for mutual recursion!

### Parser State: Threading Tokens

Each parser function:
1. Takes a **token list** (what remains to parse)
2. Consumes some tokens
3. Returns **(AST node, remaining tokens)** or an error

```ocaml
parse_expr  : token list -> (expr * token list, string) result
parse_term  : token list -> (expr * token list, string) result
parse_factor: token list -> (expr * token list, string) result
```

**No position tracking needed!** We just pass the remaining token list through.

### The Three Levels of Precedence

Each function handles **only its own operators**. This is what "operator at this level" means:

| Function | Operators | When to Stop |
|----------|-----------|--------------|
| `parse_expr` | `+`, `-` | When you see `*`, `/`, `)`, or `EOF` |
| `parse_term` | `*`, `/` | When you see `+`, `-`, `)`, or `EOF` |
| `parse_factor` | none (just numbers/parens) | After consuming one token/group |

**Key rule:** Each function only "claims" its own operators. When it sees something else, it returns control to its caller.

**Example trace for `"1 + 2 * 3"`:**

Tokens: `[INT 1; PLUS; INT 2; TIMES; INT 3; EOF]`

```
parse_expr([INT 1; PLUS; INT 2; TIMES; INT 3; EOF])
  │
  ├─ Step 1: Parse first term
  │   parse_term([INT 1; PLUS; INT 2; TIMES; INT 3; EOF])
  │     ├─ parse_factor([INT 1; ...]) → Int 1
  │     ├─ Look ahead: next is PLUS (not TIMES/DIV)
  │     └─ Return (Int 1, [PLUS; INT 2; TIMES; INT 3; EOF])
  │
  ├─ Step 2: See PLUS → this is MY operator!
  │   Consume it: [INT 2; TIMES; INT 3; EOF]
  │
  ├─ Step 3: Parse second term
  │   parse_term([INT 2; TIMES; INT 3; EOF])
  │     ├─ parse_factor([INT 2; ...]) → Int 2
  │     ├─ Look ahead: next is TIMES → this is MY operator!
  │     ├─ Consume it: [INT 3; EOF]
  │     ├─ parse_factor([INT 3; EOF]) → Int 3
  │     └─ Return (Mul(Int 2, Int 3), [EOF])
  │
  └─ Step 4: Build result
      Add(Int 1, Mul(Int 2, Int 3))
```

**The magic:** `parse_term` consumed the `*` because multiplication is handled at the "term level". By the time we returned to `parse_expr`, the multiplication was already built into the AST!

### Handling Parentheses with Recursion

Parentheses create nested structure. Here's the beautiful part: **you don't track depth manually** — the call stack does it for you!

```ocaml
let rec parse_factor tokens =
  match tokens with
  | INT n :: rest -> 
      Ok (Int n, rest)  (* Simple case *)
      
  | LPAREN :: rest ->
      (* Parse what's inside the parentheses *)
      match parse_expr rest with  (* Recursive call! *)
      | Error e -> Error e
      | Ok (expr, remaining) ->
          (* Expect closing paren *)
          match remaining with
          | RPAREN :: rest -> Ok (expr, rest)
          | _ -> Error "Expected ')'"
          
  | EOF :: _ -> Error "Expected number or '(' but got EOF"
  | _ -> Error "Expected number or '('"
```

When you see `(`, you call `parse_expr` again. When you see `)`, you return from that call. **The recursion depth = parenthesis depth!**

**Example:** `"(1 + 2) * 3"`

```
parse_expr([LPAREN; INT 1; PLUS; INT 2; RPAREN; TIMES; INT 3; EOF])
  │
  └─> parse_term(...)
        │
        └─> parse_factor([LPAREN; INT 1; PLUS; INT 2; RPAREN; TIMES; INT 3; EOF])
              │
              ├─ Sees LPAREN
              │
              └─> parse_expr([INT 1; PLUS; INT 2; RPAREN; TIMES; INT 3; EOF])  ← Recursion!
                    │ (Now we're "inside" the parentheses)
                    │
                    ├─ Parses "1 + 2" → Add(Int 1, Int 2)
                    └─ Returns (Add(Int 1, Int 2), [RPAREN; TIMES; INT 3; EOF])
              │
              ├─ Back in parse_factor
              ├─ Sees RPAREN → good!
              └─ Returns (Add(Int 1, Int 2), [TIMES; INT 3; EOF])
        │
        ├─ Sees TIMES → multiply!
        ├─ Gets Int 3
        └─ Returns (Mul(Add(Int 1, Int 2), Int 3), [EOF])
```

No counter, no manual tracking. Just recursion!

### The Loop Pattern: Left-Associativity

How do we handle multiple operators at the same level, like `"1 + 2 + 3"`?

We use a **loop** that keeps consuming operators as long as they're at our level:

```ocaml
let rec parse_expr tokens =
  (* Step 1: Parse the first term *)
  match parse_term tokens with
  | Error e -> Error e
  | Ok (left, rest) ->
      (* Step 2: Loop, consuming + and - operators *)
      let rec loop left tokens =
        match tokens with
        | PLUS :: rest ->
            (* Parse next term, build Add node, keep looping *)
            (match parse_term rest with
             | Error e -> Error e
             | Ok (right, rest) -> loop (Add (left, right)) rest)
        
        | MINUS :: rest ->
            (* Parse next term, build Sub node, keep looping *)
            (match parse_term rest with
             | Error e -> Error e
             | Ok (right, rest) -> loop (Sub (left, right)) rest)
        
        | _ -> 
            (* No more + or - operators, we're done *)
            Ok (left, tokens)
      in
      loop left rest
```

This creates **left-associativity**:
```
"1 - 2 - 3" → Sub(Sub(1, 2), 3) → (1 - 2) - 3 = -4 ✓
```

Not `Sub(1, Sub(2, 3)) → 1 - (2 - 3) = 2` ✗

### Error Handling

When things go wrong, return helpful error messages:

```ocaml
match tokens with
| EOF :: _ -> Error "Expected number or '(' but got EOF"
| PLUS :: _ -> Error "Expected number or '(' but got PLUS"
| [] -> Error "Unexpected end of input"
| _ -> Error "Expected number or '('"
```

**Missing `)`:**
```
parse "(1 + 2"
→ parse_expr parses "1 + 2" → (Add(Int 1, Int 2), [EOF])
→ parse_factor expects RPAREN, finds EOF
→ Error "Expected ')'"
```

**Extra `)`:**
```
parse "1 + 2)"
→ parse_expr parses "1 + 2" → (Add(Int 1, Int 2), [RPAREN; EOF])
→ Main parse function checks remaining tokens
→ Expected [EOF] but got [RPAREN; EOF]
→ Error "Unexpected tokens after expression"
```

---

## 📝 Your Task

Implement a lexer and parser for arithmetic expressions in `lib/parser.ml`.

### Types

```ocaml
type expr =
  | Int of int
  | Add of expr * expr
  | Sub of expr * expr
  | Mul of expr * expr
  | Div of expr * expr

type token =
  | INT of int
  | PLUS | MINUS | TIMES | DIV
  | LPAREN | RPAREN
  | EOF
```

### Functions to Implement

#### 1. `lex : string -> (token list, string) result`

Convert a string into a list of tokens.

**Examples:**
```ocaml
lex "42" = Ok [INT 42; EOF]
lex "1 + 2" = Ok [INT 1; PLUS; INT 2; EOF]
lex "1 + 2 * 3" = Ok [INT 1; PLUS; INT 2; TIMES; INT 3; EOF]
lex "(1 + 2) * 3" = Ok [LPAREN; INT 1; PLUS; INT 2; RPAREN; TIMES; INT 3; EOF]
lex "abc" = Error "Invalid character 'a' at position 0"
```

#### 2. `parse : string -> (expr, string) result`

Main parsing function. Lexes and parses a string to an AST.

**Examples:**
```ocaml
parse "42" = Ok (Int 42)
parse "1 + 2" = Ok (Add (Int 1, Int 2))
parse "1 + 2 * 3" = Ok (Add (Int 1, Mul (Int 2, Int 3)))
parse "(1 + 2) * 3" = Ok (Mul (Add (Int 1, Int 2), Int 3))
parse "2 * (3 + 4)" = Ok (Mul (Int 2, Add (Int 3, Int 4)))
parse "1 + " = Error "Expected number or '(' but got EOF"
parse "abc" = Error "Invalid character 'a' at position 0"
```

### Implementation Strategy

#### Phase 1: Implement the Lexer

1. **Whitespace helper**: Skip spaces, tabs, newlines
2. **Integer parsing**: Handle multi-digit numbers (including negatives)
3. **Single-character tokens**: +, -, *, /, (, )
4. **Main loop**: Recursive function with accumulator
5. **Don't forget**: Reverse the accumulator at the end!

#### Phase 2: Implement the Parser

1. **parse_factor**: Handle `INT` tokens and parentheses (with recursive call to `parse_expr`)
2. **parse_term**: Parse factor, then loop for `*` and `/`
3. **parse_expr**: Parse term, then loop for `+` and `-`
4. **parse main**: Call `lex`, then `parse_expr`, check for `EOF`

**Function signatures (work on token lists):**
```ocaml
val parse_factor : token list -> (expr * token list, string) result
val parse_term   : token list -> (expr * token list, string) result
val parse_expr   : token list -> (expr * token list, string) result
```

Each function returns `(result, remaining_tokens)` or an error.

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

(* Try the lexer *)
lex "42";;
lex "1 + 2";;
lex "1 + 2 * 3";;
lex "(1 + 2) * 3";;

(* Try the parser *)
parse "42";;
parse "1 + 2";;
parse "1 + 2 * 3";;
parse "(1 + 2) * 3";;
parse "2 * (3 + 4) - 5";;

(* Try invalid inputs *)
parse "abc";;        (* Lexer error *)
parse "1 +";;        (* Parser error *)
parse "* 2";;        (* Parser error *)
parse "(1 + 2";;     (* Parser error *)
```

---

## 💡 Common Mistakes

### Mistake 1: Forgetting to Reverse Accumulator in Lexer

```ocaml
(* WRONG — tokens are backwards! *)
let rec lex_helper s pos acc =
  if pos >= String.length s then
    Ok (EOF :: acc)  (* Missing List.rev! *)

(* RIGHT *)
let rec lex_helper s pos acc =
  if pos >= String.length s then
    Ok (List.rev (EOF :: acc))
```

### Mistake 2: Wrong Precedence in Parser

```ocaml
(* WRONG — parses "1 + 2 * 3" as "(1 + 2) * 3" *)
let rec parse_expr tokens =
  match parse_factor tokens with  (* Skipped term! *)
    ...

(* RIGHT — delegate to higher precedence first *)
let rec parse_expr tokens =
  match parse_term tokens with  (* term handles * and / *)
    ...
```

### Mistake 3: Not Consuming Tokens in Loop

```ocaml
(* WRONG — infinite loop! *)
let rec loop left tokens =
  match tokens with
  | PLUS :: rest ->
      let (right, rest) = parse_term rest in
      loop (Add (left, right)) rest
  | _ -> loop left tokens  (* Loops forever! *)

(* RIGHT — return when done *)
let rec loop left tokens =
  match tokens with
  | PLUS :: rest ->
      let (right, rest) = parse_term rest in
      loop (Add (left, right)) rest
  | _ -> Ok (left, tokens)  (* Stop *)
```

### Mistake 4: Handling MINUS in Lexer

```ocaml
(* WRONG — treats "-5" as MINUS then INT 5 *)
| '-' -> lex_helper s (pos + 1) (MINUS :: acc)

(* RIGHT — check if it's a negative number *)
| '-' ->
    if pos + 1 < String.length s && is_digit s.[pos + 1] then
      let (num, new_pos) = parse_int s pos in
      lex_helper s new_pos (INT num :: acc)
    else
      lex_helper s (pos + 1) (MINUS :: acc)
```

### Mistake 5: Poor Error Messages

```ocaml
(* BAD *)
Error "Parse error"

(* BETTER *)
Error "Expected number or '('"

(* BEST — show what was found *)
match tokens with
| EOF :: _ -> Error "Expected number or '(' but got EOF"
| PLUS :: _ -> Error "Expected number or '(' but got PLUS"
| _ -> Error "Expected number or '('"
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
- **Parser combinators** (Angstrom in OCaml) — functional, composable
- **Parser generators** (Menhir) — define grammar, generate code
- **PEG parsers** (Parsing Expression Grammars) — alternative formalism

### Left vs Right Associativity

Our loop pattern creates **left-associativity**:
```
"1 - 2 - 3" → Sub(Sub(1, 2), 3) → (1 - 2) - 3 = -4 ✓
```

Right-associative would be:
```
"1 - 2 - 3" → Sub(1, Sub(2, 3)) → 1 - (2 - 3) = 2 ✗
```

For most operators (-, /), left-associativity is correct. For exponentiation (`2^3^4 = 2^(3^4)`), you'd want right-associativity.

### Lexer vs Parser: Why Separate?

| Concern | Lexer | Parser |
|---------|-------|--------|
| **Input** | Characters | Tokens |
| **Output** | Tokens | AST |
| **Handles** | Whitespace, comments, multi-char tokens | Structure, precedence, recursion |
| **Errors** | "Invalid character" | "Expected ')'" |

**Benefits:**
- Each phase has one clear job
- Easier to test (test lexer and parser separately)
- Easier to extend (add keywords? just update lexer)
- Cleaner code (no character-level logic in parser)

This is standard practice in compiler design!

---

## 🚀 Ready to Code!

Open `lib/parser.ml` and implement your lexer and parser.

**Suggested order:**
1. **Lexer first** — Start simple (just integers and `+`), then add more
2. **Test lexer** — `dune test` to run lexer tests
3. **Parser** — Implement `parse_factor`, then `parse_term`, then `parse_expr`
4. **Test parser** — `dune test` to run full test suite

**Tips:**
- **Lexer**: Use recursive helper with accumulator, don't forget `List.rev`
- **Parser**: Each function delegates to the next level, then loops for its own operators
- **Both**: Write helpful error messages from the start
- **Test incrementally!** Don't try to implement everything at once

Good luck! 🎉