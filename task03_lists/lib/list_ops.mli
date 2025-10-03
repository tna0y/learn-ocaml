(** List Operations Library *)

(** {1 Core Higher-Order List Functions} *)

(** [map f list] applies function [f] to each element of [list].
    
    @param f a function to apply to each element
    @param list the input list
    @return a new list with [f] applied to each element
    
    Must be tail-recursive.
    
    Examples:
    - [map (fun x -> x * 2) [1; 2; 3] = [2; 4; 6]]
    - [map String.length ["hi"; "hello"] = [2; 5]]
*)
val map : ('a -> 'b) -> 'a list -> 'b list

(** [filter pred list] keeps only elements that satisfy the predicate.
    
    @param pred a predicate function returning bool
    @param list the input list
    @return a new list containing only elements where [pred element = true]
    
    Must be tail-recursive.
    
    Examples:
    - [filter (fun x -> x > 0) [-1; 0; 1; 2] = [1; 2]]
    - [filter (fun x -> x mod 2 = 0) [1; 2; 3; 4] = [2; 4]]
*)
val filter : ('a -> bool) -> 'a list -> 'a list

(** [fold_left f init list] reduces [list] to a single value.
    
    Processes elements left-to-right, accumulating a result:
    [fold_left f init [x1; x2; x3] = f (f (f init x1) x2) x3]
    
    @param f accumulator function taking (acc, element) -> new_acc
    @param init initial accumulator value
    @param list the input list
    @return the final accumulated value
    
    Must be tail-recursive (fold_left naturally is).
    
    Examples:
    - [fold_left (+) 0 [1; 2; 3; 4] = 10]
    - [fold_left (fun acc x -> acc ^ x) "" ["a"; "b"; "c"] = "abc"]
    - [fold_left (fun acc x -> x :: acc) [] [1; 2; 3] = [3; 2; 1]] (reverses)
*)
val fold_left : ('acc -> 'a -> 'acc) -> 'acc -> 'a list -> 'acc

