# Task 6: Modules and Functors

Welcome to Task 6, the final task in Module A! You've learned OCaml fundamentals—now it's time to explore OCaml's most powerful and distinctive feature: the **module system**. 

Unlike other tasks, this one is structured as **4 progressive mini-modules**, each teaching one concept hands-on. You'll write actual `.mli` files, create functors, and see how modules enable code organization and reuse.

---

## 🎯 Learning Goals

- Create modules to group related functionality
- Write `.mli` signature files to hide implementation
- Understand abstract vs concrete types
- Implement functors to parameterize over implementations
- Instantiate functors with different module arguments
- See how modules enable code reuse

---

## 📚 Theory: OCaml's Module System

### What Are Modules?

A **module** is a collection of definitions grouped under a namespace:

```ocaml
module Math = struct
  let pi = 3.14159
  let square x = x *. x
  let circle_area r = pi *. square r
end

(* Usage *)
let area = Math.circle_area 5.0
```

**Comparison:**
- **C++**: Namespaces
- **Python**: Modules/files
- **Java**: Packages + classes
- **Rust**: Modules (`mod`)
- **OCaml**: First-class modules (much more powerful!)

### Module Signatures (.mli files)

A **signature** specifies what's visible from outside:

```ocaml
(* stack.mli - the interface *)
type 'a t
val empty : 'a t
val push : 'a -> 'a t -> 'a t
val pop : 'a t -> ('a * 'a t) option

(* stack.ml - the implementation *)
type 'a t = 'a list  (* Implementation hidden! *)
let empty = []
let push x s = x :: s
let pop = function
  | [] -> None
  | x :: xs -> Some (x, xs)
```

Users can't directly access the list—only through your API!

**Benefits:**
1. **Encapsulation**: Hide implementation details
2. **Type safety**: Can't misuse internal representation  
3. **Change freedom**: Swap implementation without breaking clients
4. **Documentation**: Interface is a contract

### Abstract Types

When `.mli` says `type t` without definition, it's **abstract**:

```ocaml
(* Abstract: users can't construct directly *)
type t

(* Concrete: users see the representation *)
type t = int list
```

Abstract types force users to use your API, maintaining invariants.

### Functors: Functions on Modules

A **functor** is a function that takes a module and returns a module:

```ocaml
module type COMPARABLE = sig
  type t
  val compare : t -> t -> int
end

module MakeSet(Elem : COMPARABLE) = struct
  type t = Elem.t list
  
  let insert x set =
    if List.exists (fun y -> Elem.compare x y = 0) set
    then set
    else x :: set
end

(* Use with different types! *)
module IntOrd = struct type t = int let compare = compare end
module IntSet = MakeSet(IntOrd)

module StringOrd = struct type t = string let compare = compare end
module StringSet = MakeSet(StringOrd)
```

**One functor, many instantiations!** This is like C++ templates or Rust generics, but checked at functor definition, not instantiation.

---

## 📝 Your Task: 4 Progressive Mini-Modules

You'll build 4 modules, each demonstrating one concept. Each has its own directory in `lib/`.

### Part 1: Basic Stack Module

**File**: `lib/part1_stack.ml` (and `part1_stack.mli`)

Create a basic stack module with:

```ocaml
type 'a t  (* Stack type - YOU define representation *)
val empty : 'a t
val push : 'a -> 'a t -> 'a t
val pop : 'a t -> ('a * 'a t) option
val peek : 'a t -> 'a option
```

