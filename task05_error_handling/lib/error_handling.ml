(** Error Handling with Option and Result - Implementation *)

(* Task 5: Option/Result and Error Handling
 *
 * Implement functions using option and result types:
 * 1. parse_int - convert string to int option
 * 2. safe_div - divide with result type
 * 3. safe_sqrt - square root with error handling
 * 4. combine_options - return first Some value
 *
 * Remember:
 * - option: Some x | None
 * - result: Ok x | Error e
 * - Use try...with to catch exceptions
 * - Pattern match to handle all cases
 *)

(** Parse a string to an integer *)
let parse_int _s =
  failwith "TODO: Implement parse_int"
  (* Hints:
   * - Use try...with to catch exceptions
   * - try Some (int_of_string s)
   * - with Failure _ -> None
   * - This converts exception to option type
   *)

(** Return first Some value, or None *)
let combine_options _opt1 _opt2 =
  failwith "TODO: Implement combine_options"
  (* Hints:
   * - Match on opt1:
   *     | Some x -> Some x (return first if present)
   *     | None -> opt2 (return second)
   * - Simple pattern matching!
   *)

(** Safe division returning result *)
let safe_div _a _b =
  failwith "TODO: Implement safe_div"
  (* Hints:
   * - Check if b = 0
   * - If yes: Error "Division by zero"
   * - If no: Ok (a / b)
   * - Use if...then...else
   *)

(** Safe square root returning result *)
let safe_sqrt _x =
  failwith "TODO: Implement safe_sqrt"
  (* Hints:
   * - Check if x < 0.0
   * - If yes: Error "Cannot take square root of negative number"
   * - If no: Ok (sqrt x)  or  Ok (Float.sqrt x)
   * - sqrt is from Stdlib
   *)

