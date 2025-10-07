(** Stack Machine Compiler - Implementation *)

[@@@warning "-32-27"]  (* Suppress warnings for unused functions/vars in skeleton *)

(* Task 12: Toy Stack Machine and Compilation
 *
 * Implement:
 * 1. compile - compile expressions to stack machine instructions
 *
 * Key concepts:
 * - Stack-based execution model
 * - Instruction sequences
 * - Postfix/RPN evaluation
 * - Compilation strategy: left, right, operation
 * - LOAD/STORE for variables
 *)

type expr =
  | Int of int
  | Add of expr * expr
  | Sub of expr * expr
  | Mul of expr * expr
  | Div of expr * expr
  | Var of string
  | Let of string * expr * expr

type instr =
  | PUSH of int
  | ADD
  | SUB
  | MUL
  | DIV
  | LOAD of string
  | STORE of string

type vm_env = (string * int) list

(** ============================================
    STUDENT TODO: Implement this function
    ============================================ *)

(** Compile expression to stack machine instructions *)
let compile _e =
  failwith "TODO: Implement compile (use 'let rec')"
  (* Hints:
   * - Use 'let rec compile e = ...' (add the 'rec' keyword)
   * - Pattern match on e
   * - Int n -> [PUSH n]
   * - Var x -> [LOAD x]
   * - Binary operations (Add/Sub/Mul/Div):
   *   | Add (e1, e2) ->
   *       compile e1        (* Compile left operand *)
   *       @ compile e2      (* Compile right operand *)
   *       @ [ADD]           (* Apply operation *)
   *   Same pattern for Sub, Mul, Div
   * - Let binding:
   *   | Let (x, e1, e2) ->
   *       compile e1        (* Compile binding expression *)
   *       @ [STORE x]       (* Store value in environment *)
   *       @ compile e2      (* Compile body *)
   * 
   * Remember:
   * - Use @ to concatenate lists
   * - Left operand comes before right operand
   * - STORE pops value from stack and saves to environment
   * - LOAD pushes value from environment onto stack
   *)

(** ============================================
    VM IMPLEMENTATION (Provided - Do Not Modify)
    ============================================ *)

(** Helper: lookup variable in environment *)
let rec lookup x = function
  | [] -> failwith ("Unbound variable: " ^ x)
  | (y, v) :: rest -> if x = y then v else lookup x rest

(** Execute instruction list on stack machine *)
let execute instrs env =
  let rec exec stack env = function
    | [] ->
        (* Finished - return top of stack *)
        (match stack with
         | [] -> failwith "Empty stack at end of execution"
         | result :: _ -> result)
    | instr :: rest ->
        (match instr with
         | PUSH n ->
             (* Push constant onto stack *)
             exec (n :: stack) env rest
         | ADD ->
             (* Pop two values, push sum *)
             (match stack with
              | y :: x :: stack' -> exec ((x + y) :: stack') env rest
              | _ -> failwith "Stack underflow in ADD")
         | SUB ->
             (* Pop two values, push difference *)
             (match stack with
              | y :: x :: stack' -> exec ((x - y) :: stack') env rest
              | _ -> failwith "Stack underflow in SUB")
         | MUL ->
             (* Pop two values, push product *)
             (match stack with
              | y :: x :: stack' -> exec ((x * y) :: stack') env rest
              | _ -> failwith "Stack underflow in MUL")
         | DIV ->
             (* Pop two values, push quotient *)
             (match stack with
              | y :: x :: stack' -> exec ((x / y) :: stack') env rest
              | _ -> failwith "Stack underflow in DIV")
         | LOAD x ->
             (* Load variable from environment, push onto stack *)
             let v = lookup x env in
             exec (v :: stack) env rest
         | STORE x ->
             (* Pop value from stack, store in environment *)
             (match stack with
              | v :: stack' -> exec stack' ((x, v) :: env) rest
              | _ -> failwith "Stack underflow in STORE"))
  in
  exec [] env instrs

