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
  let rec loop _l acc =
    match _l with [] -> List.rev acc | x :: xs -> loop xs (_f x :: acc)
  in
  loop _list []

(** Keep only elements satisfying a predicate *)
let filter _pred _list =
  let rec loop _l acc =
    match _l with
    | [] -> List.rev acc
    | x :: xs -> if _pred x then loop xs (x :: acc) else loop xs acc
  in
  loop _list []

(** Reduce a list to a single value (left to right) *)
let fold_left _f _init _list =
  let rec loop cur rem =
    match rem with [] -> cur | x :: xs -> loop (_f cur x) xs
  in
  loop _init _list
