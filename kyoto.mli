type db
type cursor

type db_type =
|  TYPEVOID
|  TYPEPHASH
|  TYPEPTREE
|  TYPESTASH
|  TYPECACHE
|  TYPEGRASS
|  TYPEHASH
|  TYPETREE
|  TYPEDIR
|  TYPEFOREST
|  TYPETEXT
|  TYPEMISC

type open_flag =
|  OREADER
|  OWRITER
|  OCREATE
|  OTRUNCATE
|  OAUTOTRAN
|  OAUTOSYNC
|  ONOLOCK
|  OTRYLOCK
|  ONOREPAIR

exception Error of string

external opendb: string -> open_flag list -> db = "kc_open"
external close: db -> unit = "kc_close"

external count: db -> int64 = "kc_count"
external exists: db -> string -> bool = "kc_exists"
external get: db -> string -> string option = "kc_get"

external set: db -> string -> string -> unit = "kc_set"
external remove: db -> string -> unit = "kc_remove"

external fold: db -> ('a -> (string*string) -> 'a) -> 'a -> 'a = "kc_fold"

external cursor_open: db -> cursor = "kc_cursor_open"
external cursor_next: cursor -> (string*string) option = "kc_cursor_next"
external cursor_close: cursor -> unit = "kc_cursor_close"

(*
TODO:

hash/tree compare

clear

update/add
count
check
merge -- using a function to merge old and new values.
zip 

matchprefix

transaction
sync


let cursor_fold comb seed cur =
  let rec cf s =
  Lwt.bind
  (Lwt_preemptive.detach cursor_next cur) (
    fun item -> match item with
      | None -> Lwt.return s
      | Some(kv) -> cf (comb s kv)
  )
  in cf seed

*)






