(* REFERENCE SOLUTION - Do not peek until you've tried implementing it yourself! *)

let map f list =
  let rec loop acc = function
    | [] -> List.rev acc
    | x :: xs -> loop (f x :: acc) xs
  in
  loop [] list

let filter pred list =
  let rec loop acc = function
    | [] -> List.rev acc
    | x :: xs -> 
        if pred x then loop (x :: acc) xs
        else loop acc xs
  in
  loop [] list

let fold_left f init list =
  let rec loop acc = function
    | [] -> acc
    | x :: xs -> loop (f acc x) xs
  in
  loop init list

