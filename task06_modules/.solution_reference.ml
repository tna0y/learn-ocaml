(* REFERENCE SOLUTION - Do not peek until you've tried implementing it yourself! *)

type t = { num : int; den : int }

(* Euclidean GCD algorithm *)
let rec gcd a b =
  let a = abs a in
  let b = abs b in
  if b = 0 then a
  else gcd b (a mod b)

(* Create simplified rational *)
let make num den =
  if den = 0 then failwith "Denominator cannot be zero";
  let g = gcd num den in
  let num' = num / g in
  let den' = den / g in
  (* Keep sign in numerator *)
  if den' < 0 then { num = -num'; den = -den' }
  else { num = num'; den = den' }

(* Addition: a/b + c/d = (ad + bc) / bd *)
let add a b =
  let num = a.num * b.den + b.num * a.den in
  let den = a.den * b.den in
  make num den

(* Multiplication: a/b * c/d = ac / bd *)
let mul a b =
  let num = a.num * b.num in
  let den = a.den * b.den in
  make num den

(* Convert to string *)
let to_string r =
  if r.den = 1 then string_of_int r.num
  else Printf.sprintf "%d/%d" r.num r.den

