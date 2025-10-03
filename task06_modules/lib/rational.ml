(** Rational Numbers Module - Implementation *)

(* Task 6: Modules and Functors
 *
 * Implement a rational number library:
 * 1. gcd - greatest common divisor
 * 2. make - create simplified rational
 * 3. add - addition
 * 4. mul - multiplication
 * 5. to_string - convert to string
 *
 * Remember:
 * - Simplify using GCD
 * - Keep sign in numerator
 * - Handle division by zero
 *)

(** Type for rational numbers *)
type t = { num : int; den : int }

(** Helper: greatest common divisor *)
let gcd _a _b =
  failwith "TODO: Implement gcd using Euclidean algorithm (use 'let rec')"
  (* Hints:
   * - Use abs to handle negative numbers
   * - Base case: if b = 0 then abs a
   * - Recursive case: gcd b (a mod b)
   * - This is the classic Euclidean algorithm
   * - You'll need to use 'let rec' since gcd calls itself
   *)

(** Create a rational number in simplified form *)
let make _num _den =
  failwith "TODO: Implement make"
  (* Hints:
   * - Check if den = 0, raise Failure "Denominator cannot be zero"
   * - Compute g = gcd num den
   * - Simplify: num' = num / g, den' = den / g
   * - If den' < 0, negate both to keep sign in numerator
   * - Return { num = num'; den = den' }
   *)

(** Add two rational numbers *)
let add _a _b =
  failwith "TODO: Implement add"
  (* Hints:
   * - Formula: a/b + c/d = (ad + bc) / bd
   * - Compute: num = a.num * b.den + b.num * a.den
   * - Compute: den = a.den * b.den
   * - Use make num den to simplify the result
   *)

(** Multiply two rational numbers *)
let mul _a _b =
  failwith "TODO: Implement mul"
  (* Hints:
   * - Formula: a/b * c/d = (ac) / (bd)
   * - Compute: num = a.num * b.num
   * - Compute: den = a.den * b.den
   * - Use make num den to simplify the result
   *)

(** Convert rational to string *)
let to_string _r =
  failwith "TODO: Implement to_string"
  (* Hints:
   * - Use Printf.sprintf "%d/%d" r.num r.den
   * - Or handle special case: if den = 1 then just show num
   * - Example: "2/3", "5/1" or "5", "-2/3"
   *)

