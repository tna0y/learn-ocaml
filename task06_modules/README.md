# Task 6: Modules and Functors

Welcome to Task 6, the final task in Module A! You've learned the fundamentals—now it's time to explore OCaml's most distinctive feature: the **module system**. Modules let you organize code, create namespaces, and write generic, reusable components using **functors**.

By the end of this task, you'll understand modules, signatures, and functors, and you'll implement a generic `Rational` number library.

---

## 🎯 Learning Goals

- Understand OCaml's module system
- Create modules and module signatures
- Use functors to parameterize modules
- Implement a `Rational` number type
- Compare modules with constructs in other languages

---

## 📚 Theory: Modules and Functors

### What Are Modules?

A module is a collection of definitions (types, values, functions) grouped under a namespace:

```ocaml
module Math = struct
  let pi = 3.14159
  let square x = x * x
end

(* Usage *)
let area r = Math.pi *. Math.square r
```

**Comparison with other languages:**
- **C++**: Namespaces
- **Python**: Modules/packages
- **Java**: Packages and classes
- **Rust**: Modules (`mod`)
- **OCaml**: First-class modules (much more powerful!)

### Module Signatures

A signature specifies what a module exposes:

```ocaml
module type MATH = sig
  val pi : float
  val square : float -> float
end

module Math : MATH = struct
  let pi = 3.14159
  let square x = x *. x
  let hidden = 42  (* Not in signature, so private! *)
end
```

**Comparison:**
- **Java**: Interfaces
- **Rust**: Traits (somewhat similar)
- **C++**: Abstract classes / concepts
- **OCaml**: Module signatures (types, not just functions!)

### Functors: Functions on Modules

A **functor** is a function that takes a module and returns a module:

```ocaml
module type ORDERED = sig
  type t
  val compare : t -> t -> int
end

module MakeSet (Ord : ORDERED) = struct
  type t = Ord.t list
  
  let insert x set =
    if List.exists (fun y -> Ord.compare x y = 0) set
    then set
    else x :: set
end

(* Usage *)
module IntOrd = struct
  type t = int
  let compare = compare
end

module IntSet = MakeSet(IntOrd)
```

**Comparison:**
- **C++**: Templates (but checked at instantiation)
- **Rust**: Generics with trait bounds (very similar!)
- **Haskell**: Type classes (different mechanism, similar power)
- **Java**: Generics (weaker—can't abstract over implementations)
- **OCaml**: Functors (very powerful!)

### Why Functors?

Functors let you write code that's generic over *implementations*, not just types:

```ocaml
(* Generic over the representation of integers! *)
module MakeRational (Int : INTEGER_OPS) = struct
  type t = { num : Int.t; den : Int.t }
  
  let make n d = 
    let g = Int.gcd n d in
    { num = Int.div n g; den = Int.div d g }
end
```

You could instantiate this with:
- Standard `int`
- Arbitrary-precision integers
- Modular arithmetic integers
- Any type with the right operations!

---

## 📝 Your Task

Implement a **Rational number library** using modules and functors.

### Part 1: Basic Rational Module

In `lib/rational.ml`, implement a module with:

#### Type

```ocaml
type t = { num : int; den : int }
```

Represents a rational number `num/den`.

#### Functions

**1. `make : int -> int -> t`**

Create a rational number in simplified form.

**Examples:**
```ocaml
make 6 9 = { num = 2; den = 3 }  (* simplified *)
make 5 1 = { num = 5; den = 1 }
make 0 5 = { num = 0; den = 1 }
```

**Requirements:**
- Simplify using GCD
- Handle negative numbers: keep sign in numerator
- Raise exception if denominator is zero

**2. `add : t -> t -> t`**

Add two rationals: `a/b + c/d = (ad + bc) / bd`

**Example:**
```ocaml
add (make 1 2) (make 1 3) = make 5 6
```

**3. `mul : t -> t -> t`**

Multiply two rationals: `a/b * c/d = ac / bd`

**Example:**
```ocaml
mul (make 2 3) (make 3 4) = make 1 2
```

**4. `to_string : t -> string`**

Convert to string representation.

**Examples:**
```ocaml
to_string (make 2 3) = "2/3"
to_string (make 5 1) = "5/1" or "5"  (* either is fine *)
```

### Part 2: Functor (Advanced)

Create a functor `MakeRational` that's parameterized over integer operations:

```ocaml
module type INT_OPS = sig
  type t
  val zero : t
  val add : t -> t -> t
  val mul : t -> t -> t
  val div : t -> t -> t
  val gcd : t -> t -> t
  val compare : t -> t -> int
end

module MakeRational (I : INT_OPS) = struct
  type t = { num : I.t; den : I.t }
  (* Implement using I.add, I.mul, etc. *)
end
```

This is optional but highly encouraged for understanding functors!

---

## 🏗️ Building and Running

```bash
dune build
dune test
dune utop
```

In utop:
```ocaml
open Rational;;

let half = make 1 2;;
let third = make 1 3;;
let sum = add half third;;
to_string sum;;  (* "5/6" *)

let product = mul half third;;
to_string product;;  (* "1/6" *)
```

---

## 💡 Common Mistakes

### Mistake 1: Not Simplifying

```ocaml
(* WRONG *)
let add a b =
  { num = a.num * b.den + b.num * a.den;
    den = a.den * b.den }
(* Result: 1/2 + 1/3 = 5/6 ✓, but 2/4 + 1/2 = 8/8 ✗ (not simplified!) *)

(* RIGHT *)
let add a b =
  let num = a.num * b.den + b.num * a.den in
  let den = a.den * b.den in
  let g = gcd num den in
  { num = num / g; den = den / g }
```

### Mistake 2: Wrong GCD Algorithm

```ocaml
(* Euclidean GCD *)
let rec gcd a b =
  if b = 0 then abs a  (* abs to handle negatives *)
  else gcd b (a mod b)
```

### Mistake 3: Sign Handling

```ocaml
(* Keep sign in numerator *)
let make num den =
  if den = 0 then failwith "Denominator cannot be zero";
  let g = gcd num den in
  let num' = num / g in
  let den' = den / g in
  if den' < 0 then { num = -num'; den = -den' }
  else { num = num'; den = den' }
```

---

## 🎓 Going Deeper

### Modules are First-Class

You can pass modules as values (with some syntax):

```ocaml
let module M = MyModule in
M.some_function
```

### Module Type Ascription

```ocaml
module M : SIGNATURE = struct
  (* implementation *)
end
```

This hides anything not in `SIGNATURE`.

### Functors Enable Code Reuse

Instead of duplicating code for `IntSet`, `StringSet`, `FloatSet`, write one functor:

```ocaml
module MakeSet (Ord : ORDERED) = struct
  (* Generic set implementation *)
end

module IntSet = MakeSet(IntOrd)
module StringSet = MakeSet(StringOrd)
```

---

## 🚀 Ready to Code!

Open `lib/rational.ml` and implement the rational number library. Start with `gcd`, then `make`, then the arithmetic operations.

Good luck with the final Module A task! 🎉

