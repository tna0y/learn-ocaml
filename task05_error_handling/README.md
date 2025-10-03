# Task 5: Option/Result and Error Handling

Welcome to Task 5! In most languages, errors are handled with exceptions or null pointers. OCaml takes a different approach: **explicit error types** using `option` and `result`. This makes error handling type-safe and forces you to handle errors explicitly.

By the end of this task, you'll understand how to use `option` and `result` types, pattern match on errors, and write robust code without exceptions.

---

## 🎯 Learning Goals

- Understand the `option` type and its use cases
- Master the `result` type for error handling
- Pattern match on success/failure cases
- Avoid exceptions in favor of explicit errors
- Compare with error handling in other languages

---

## 📚 Theory: Option and Result Types

### The `option` Type

The `option` type represents a value that might be absent:

```ocaml
type 'a option =
  | None
  | Some of 'a
```

**Use case:** Functions that might not return a value.

```ocaml
let find_in_list x list =
  (* Returns Some x if found, None otherwise *)
  ...
```

**Comparison with other languages:**
- **C**: `NULL` pointers (unsafe!)
- **Python**: `None` (not type-safe!)
- **Java**: `Optional<T>` (similar!)
- **Rust**: `Option<T>` (identical!)
- **Haskell**: `Maybe a` (same concept!)
- **OCaml**: `'a option`

### Pattern Matching on option

```ocaml
match parse_int "42" with
| None -> print_endline "Not a number"
| Some n -> Printf.printf "Got %d\n" n
```

**Benefits over null:**
- **Type-safe**: Can't forget to check
- **Explicit**: Caller must handle both cases
- **No null pointer exceptions**: Compiler forces you to handle `None`

### The `result` Type

The `result` type represents success or failure with error information:

```ocaml
type ('ok, 'error) result =
  | Ok of 'ok
  | Error of 'error
```

**Use case:** Operations that can fail with specific error messages.

```ocaml
let divide a b =
  if b = 0 then Error "Division by zero"
  else Ok (a / b)
```

**Comparison with other languages:**
- **C**: Return error codes (easy to ignore!)
- **Python**: Exceptions (can be forgotten!)
- **Java**: Checked exceptions (verbose!)
- **Rust**: `Result<T, E>` (identical!)
- **Haskell**: `Either a b` (same concept!)
- **Go**: `(value, error)` tuple (similar!)
- **OCaml**: `('a, 'error) result`

### Pattern Matching on result

```ocaml
match divide 10 2 with
| Ok value -> Printf.printf "Result: %d\n" value
| Error msg -> Printf.printf "Error: %s\n" msg
```

### When to Use option vs result

| Type | Use When |
|------|----------|
| **option** | Absence of value is self-explanatory (e.g., search not found) |
| **result** | Need to explain *why* operation failed (e.g., parse error with message) |

**Examples:**
```ocaml
val find : 'a -> 'a list -> 'a option
(* None clearly means "not found" *)

val parse_int : string -> (int, string) result
(* Error "invalid digit at position 3" is helpful *)
```

### Avoiding Exceptions

In OCaml, exceptions exist but are discouraged for control flow:

```ocaml
(* BAD: Using exceptions *)
let parse_int s =
  try int_of_string s
  with Failure _ -> 0  (* Silent failure! *)

(* GOOD: Using result *)
let parse_int s =
  try Ok (int_of_string s)
  with Failure msg -> Error msg
```

**Why avoid exceptions?**
- Not tracked in types (caller might not know function can throw)
- Can be forgotten (no compiler error)
- Break control flow (harder to reason about)

**Comparison:**
- **Java**: Checked exceptions (tracked, but verbose)
- **Python/Ruby**: Exceptions encouraged (risky!)
- **Rust**: No exceptions, only `Result` (like OCaml style)
- **Go**: Explicit error returns (similar philosophy)

### Chaining Operations

You can chain operations that return `option` or `result`:

```ocaml
(* Helper: Option.bind *)
let (let*) opt f =
  match opt with
  | None -> None
  | Some x -> f x

(* Usage *)
let process s =
  let* n = parse_int s in        (* None if parse fails *)
  let* doubled = Some (n * 2) in
  Some (doubled + 1)
```

This is like the "maybe monad" in Haskell or `?` operator in Rust!

---

## 📝 Your Task

Implement the following functions in `lib/error_handling.ml`:

### 1. `parse_int : string -> int option`

Parse a string to an integer. Return `None` if parsing fails.

