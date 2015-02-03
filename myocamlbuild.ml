open Ocamlbuild_plugin ;;

let _ = dispatch begin function
    | After_rules ->
        ocaml_lib "okyoto";

        flag ["ocamlmklib"; "c"; "use_kyotocabinet"] (S[A"-lkyotocabinet"]);
        flag ["link"; "ocaml"; "use_kyotocabinet"] (S[A"-cclib"; A"-lkyotocabinet"]);

        flag ["link";"library";"ocaml";"byte";"use_kyoto"] & S[A"-dllib";A"-locamlkyoto";A"-cclib";A"-L.";A"-cclib";A"-locamlkyoto"];
        flag ["link";"library";"ocaml";"native";"use_kyoto"] & S[A"-cclib";A"-L.";A"-cclib";A"-locamlkyoto"];
        flag ["link";"ocaml";"link_kyotocabinet"] (A"libocamlkyoto.a");

        dep ["link";"ocaml";"use_kyotocabinet"] ["libocamlkyoto.a"];
        dep ["link";"ocaml";"link_kyotocabinet"] ["libocamlkyoto.a"];

    | _ -> ()
end
