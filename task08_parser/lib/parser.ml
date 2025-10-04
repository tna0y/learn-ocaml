(** Recursive Descent Parser - Implementation *)

[@@@warning "-32-27-39"]  (* Suppress warnings for unused functions/vars/rec in skeleton *)

(* Task 8: Parser (Recursive Descent) with Tokenization
 *
 * This implementation uses a two-phase approach:
 * Phase 1: Lexer (lex) - converts string to tokens, handles whitespace
 * Phase 2: Parser - converts tokens to AST, handles precedence
 *
 * Grammar:
 *   expr   ::= term (('+' | '-') term)*
 *   term   ::= factor (('*' | '/') factor)*
 *   factor ::= INT | '(' expr ')'
 *
 * Strategy:
 * 1. Implement the lexer (lex function)
 * 2. Implement parser for integers
 * 3. Add operators with correct precedence
 * 4. Add parentheses support
 *)

type expr =
  | Int of int
  | Add of expr * expr
  | Sub of expr * expr
  | Mul of expr * expr
  | Div of expr * expr

type token =
  | INT of int
  | PLUS
  | MINUS
  | TIMES
  | DIV
  | LPAREN
  | RPAREN
  | EOF

(* ========== LEXER (Tokenization) ========== *)

(* Helper: check if character is whitespace *)
let is_whitespace c = c = ' ' || c = '\t' || c = '\n' || c = '\r'

(* Helper: check if character is a digit *)
let is_digit c = c >= '0' && c <= '9'

(* Lexer implementation *)
let lex _s =
  failwith "TODO: Implement lex"
  (* Hints:
   * - Create a recursive helper function: let rec lex_helper pos acc = ...
   * - Skip whitespace: while pos < String.length s && is_whitespace s.[pos] do pos := pos + 1
   * - If pos >= String.length s: return Ok (List.rev (EOF :: acc))
   * - Match current character:
   *   | '+' -> continue with PLUS :: acc, pos + 1
   *   | '-' -> check next char: if digit, parse negative number; else MINUS token
   *   | '*' -> continue with TIMES :: acc, pos + 1
   *   | '/' -> continue with DIV :: acc, pos + 1
   *   | '(' -> continue with LPAREN :: acc, pos + 1
   *   | ')' -> continue with RPAREN :: acc, pos + 1
   *   | '0'..'9' -> parse integer:
   *       - accumulate digits while is_digit
   *       - convert to int: int_of_string (String.sub s start len)
   *       - continue with INT n :: acc
   *   | _ -> Error (Printf.sprintf "Invalid character '%c' at position %d" s.[pos] pos)
   * - Start with: lex_helper 0 []
   * - Remember to reverse accumulator when done!
   *)

(* ========== PARSER (Token Stream to AST) ========== *)

(* The parser functions now work on token lists instead of strings.
 * Each function returns: (expr * remaining_tokens, string) result
 *)

(* Mutually recursive parser functions *)
(* Parse a factor: INT | '(' expr ')' *)
let rec parse_factor _tokens =
  failwith "TODO: Implement parse_factor"
  (* Hints:
   * - Pattern match on tokens:
   *   | INT n :: rest -> Ok (Int n, rest)
   *   | LPAREN :: rest ->
   *       - call parse_expr rest
   *       - expect RPAREN in remaining tokens
   *       - return (expr, tokens_after_rparen)
   *   | EOF :: _ -> Error "Expected number or '(' but got EOF"
   *   | _ -> Error "Expected number or '('"
   *)

(* Parse a term: factor (('*' | '/') factor)* *)
and parse_term _tokens =
  failwith "TODO: Implement parse_term"
  (* Hints:
   * - Parse first factor: match parse_factor tokens with Ok (left, rest) -> ...
   * - Create a loop using a recursive helper:
   *     let rec loop left tokens =
   *       match tokens with
   *       | TIMES :: rest ->
   *           - parse_factor rest
   *           - loop (Mul (left, right)) remaining_tokens
   *       | DIV :: rest ->
   *           - parse_factor rest
   *           - loop (Div (left, right)) remaining_tokens
   *       | _ -> Ok (left, tokens)  (* no more * or / *)
   * - Call: loop left rest
   *)

(* Parse an expression: term (('+' | '-') term)* *)
and parse_expr _tokens =
  failwith "TODO: Implement parse_expr"
  (* Hints:
   * - Similar to parse_term, but for PLUS and MINUS
   * - Parse first term
   * - Loop while PLUS or MINUS:
   *     - Build Add or Sub nodes
   *     - Continue with next term
   *)

(* Main parse function *)
let parse s =
  failwith "TODO: Implement parse"
  (* Hints:
   * - First, lex the string: match lex s with Error e -> Error e | Ok tokens -> ...
   * - Then parse: match parse_expr tokens with Error e -> Error e | Ok (expr, rest) -> ...
   * - Check that we consumed all tokens except EOF:
   *     match rest with
   *     | [EOF] -> Ok expr
   *     | _ -> Error "Unexpected tokens after expression"
   *)

