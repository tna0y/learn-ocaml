(** Recursive Descent Parser - Implementation *)

[@@@warning "-32-27-39"]
(* Suppress warnings for unused functions/vars/rec in skeleton *)

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

let (let*) = Result.bind

type expr =
  | Int of int
  | Add of expr * expr
  | Sub of expr * expr
  | Mul of expr * expr
  | Div of expr * expr

type token = INT of int | PLUS | MINUS | TIMES | DIV | LPAREN | RPAREN | EOF

let to_string (x : token) = match x with
| INT (n) -> string_of_int n
| PLUS -> "+"
| MINUS -> "-"
| TIMES -> "*"
| DIV -> "/"
| LPAREN -> "("
| RPAREN -> ")"
| EOF -> "EOF"
(* ========== LEXER (Tokenization) ========== *)

(* Helper: check if character is whitespace *)
let is_whitespace c = c = ' ' || c = '\t' || c = '\n' || c = '\r'

(* Helper: check if character is a digit *)
let is_digit c = (c >= '0' && c <= '9')

(* let is_token c = function
| int (_) -> is_digit c *)
(* Lexer implementation *)
let rec parse_ints acc = function
| [] -> (int_of_string acc, [])
| x :: xs ->
    if is_digit x then parse_ints (acc ^ Char.escaped x) xs
    else (int_of_string acc, x :: xs)
let lex _s =
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
  let rec lex_rem acc = function
    | [] -> Ok (List.rev (EOF :: acc))
    | x :: xs -> (
        match x with
        | '+' -> lex_rem (PLUS :: acc) xs
        | '-' -> (
            match (xs, acc) with
            (* If previous token was a number, this is subtraction *)
            | _, INT _ :: _ -> lex_rem (MINUS :: acc) xs
            | _, RPAREN :: _ -> lex_rem (MINUS :: acc) xs
            (* If next char is a digit and we haven't just seen a number, parse negative *)
            | d :: rest, _ when is_digit d ->
                let parsed_int, digit_rem = parse_ints (Char.escaped d) rest in
                lex_rem (INT (-parsed_int) :: acc) digit_rem
            (* Otherwise, it's just a minus operator *)
            | _ -> lex_rem (MINUS :: acc) xs)
        | '*' -> lex_rem (TIMES :: acc) xs
        | '/' -> lex_rem (DIV :: acc) xs
        | '(' -> lex_rem (LPAREN :: acc) xs
        | ')' -> lex_rem (RPAREN :: acc) xs
        | c when is_whitespace c -> lex_rem acc xs
        | c when is_digit c ->
            let parsed_int, digit_rem = parse_ints "" (x :: xs) in
            lex_rem (INT parsed_int :: acc) digit_rem
        | c -> Error ("Invalid character '" ^ Char.escaped c ^ "'"))
  in
  lex_rem [] (String.to_seq _s |> List.of_seq)

(* ========== PARSER (Token Stream to AST) ========== *)

(* The parser functions now work on token lists instead of strings.
 * Each function returns: (expr * remaining_tokens, string) result
 *)

(* Mutually recursive parser functions *)
(* Parse a factor: INT | '(' expr ')' *)
let rec parse_factor = function
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
 | INT (n) :: xs -> Ok (Int (n), xs)
 | tok :: _ -> Error ("Unexpected token " ^ (to_string tok))
 | [] -> Error ("Unexpected end of token stream")
(* Parse a term: factor (('*' | '/') factor)* *)
and parse_term _tokens = 
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
 let* (fac1, rem) = parse_factor _tokens in
 let rec loop left tokens =
  match tokens with
  | TIMES :: rest_op -> 
    let* (f2, rest_f2) = parse_factor rest_op in
    loop (Mul ( left, f2)) rest_f2
  | DIV :: rest_op ->
    let* (f2, rest_f2) = parse_factor rest_op in
    loop (Div (left, f2)) rest_f2
  | _ -> Ok (left, tokens)
  in
  loop fac1 rem

(* Parse an expression: term (('+' | '-') term)* *)
and parse_expr _tokens =
(* Hints:
 * - Similar to parse_term, but for PLUS and MINUS
 * - Parse first term
 * - Loop while PLUS or MINUS:
 *     - Build Add or Sub nodes
 *     - Continue with next term
 *)
 let* (term1, rem) = parse_term _tokens in
 let rec loop left tokens =
  match tokens with
  | PLUS :: rest_op -> 
    let* (t2, rest_t2) = parse_term rest_op in
    loop (Add ( left, t2)) rest_t2
  | MINUS :: rest_op ->
    let* (t2, rest_t2) = parse_term rest_op in
    loop (Sub (left, t2)) rest_t2
  | _ -> Ok (left, tokens)
  in
  loop term1 rem

(* Main parse function *)
let parse s = 
(* Hints:
 * - First, lex the string: match lex s with Error e -> Error e | Ok tokens -> ...
 * - Then parse: match parse_expr tokens with Error e -> Error e | Ok (expr, rest) -> ...
 * - Check that we consumed all tokens except EOF:
 *     match rest with
 *     | [EOF] -> Ok expr
 *     | _ -> Error "Unexpected tokens after expression"
 *)
 let* tokens = lex s in
 let* (ast, rem) = parse_expr tokens in
 match rem with
 | EOF :: [] -> Ok ast
 | _ -> Error "Unexpected tokens after expression"
