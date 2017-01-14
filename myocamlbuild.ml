open Ocamlbuild_plugin ;;

let _ = dispatch begin function
    | After_rules ->
        ocaml_lib "traildb";

        flag ["ocamlmklib"; "c"; "use_libtraildb"] (S[A"-ltraildb"]);
        flag ["link"; "ocaml"; "use_libtraildb"] (S[A"-cclib"; A"-ltraildb"]);

        flag ["link";"library";"ocaml";"byte";"use_ocaml_traildb"] & S[A"-dllib";A"-locamltraildb";A"-cclib";A"-L.";A"-cclib";A"-locamltraildb"];
        flag ["link";"library";"ocaml";"native";"use_ocaml_traildb"] & S[A"-cclib";A"-L.";A"-cclib";A"-locamltraildb"];
        flag ["link";"ocaml";"link_libtraildb"] (A"libocamltraildb.a");

        dep ["link";"ocaml";"use_libtraildb"] ["libocamltraildb.a"];
        dep ["link";"ocaml";"link_libtraildb"] ["libocamltraildb.a"];

    | _ -> ()
end
