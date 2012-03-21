open Ocamlbuild_plugin
open Command

;;

dispatch begin function
| After_rules ->
        (*
         * The linker flags are different depending on
         * if we are compiling bytecode or native code
         *)
        flag ["link"; "ocaml"; "byte"; "use_backpack"]
             (S [A "-dllib"; A "-lbackpack"]);
        flag ["link"; "ocaml"; "native"; "use_backpack"]
             (S [A "-cclib"; A "-lbackpack"])
| _ -> ()
end
