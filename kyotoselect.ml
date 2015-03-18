let select_prefix path prefix =
  let db = Kyoto.opendb path [Kyoto.OREADER] in
  let combiner () (k,v) = Printf.printf "%s: %s\n%!" k v in
  Kyoto.fold_prefix db prefix combiner ()

let main =
  if Array.length Sys.argv != 2 && Array.length Sys.argv != 3
  then (
    Printf.fprintf stderr "usage: %s kyoto-db-path [key-prefix]\n%!" Sys.argv.(0);
  )
  else
    let path = Sys.argv.(1) in
    let prefix = if Array.length Sys.argv == 3 then Sys.argv.(2) else ""
    in select_prefix path prefix
