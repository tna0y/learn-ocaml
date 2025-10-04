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
let parse_int _s = try Some (int_of_string _s) with Failure _ -> None

(** Return first Some value, or None *)
let combine_options _opt1 _opt2 =
  match _opt1 with Some x -> Some x | _ -> _opt2

(** Safe division returning result *)
let safe_div _a _b = if _b = 0 then Error "Division by zero" else Ok (_a / _b)

(** Safe square root returning result *)
let safe_sqrt _x =
  if _x < 0.0 then Error "Cannot take square root of negative number"
  else Ok (sqrt _x)
