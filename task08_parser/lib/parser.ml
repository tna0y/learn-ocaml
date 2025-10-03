(** Recursive Descent Parser - Implementation *)

[@@@warning "-32-27"]  (* Suppress warnings for unused functions/vars in skeleton *)

(* Task 8: Parser (Recursive Descent)
 *
 * Implement a parser for arithmetic expressions:
 * Grammar:
 *   expr   ::= term (('+' | '-') term)*
 *   term   ::= factor (('*' | '/') factor)*
 *   factor ::= number | '(' expr ')'
 *
 * Strategy:
 * 1. Start with integers
 * 2. Add single operator (e.g., just +)
 * 3. Add all operators with precedence
 * 4. Add parentheses
 * 5. Add error handling
 *)

type expr =
  | Int of int
  | Add of expr * expr
  | Sub of expr * expr
  | Mul of expr * expr
  | Div of expr * expr

(* Helper: skip whitespace starting at position pos *)
let skip_ws _s _pos =
  failwith "TODO: Implement skip_ws"
  (* Hints:
   * - Start at pos
   * - While pos < String.length s && s.[pos] is space/tab/newline:
   *     increment pos
   * - Return final position
   * - Use a recursive helper or a ref
   *)

(* Helper: parse an integer starting at position pos *)
let parse_number _s _pos =
  failwith "TODO: Implement parse_number"
  (* Hints:
   * - Skip whitespace first: let pos = skip_ws s pos
   * - Check if at end: if pos >= String.length s then Error "..."
   * - Handle negative sign: if s.[pos] = '-' then ...
   * - Accumulate digits: while s.[pos] is digit '0'-'9'
   * - Convert to int: int_of_string (String.sub s start len)
   * - Return Ok (number, new_position) or Error message
   *)

(* Parse a factor: number or ( expr ) *)
let parse_factor _s _pos =
  failwith "TODO: Implement parse_factor (use 'let rec ... and ...')"
  (* Hints:
   * - Skip whitespace
   * - If s.[pos] = '(': 
   *     parse_expr for the contents
   *     expect ')' 
   *     return result
   * - Else: parse_number
   *)

(* Parse a term: factor (times or div factor)* *)
let parse_term _s _pos =
  failwith "TODO: Implement parse_term (use 'let rec ... and ...')"
  (* Hints:
   * - Parse first factor: match parse_factor s pos with Ok (left, pos') -> ...
   * - Loop: while s.[pos'] is times or div:
   *     consume operator
   *     parse right factor
   *     left := Mul(left, right) or Div(left, right)
   * - Return Ok (left, final_pos)
   *)

(* Parse an expression: term (plus or minus term)* *)
let parse_expr _s _pos =
  failwith "TODO: Implement parse_expr (use 'let rec ... and ...')"
  (* Hints:
   * - Similar to parse_term but for + and -
   * - Parse first term
   * - Loop while '+' or '-'
   * - Build Add or Sub nodes
   *)

(* Main parse function *)
let parse _s =
  failwith "TODO: Implement parse"
  (* Hints:
   * - Call parse_expr s 0
   * - Check that we consumed all input: if pos = String.length s
   * - Return Ok expr or Error "Unexpected characters after expression"
   *)

