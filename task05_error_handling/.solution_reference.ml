(* REFERENCE SOLUTION - Do not peek until you've tried implementing it yourself! *)

let parse_int s =
  try Some (int_of_string s)
  with Failure _ -> None

let combine_options opt1 opt2 =
  match opt1 with
  | Some x -> Some x
  | None -> opt2

let safe_div a b =
  if b = 0 then Error "Division by zero"
  else Ok (a / b)

let safe_sqrt x =
  if x < 0.0 then Error "Cannot take square root of negative number"
  else Ok (sqrt x)

