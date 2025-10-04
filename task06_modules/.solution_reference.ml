(* REFERENCE SOLUTION - Do not peek until you've tried implementing it yourself! *)

(* ===== PART 1: Stack ===== *)
module Part1_Stack = struct
  type 'a t = 'a list
  
  let empty = []
  
  let push x s = x :: s
  
  let pop = function
    | [] -> None
    | x :: xs -> Some (x, xs)
  
  let peek = function
    | [] -> None
    | x :: _ -> Some x
end

(* ===== PART 2: Counter ===== *)
module Part2_Counter = struct
  type t = int
  
  let create initial = initial
  
  let increment c = c + 1
  
  let decrement c = c - 1
  
  let get_value c = c
  
  let reset _ = 0
end

(* ===== PART 3: Queue Functor ===== *)
module Part3_Queue_Solution = struct
  module type ELEMENT = sig
    type t
    val to_string : t -> string
  end
  
  module MakeQueue(E : ELEMENT) = struct
    type t = E.t list
    
    let empty = []
    
    let enqueue x q = q @ [x]  (* Add to end *)
    
    let dequeue = function
      | [] -> None
      | x :: xs -> Some (x, xs)  (* Remove from front *)
    
    let to_string q =
      "[" ^ String.concat "; " (List.map E.to_string q) ^ "]"
  end
end

(* ===== PART 4: Set Functor ===== *)
module Part4_Set_Solution = struct
  module type ORDERED = sig
    type t
    val compare : t -> t -> int
  end
  
  module MakeSet(Ord : ORDERED) = struct
    type t = Ord.t list  (* Sorted list, no duplicates *)
    
    let empty = []
    
    let rec add x = function
      | [] -> [x]
      | y :: ys as s ->
          let c = Ord.compare x y in
          if c < 0 then x :: s
          else if c = 0 then s  (* Already exists *)
          else y :: add x ys
    
    let rec mem x = function
      | [] -> false
      | y :: ys ->
          let c = Ord.compare x y in
          if c = 0 then true
          else if c < 0 then false  (* Past where it would be *)
          else mem x ys
    
    let to_list s = s
  end
end

(* Key insights:
 * - Part 1: Abstract types hide implementation
 * - Part 2: Same code, different signatures = different interfaces
 * - Part 3: Functors enable code reuse (one queue for all types)
 * - Part 4: Complex functors like OCaml's Set module
 *)
