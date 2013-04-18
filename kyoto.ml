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
let _ = Callback.register_exception "kyotocabinet.error" (Error "any string")

external opendb: string -> open_flag list -> db = "kc_open"
external close: db -> unit = "kc_close"

external count: db -> int64 = "kc_count"
external exists: db -> string -> bool = "kc_exists"
external set: db -> string -> string -> unit = "kc_set"
external get: db -> string -> string option = "kc_get"
external remove: db -> string -> unit = "kc_remove"

external fold: db -> ('a -> (string*string) -> 'a) -> 'a -> 'a = "kc_fold"

external cursor_open: db -> cursor = "kc_cursor_open"
external cursor_next: cursor -> (string*string) option = "kc_cursor_next"
external cursor_close: cursor -> unit = "kc_cursor_close"
