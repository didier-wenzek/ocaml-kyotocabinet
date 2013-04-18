let _ =

  (* create a database, here a in-memory tree database. *)
  let db = Kyoto.opendb "+" [Kyoto.OWRITER; Kyoto.OCREATE] in

  (* store records *)
  Kyoto.set db "foo" "hop";
  Kyoto.set db "bar" "step";
  Kyoto.set db "baz" "jump";
  Kyoto.set db "baz2" "jump";

  (* retrieve records *)
  assert (Kyoto.get db "foo" = Some "hop");
  assert (Kyoto.get db "xoxox" = None);

  (* update records *)
  Kyoto.set db "bar" "step2";
  Kyoto.remove db "baz2";

  (* check records *)
  assert (Kyoto.exists db "foo");
  assert (not (Kyoto.exists db "baz2"));

  (* get stats *)
  assert (Kyoto.count db = 3L);
  assert (Kyoto.size db > 10L);
  assert (Kyoto.path db = "+");

  (* fold the whole database *)
  assert (Kyoto.fold db (fun n x -> n+1) 0 = 3);

  (* use a cursor to iter over the database *)
  let cursor = Kyoto.cursor_open db in
  
  assert (Kyoto.cursor_next cursor = Some ("bar","step2"));
  assert (Kyoto.cursor_next cursor = Some ("baz","jump"));
  assert (Kyoto.cursor_next cursor = Some ("foo","hop"));
  assert (Kyoto.cursor_next cursor = None);

  Kyoto.cursor_close cursor;

  (* close the database *)
  Kyoto.close db



