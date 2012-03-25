open Ocamlbuild_plugin;;

dispatch begin function
    | After_rules ->
            flag ["compile"; "c"]
                 (S [A "-ccopt"; A "-I../src"]);
            flag ["link"; "ocaml"; "byte"; "use_backpack"]
                 (S [A "-dllib"; A "-lbackpack"]);
            flag ["link"; "ocaml"; "native"; "use_backpack"]
                 (S [A "-cclib"; A "-lbackpack"])
    | _ -> ()
end