**Examples:**
```ocaml
parse_int "42" = Some 42
parse_int "-100" = Some (-100)
parse_int "abc" = None
parse_int "12.5" = None
parse_int "" = None
```

**Hint:** Use `int_of_string` wrapped in `try ... with`.

### 2. `safe_div : int -> int -> (int, string) result`

Divide two integers. Return `Error` if divisor is zero.

**Examples:**
```ocaml
safe_div 10 2 = Ok 5
safe_div 7 3 = Ok 2
safe_div 10 0 = Error "Division by zero"
```

### 3. `safe_sqrt : float -> (float, string) result`

Compute square root. Return `Error` for negative numbers.

**Examples:**
```ocaml
safe_sqrt 4.0 = Ok 2.0
safe_sqrt 0.0 = Ok 0.0
safe_sqrt (-1.0) = Error "Cannot take square root of negative number"
```

**Hint:** Use `sqrt` from Stdlib (or `Float.sqrt`).

### 4. `combine_options : 'a option -> 'a option -> 'a option`

Return first `Some` value, or `None` if both are `None`.

**Examples:**
```ocaml
combine_options (Some 5) (Some 10) = Some 5
combine_options None (Some 10) = Some 10
combine_options (Some 5) None = Some 5
combine_options None None = None
```

This is like the `or` operator for optional values!

---

## 🏗️ Building and Running

```bash
dune build
dune test
dune utop
```

In utop:
```ocaml
open Error_handling;;

parse_int "42";;
parse_int "not a number";;
safe_div 10 2;;
safe_div 10 0;;
safe_sqrt 16.0;;
safe_sqrt (-1.0);;
```

---

## 💡 Common Mistakes

### Mistake 1: Returning Wrong option Cases

```ocaml
(* WRONG *)
let parse_int s =
  if s = "42" then Some 42
  else None  (* Only works for "42"! *)

(* RIGHT *)
let parse_int s =
  try Some (int_of_string s)
  with Failure _ -> None
```

### Mistake 2: Silently Ignoring Errors

```ocaml
(* BAD *)
match safe_div 10 0 with
| Ok n -> n
| Error _ -> 0  (* Hides the error! *)

(* BETTER *)
match safe_div 10 0 with
| Ok n -> Printf.printf "Result: %d\n" n
| Error msg -> Printf.printf "Error: %s\n" msg
```

### Mistake 3: Using Exceptions Instead of result

```ocaml
(* BAD *)
let safe_div a b =
  if b = 0 then raise (Failure "Division by zero")
  else a / b

(* GOOD *)
let safe_div a b =
  if b = 0 then Error "Division by zero"
  else Ok (a / b)
```

### Mistake 4: Forgetting to Handle None

```ocaml
(* Type error - must handle both cases *)
let get_value opt =
  match opt with
  | Some x -> x
  (* Missing None case! Compiler error. *)
```

---

## 🎓 Going Deeper

### The Billion Dollar Mistake

Tony Hoare (inventor of null references) called it his "billion dollar mistake":
> "I couldn't resist the temptation to put in a null reference, simply because it was so easy to implement... This has led to innumerable errors, vulnerabilities, and system crashes."

OCaml's `option` type prevents this entire class of bugs!

### Railway-Oriented Programming

Think of `result` as railway tracks:
- **Ok track**: Success path
- **Error track**: Failure path

Operations either stay on the success track or switch to error track:

```ocaml
let process input =
  input
  |> parse
  |> Result.bind validate
  |> Result.bind transform
  |> Result.bind save
```

One error anywhere switches to error track for the rest!

### Total vs Partial Functions

```ocaml
(* Partial function - can fail *)
val head : 'a list -> 'a  (* What if list is empty? *)

(* Total function - always succeeds *)
val head : 'a list -> 'a option  (* Returns None for empty list *)
```

OCaml encourages total functions through `option`/`result`.

---

## ✅ Checklist

- [ ] Understand `option` type and when to use it
- [ ] Understand `result` type for errors with messages
- [ ] Can pattern match on `Some`/`None` and `Ok`/`Error`
- [ ] Know how to wrap exceptions in `option`/`result`
- [ ] Understand benefits over exceptions and null
- [ ] Can chain operations with `option`/`result`

---

## 🚀 Ready to Code!

Open `lib/error_handling.ml` and implement the functions. Remember to use `try ... with` to catch exceptions and convert them to `option`/`result`.

Good luck! 🎉