(** Execute with debug output showing each step *)
let execute_debug instrs env =
  let show_stack stack =
    "[" ^ String.concat ", " (List.map string_of_int (List.rev stack)) ^ "]"
  in
  let show_env env =
    "[" ^ String.concat "; " 
      (List.map (fun (x, v) -> Printf.sprintf "(%s, %d)" x v) env) ^ "]"
  in
  let show_instr = function
    | PUSH n -> Printf.sprintf "PUSH %d" n
    | ADD -> "ADD"
    | SUB -> "SUB"
    | MUL -> "MUL"
    | DIV -> "DIV"
    | LOAD x -> Printf.sprintf "LOAD \"%s\"" x
    | STORE x -> Printf.sprintf "STORE \"%s\"" x
  in
  let rec exec step stack env = function
    | [] ->
        Printf.printf "\nFinal stack: %s\n" (show_stack stack);
        Printf.printf "Final env: %s\n" (show_env env);
        (match stack with
         | [] -> failwith "Empty stack at end of execution"
         | result :: _ -> 
             Printf.printf "Result: %d\n" result;
             result)
    | instr :: rest ->
        Printf.printf "\nStep %d: %s\n" step (show_instr instr);
        Printf.printf "  Stack before: %s\n" (show_stack stack);
        Printf.printf "  Env before:   %s\n" (show_env env);
        let (stack', env') = 
          (match instr with
           | PUSH n -> (n :: stack, env)
           | ADD ->
               (match stack with
                | y :: x :: stack' -> ((x + y) :: stack', env)
                | _ -> failwith "Stack underflow in ADD")
           | SUB ->
               (match stack with
                | y :: x :: stack' -> ((x - y) :: stack', env)
                | _ -> failwith "Stack underflow in SUB")
           | MUL ->
               (match stack with
                | y :: x :: stack' -> ((x * y) :: stack', env)
                | _ -> failwith "Stack underflow in MUL")
           | DIV ->
               (match stack with
                | y :: x :: stack' -> ((x / y) :: stack', env)
                | _ -> failwith "Stack underflow in DIV")
           | LOAD x ->
               let v = lookup x env in
               (v :: stack, env)
           | STORE x ->
               (match stack with
                | v :: stack' -> (stack', (x, v) :: env)
                | _ -> failwith "Stack underflow in STORE"))
        in
        Printf.printf "  Stack after:  %s\n" (show_stack stack');
        Printf.printf "  Env after:    %s\n" (show_env env');
        exec (step + 1) stack' env' rest
  in
  Printf.printf "=== Executing %d instructions ===\n" (List.length instrs);
  exec 0 [] env instrs

(** ============================================
    UTILITIES (Provided)
    ============================================ *)

(** Evaluate expression (for testing) *)
let rec eval env = function
  | Int n -> n
  | Add (e1, e2) -> eval env e1 + eval env e2
  | Sub (e1, e2) -> eval env e1 - eval env e2
  | Mul (e1, e2) -> eval env e1 * eval env e2
  | Div (e1, e2) -> eval env e1 / eval env e2
  | Var x -> lookup x env
  | Let (x, e1, e2) ->
      let v1 = eval env e1 in
      let env' = (x, v1) :: env in
      eval env' e2

(** Convert instruction to string *)
let instr_to_string = function
  | PUSH n -> Printf.sprintf "PUSH %d" n
  | ADD -> "ADD"
  | SUB -> "SUB"
  | MUL -> "MUL"
  | DIV -> "DIV"
  | LOAD x -> Printf.sprintf "LOAD \"%s\"" x
  | STORE x -> Printf.sprintf "STORE \"%s\"" x

(** Convert instruction list to string *)
let instrs_to_string instrs =
  String.concat "\n" (List.map instr_to_string instrs)

(** Convert expression to string *)
let rec expr_to_string = function
  | Int n -> string_of_int n
  | Add (e1, e2) -> Printf.sprintf "(%s + %s)" (expr_to_string e1) (expr_to_string e2)
  | Sub (e1, e2) -> Printf.sprintf "(%s - %s)" (expr_to_string e1) (expr_to_string e2)
  | Mul (e1, e2) -> Printf.sprintf "(%s * %s)" (expr_to_string e1) (expr_to_string e2)
  | Div (e1, e2) -> Printf.sprintf "(%s / %s)" (expr_to_string e1) (expr_to_string e2)
  | Var x -> x
  | Let (x, e1, e2) -> 
      Printf.sprintf "let %s = %s in %s" x (expr_to_string e1) (expr_to_string e2)

