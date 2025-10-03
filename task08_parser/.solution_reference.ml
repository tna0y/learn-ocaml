(* REFERENCE SOLUTION - Do not peek until you've tried implementing it yourself! *)

type expr =
  | Int of int
  | Add of expr * expr
  | Sub of expr * expr
  | Mul of expr * expr
  | Div of expr * expr

let skip_ws s pos =
  let rec loop pos =
    if pos >= String.length s then pos
    else match s.[pos] with
    | ' ' | '\t' | '\n' | '\r' -> loop (pos + 1)
    | _ -> pos
  in
  loop pos

let parse_number s pos =
  let pos = skip_ws s pos in
  if pos >= String.length s then
    Error "Expected number"
  else
    let start = pos in
    let pos = if s.[pos] = '-' then pos + 1 else pos in
    let rec loop pos =
      if pos >= String.length s then pos
      else match s.[pos] with
      | '0'..'9' -> loop (pos + 1)
      | _ -> pos
    in
    let pos' = loop pos in
    if pos' = start || (pos' = start + 1 && s.[start] = '-') then
      Error (Printf.sprintf "Expected number at position %d" pos)
    else
      let num_str = String.sub s start (pos' - start) in
      Ok (int_of_string num_str, pos')

let rec parse_factor s pos =
  let pos = skip_ws s pos in
  if pos >= String.length s then
    Error "Expected number or '('"
  else if s.[pos] = '(' then
    match parse_expr s (pos + 1) with
    | Error msg -> Error msg
    | Ok (expr, pos') ->
        let pos' = skip_ws s pos' in
        if pos' >= String.length s || s.[pos'] <> ')' then
          Error (Printf.sprintf "Expected ')' at position %d" pos')
        else
          Ok (expr, pos' + 1)
  else
    match parse_number s pos with
    | Ok (n, pos') -> Ok (Int n, pos')
    | Error msg -> Error msg

and parse_term s pos =
  match parse_factor s pos with
  | Error msg -> Error msg
  | Ok (left, pos) ->
      let rec loop left pos =
        let pos = skip_ws s pos in
        if pos >= String.length s then Ok (left, pos)
        else match s.[pos] with
        | '*' ->
            (match parse_factor s (pos + 1) with
             | Error msg -> Error msg
             | Ok (right, pos') -> loop (Mul (left, right)) pos')
        | '/' ->
            (match parse_factor s (pos + 1) with
             | Error msg -> Error msg
             | Ok (right, pos') -> loop (Div (left, right)) pos')
        | _ -> Ok (left, pos)
      in
      loop left pos

and parse_expr s pos =
  match parse_term s pos with
  | Error msg -> Error msg
  | Ok (left, pos) ->
      let rec loop left pos =
        let pos = skip_ws s pos in
        if pos >= String.length s then Ok (left, pos)
        else match s.[pos] with
        | '+' ->
            (match parse_term s (pos + 1) with
             | Error msg -> Error msg
             | Ok (right, pos') -> loop (Add (left, right)) pos')
        | '-' ->
            (match parse_term s (pos + 1) with
             | Error msg -> Error msg
             | Ok (right, pos') -> loop (Sub (left, right)) pos')
        | _ -> Ok (left, pos)
      in
      loop left pos

let parse s =
  match parse_expr s 0 with
  | Error msg -> Error msg
  | Ok (expr, pos) ->
      let pos = skip_ws s pos in
      if pos < String.length s then
        Error (Printf.sprintf "Unexpected character '%c' at position %d" s.[pos] pos)
      else
        Ok expr

