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
external size: db -> int64 = "kc_size"
external path: db -> string = "kc_path"
external status: db -> string = "kc_status"

external exists: db -> string -> bool = "kc_exists"
external get: db -> string -> string option = "kc_get"
external find: db -> string -> string = "kc_find"

external set: db -> string -> string -> unit = "kc_set"
external add: db -> string -> string -> unit = "kc_add"
external replace: db -> string -> string -> unit = "kc_replace"
external remove: db -> string -> unit = "kc_remove"

external fold: db -> ('a -> (string*string) -> 'a) -> 'a -> 'a = "kc_fold"

external cursor_open: db -> cursor = "kc_cursor_open"
external cursor_next: cursor -> (string*string) option = "kc_cursor_next"
external cursor_jump: cursor -> string -> unit = "kc_cursor_jump"
external cursor_close: cursor -> unit = "kc_cursor_close"

external begin_tran: db -> unit = "kc_begin_tran"
external begin_tran_sync: db -> unit = "kc_begin_tran_sync"
external commit_tran: db -> unit = "kc_commit_tran"
external abort_tran: db -> unit = "kc_abort_tran"
