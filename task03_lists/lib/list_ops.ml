(** List Operations Library - Implementation *)

(* Task 3: Pattern Matching and Lists
 *
 * Implement three fundamental list operations:
 * 1. map - apply a function to each element
 * 2. filter - keep only elements matching a predicate
 * 3. fold_left - reduce a list to a single value
 *
 * All implementations must be tail-recursive!
 *
 * Pattern matching structure:
 *   match list with
 *   | [] -> base_case
 *   | head :: tail -> recursive_case
 *
 * For tail recursion with lists:
 *   - Use an accumulator to collect results
 *   - Build results in reverse (prepending is O(1))
 *   - Use List.rev at the end to fix order
 *)

(** Apply a function to each element *)
let map _f _list =
  failwith "TODO: Implement map"
  (* Hints:
   * - Define helper: let rec loop acc = function | [] -> ... | x :: xs -> ...
   * - Base case: List.rev acc
   * - Recursive case: loop (f x :: acc) xs
   * - Initial call: loop [] list
   *)

(** Keep only elements satisfying a predicate *)
let filter _pred _list =
  failwith "TODO: Implement filter"
  (* Hints:
   * - Similar to map, but conditionally add to accumulator
   * - If pred x then loop (x :: acc) xs
   * - Else loop acc xs (skip this element)
   * - Don't forget List.rev at the end!
   *)

(** Reduce a list to a single value (left to right) *)
let fold_left _f _init _list =
  failwith "TODO: Implement fold_left"
  (* Hints:
   * - Define helper: let rec loop acc = function | [] -> ... | x :: xs -> ...
   * - Base case: acc (not List.rev! fold_left returns the accumulator directly)
   * - Recursive case: loop (f acc x) xs
   * - Initial call: loop init list
   * - This is naturally tail-recursive
   *)

