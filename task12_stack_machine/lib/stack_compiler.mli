(** Stack Machine Compiler *)

(** {1 Expression Type} *)

(** The type of expressions. *)
type expr =
  | Int of int
  | Add of expr * expr
  | Sub of expr * expr
  | Mul of expr * expr
  | Div of expr * expr
  | Var of string
  | Let of string * expr * expr

(** {1 Instruction Set} *)

(** Stack machine instructions. *)
type instr =
  | PUSH of int        (** Push constant onto stack *)
  | ADD                (** Pop y, pop x, push x + y *)
  | SUB                (** Pop y, pop x, push x - y *)
  | MUL                (** Pop y, pop x, push x * y *)
  | DIV                (** Pop y, pop x, push x / y *)
  | LOAD of string     (** Load variable from environment *)
  | STORE of string    (** Pop value, store in environment *)

(** {1 Environment} *)

(** VM environment type. *)
type vm_env = (string * int) list

(** {1 Compilation} *)

(** [compile e] compiles expression [e] to a list of stack machine instructions.
    
    The generated code, when executed, leaves the result on top of the stack.
    
    Compilation strategy:
    - [Int n]: Push constant
    - [Add/Sub/Mul/Div (e1, e2)]: Compile e1, compile e2, apply operation
    - [Var x]: Load variable from environment
    - [Let (x, e1, e2)]: Compile e1, store result, compile e2
    
    @param e the expression to compile
    @return list of instructions
    
    Examples:
    - [compile (Int 42) = [PUSH 42]]
    - [compile (Add (Int 2, Int 3)) = [PUSH 2; PUSH 3; ADD]]
    - [compile (Var "x") = [LOAD "x"]]
    - [compile (Let ("x", Int 5, Var "x")) = [PUSH 5; STORE "x"; LOAD "x"]]
    
    Property: [execute (compile e) env = eval env e] for all [e] and [env]
*)
val compile : expr -> instr list

(** {1 Virtual Machine (Provided)} *)

(** [execute instrs env] executes the instruction list on the VM.
    
    Starts with empty stack and given environment.
    Returns the final value (top of stack).
    
    @param instrs list of instructions to execute
    @param env initial environment
    @return final result (top of stack)
    @raise Failure if stack underflow or variable not found
    
    Examples:
    - [execute [PUSH 5] [] = 5]
    - [execute [PUSH 2; PUSH 3; ADD] [] = 5]
    - [execute [PUSH 5; STORE "x"; LOAD "x"] [] = 5]
*)
val execute : instr list -> vm_env -> int

(** [execute_debug instrs env] executes instructions with debug output.
    
    Prints each step showing instruction, stack state, and environment.
    Useful for understanding and debugging compilation.
    
    @param instrs list of instructions to execute
    @param env initial environment
    @return final result (top of stack)
*)
val execute_debug : instr list -> vm_env -> int

(** {1 Utilities} *)

(** [eval env e] evaluates expression [e] in environment [env].
    
    Direct tree-walking interpreter for comparison with VM execution.
    
    @param env the environment
    @param e the expression
    @return the integer result
    @raise Failure if variable not found or division by zero
*)
val eval : vm_env -> expr -> int

(** [instr_to_string i] converts instruction to string.
    
    @param i the instruction
    @return string representation
*)
val instr_to_string : instr -> string

(** [instrs_to_string instrs] converts instruction list to string.
    
    @param instrs list of instructions
    @return string representation with newlines
*)
val instrs_to_string : instr list -> string

(** [expr_to_string e] converts expression to string.
    
    @param e the expression
    @return string representation
*)
val expr_to_string : expr -> string