**Requirements:**
- Write BOTH `.ml` and `.mli` files
- In `.mli`: keep `type 'a t` abstract (don't reveal implementation)
- In `.ml`: implement using a list (but users won't know!)
- All operations should be pure (immutable)

**Example usage:**
```ocaml
let s = Stack.empty |> Stack.push 1 |> Stack.push 2;;
Stack.peek s  (* Some 2 *)
Stack.pop s   (* Some (2, <stack with [1]>) *)
```

---

### Part 2: Counter Module with Multiple Signatures

**Files**: `lib/part2_counter.ml`, `part2_counter_full.mli`, `part2_counter_limited.mli`

Implement a counter module, then write **TWO different signatures** for it:

**Implementation** (`counter.ml`) should have:
```ocaml
type t  (* Counter with internal value *)
val create : int -> t
val increment : t -> t
val decrement : t -> t
val get_value : t -> int
val reset : t -> t  (* Resets to 0 *)
```

**Signature 1** (`counter_full.mli`): Expose everything

**Signature 2** (`counter_limited.mli`): Hide `get_value` and `reset`

**Goal**: See how different signatures control access to the same implementation!

---

### Part 3: Generic Queue Functor

**File**: `lib/part3_queue.ml`

Create a functor that makes queues for any element type that can be compared:

```ocaml
module type ELEMENT = sig
  type t
  val to_string : t -> string  (* For debugging/display *)
end

module MakeQueue(E : ELEMENT) : sig
  type t
  val empty : t
  val enqueue : E.t -> t -> t
  val dequeue : t -> (E.t * t) option
  val to_string : t -> string
end = struct
  (* YOU IMPLEMENT THIS *)
end
```

Then create **two instantiations**:
- `IntQueue` using `IntElement`
- `StringQueue` using `StringElement`

**Goal**: Write a functor yourself and see code reuse in action!

---

### Part 4: Ordered Set Functor

**File**: `lib/part4_set.ml`

Create a generic set functor (like OCaml's Set module):

```ocaml
module type ORDERED = sig
  type t
  val compare : t -> t -> int
end

module MakeSet(Ord : ORDERED) : sig
  type t
  val empty : t
  val add : Ord.t -> t -> t
  val mem : Ord.t -> t -> bool
  val to_list : t -> Ord.t list
end = struct
  (* YOU IMPLEMENT THIS *)
end
```

Then create **three instantiations**:
- `IntSet`
- `StringSet`  
- `FloatSet` (careful with float comparison!)

**Goal**: See how one functor works with many types!

---

## 🏗️ Building and Running

```bash
dune build
dune test
dune utop
```

In utop:
```ocaml
open Part1_stack;;
let s = empty |> push 1 |> push 2 |> push 3;;
peek s;;

open Part3_queue;;
module IQ = IntQueue;;
let q = IQ.empty |> IQ.enqueue 5 |> IQ.enqueue 10;;
IQ.dequeue q;;

open Part4_set;;
module IS = IntSet;;
let s = IS.empty |> IS.add 3 |> IS.add 1 |> IS.add 2;;
IS.to_list s;;  (* Should be sorted! *)
```

---

## 💡 Common Mistakes

### Mistake 1: Revealing Implementation in .mli

```ocaml
(* BAD - reveals internal list *)
type 'a t = 'a list

(* GOOD - keeps it abstract *)
type 'a t
```

### Mistake 2: Forgetting Signature in Functor

```ocaml
(* BAD - no signature constraint *)
module MakeQueue(E : ELEMENT) = struct
  (* ... *)
end

(* GOOD - signature ensures interface *)
module MakeQueue(E : ELEMENT) : sig
  type t
  val empty : t
  (* ... *)
end = struct
  (* ... *)
end
```

### Mistake 3: Wrong Module Type Syntax

```ocaml
(* WRONG *)
module type ELEMENT = {
  type t  (* Not OCaml syntax! *)
}

(* RIGHT *)
module type ELEMENT = sig
  type t
end
```

### Mistake 4: Not Using Functor Parameter

```ocaml
(* WRONG - doesn't use E at all! *)
module MakeQueue(E : ELEMENT) = struct
  type t = int list  (* Should use E.t! *)
end

(* RIGHT *)
module MakeQueue(E : ELEMENT) = struct
  type t = E.t list
end
```

---

## 🎓 Going Deeper

### Why OCaml's Module System is Special

**Most languages**: Modules are just namespaces
**OCaml**: Modules are first-class, parameterizable, with strong type checking

Functors are checked at **definition time**, not instantiation:
- **C++ templates**: Errors at instantiation (cryptic messages)
- **Rust generics**: Similar to OCaml (trait bounds)
- **Java generics**: Type erasure (weaker)
- **OCaml functors**: Full type checking upfront

### Module System Uses

1. **Data structures**: Generic collections (Set, Map, Queue)
2. **Strategies**: Different implementations of same interface
3. **Configuration**: Parameterize app behavior
4. **Testing**: Mock implementations via modules

### Real OCaml Code

OCaml's standard library uses this heavily:

```ocaml
module IntMap = Map.Make(struct 
  type t = int 
  let compare = compare 
end)
```

One `Map` functor generates maps for any key type!

---

## 🚀 Ready to Code!

This task is different - you'll work through 4 mini-modules progressively:

1. **Part 1**: Basic module + signature (learn encapsulation)
2. **Part 2**: Multiple signatures (learn access control)
3. **Part 3**: First functor (learn parameterization)
4. **Part 4**: Complex functor (learn code reuse)

Each part builds your understanding of the module system piece by piece.

Start with `lib/part1_stack.ml` and `lib/part1_stack.mli`!

Good luck! 🎉
