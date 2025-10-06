(* Main executable for Task 11: Alpha-Renaming *)

open Alpha_rename

let () =
  print_endline "Task 11: Alpha-Renaming and Shadow Elimination";
  print_endline "==============================================";
  print_endline "";
  
  (* Example 1: Simple let binding *)
  let e1 = Let ("x", Int 5, Var "x") in
  print_endline ("Original:  " ^ expr_to_string e1);
  let e1' = alpha_rename e1 in
  print_endline ("Renamed:   " ^ expr_to_string e1');
  print_endline "";
  
  (* Example 2: Simple shadowing *)
  let e2 = Let ("x", Int 1,
            Let ("x", Int 2,
              Var "x")) in
  print_endline ("Original:  " ^ expr_to_string e2);
  let e2' = alpha_rename e2 in
  print_endline ("Renamed:   " ^ expr_to_string e2');
  print_endline "";
  
  (* Example 3: Shadowing with reference to outer variable *)
  let e3 = Let ("x", Int 10,
            Let ("x", Add (Var "x", Int 5),
              Var "x")) in
  print_endline ("Original:  " ^ expr_to_string e3);
  let e3' = alpha_rename e3 in
  print_endline ("Renamed:   " ^ expr_to_string e3');
  print_endline "";
  
  (* Example 4: Multiple different variables *)
  let e4 = Let ("x", Int 1,
            Let ("y", Int 2,
              Add (Var "x", Var "y"))) in
  print_endline ("Original:  " ^ expr_to_string e4);
  let e4' = alpha_rename e4 in
  print_endline ("Renamed:   " ^ expr_to_string e4');
  print_endline "";
  
  (* Example 5: Complex nested shadowing *)
  let e5 = Let ("x", Int 1,
            Let ("x", Int 2,
              Let ("x", Int 3,
                Var "x"))) in
  print_endline ("Original:  " ^ expr_to_string e5);
  let e5' = alpha_rename e5 in
  print_endline ("Renamed:   " ^ expr_to_string e5');
  print_endline "";
  
  print_endline "Run 'dune test' to verify your implementation!"
