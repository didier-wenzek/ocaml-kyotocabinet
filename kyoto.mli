(** A key,value store database. *)
type db

(** Exception raised when something gone wrong with the database. *)
exception Error of string

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

(** Open a a database file.

  The kind of the database is infered from the path,
  and tuning parameters can trail the path.
  These conventions are inherited from kyotocabinet::PolyDB::open() :
  http://fallabs.com/kyotocabinet/api/classkyotocabinet_1_1PolyDB.html#a09384a72e6a72a0be98c80a1856f34aa
*)
external opendb: string -> open_flag list -> db = "kc_open"

(** Close the database file. *)
external close: db -> unit = "kc_close"

(** Return the count of key, value pairs. *)
external count: db -> int64 = "kc_count"

(** Return the size of the database file. *)
external size: db -> int64 = "kc_size"

(** Return the path of the database. *)
external path: db -> string = "kc_path"

(** Return a string status of the database. *)
external status: db -> string = "kc_status"

(** [exists db key] checks if any data is associated to the given [key] in the database [db]. *)
external exists: db -> string -> bool = "kc_exists"

(** [get db key] returns the data associated with the given [key] in the database [db], if any. *)
external get: db -> string -> string option = "kc_get"

(** [find db key] returns the data associated with the given [key], or raise Not_found if none is found. *)
external find: db -> string -> string = "kc_find"

(** [set db key data] inserts the pair ([key], [data]) in the database [db].

   If the database already contains data associated with [key],
   that data is discarded and silently replaced by the new [data]. *)
external set: db -> string -> string -> unit = "kc_set"

(** [add db key data] inserts the pair ([key], [data]) in the database [db].

   If the database already contains data associated with [key],
   it raises Invalid_Argument("Entry already exists"). *)
external add: db -> string -> string -> unit = "kc_add"

(** [replace db key data] inserts the pair ([key], [data]) in the database [db].

   If the database already contains data associated with [key],
   it raises Not_found. *)
external replace: db -> string -> string -> unit = "kc_replace"

(** [remove db key] removes the data associated with [key] in [db].

   If [key] has no associated data, simply do nothing.*)
external remove: db -> string -> unit = "kc_remove"

(** [fold db combiner seed] folds the whole content of the database [db].*)
external fold: db -> ('a -> (string*string) -> 'a) -> 'a -> 'a = "kc_fold"

type cursor
external cursor_open: db -> cursor = "kc_cursor_open"
external cursor_next: cursor -> (string*string) option = "kc_cursor_next"
external cursor_close: cursor -> unit = "kc_cursor_close"

(** begin a transaction with no file synchronization (save on process crash, but not system crash). *)
external begin_tran: db -> unit = "kc_begin_tran"

(** begin a transaction with file synchronization (save on process or system crash). *)
external begin_tran_sync: db -> unit = "kc_begin_tran_sync"

(** commit the current transaction *)
external commit_tran: db -> unit = "kc_commit_tran"

(** abort the current transaction *)
external abort_tran: db -> unit = "kc_abort_tran"
