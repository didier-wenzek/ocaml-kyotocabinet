#include <caml/memory.h>
#include <caml/mlvalues.h>
#include <caml/callback.h>
#include <caml/fail.h>
#include <caml/alloc.h>

#include <kclangc.h>

static
int const OPEN_FLAGS[] = {
  KCOREADER,
  KCOWRITER,
  KCOCREATE,
  KCOTRUNCATE,
  KCOAUTOTRAN,
  KCOAUTOSYNC,
  KCONOLOCK,
  KCOTRYLOCK,
  KCONOREPAIR
};

static
int decode_flags(value options, int const codes[])
{
  CAMLlocal1(head);
  int flags = 0;
  while (options!=Val_emptylist) {
    head = Field(options, 0);
    flags = flags | (codes[Int_val(head)]);
    options = Field(options, 1);
  }
  return flags;
}

static
void RAISE(const char *error)
{
  static value *exception_handler = NULL;
  if (exception_handler == NULL) {
    exception_handler = caml_named_value("kyotocabinet.error");
    if (exception_handler == NULL) {
      caml_failwith(error);
    }
  }
  caml_raise_with_string(*exception_handler, error);
}

extern CAMLprim
value kc_open(value path, value options)
{
  CAMLparam2(path, options);

  KCDB* db = kcdbnew();
  if (! kcdbopen(db, String_val(path), decode_flags(options, OPEN_FLAGS))) {
     const char *error = kcdbemsg(db);
     kcdbdel(db);
     RAISE(error);
  }

  CAMLreturn((value) db);
}

extern CAMLprim
value kc_close(value caml_db)
{
  CAMLparam1(caml_db);
  
  KCDB* db = (KCDB*) caml_db;
  if (! kcdbclose(db)) {
     const char *error = kcdbemsg(db);
     kcdbdel(db);
     RAISE(error);
  }

  kcdbdel(db);
  CAMLreturn(Val_unit);
}

extern CAMLprim
value kc_count(value caml_db)
{
  CAMLparam1(caml_db);
  CAMLlocal1(val);

  KCDB* db = (KCDB*) caml_db;
  int64_t count = kcdbcount(db);
  val = copy_int64(count);
  
  CAMLreturn(val);
}

extern CAMLprim
value kc_set(value caml_db, value key, value val)
{
  CAMLparam3(caml_db, key, val);
  
  KCDB* db = (KCDB*) caml_db;
  if (! kcdbset(db,
    String_val(key), caml_string_length(key),
    String_val(val), caml_string_length(val)
  )) {
     RAISE(kcdbemsg(db));
  }

  CAMLreturn(Val_unit);
}

static
const char* get_some_value(const char *kbuf, size_t ksiz, const char *vbuf, size_t vsiz, size_t *sp, void *opq)
{
  CAMLlocal1(str);

  str = caml_alloc_string(vsiz);
  memcpy(String_val(str), vbuf, vsiz);

  value *block = (value*) opq;
  *block = caml_alloc(1,0); // Some(str);
  Store_field(*block, 0, str); 

  return KCVISNOP;
}

static 
const char* get_no_value(const char *kbuf, size_t ksiz, size_t *sp, void *opq)
{
  value *val = (value*) opq;
  *val = Val_int(0); // None
  return KCVISNOP;
}

extern CAMLprim
value kc_get(value caml_db, value key)
{
  CAMLparam2(caml_db, key);
  CAMLlocal1(val);

  KCDB* db = (KCDB*) caml_db;
  if (! kcdbaccept(db,
    String_val(key), caml_string_length(key),
    get_some_value, get_no_value, &val, 0
  )) {
     RAISE(kcdbemsg(db));
  }
  
  CAMLreturn(val);
}

static
const char* exists_some_value(const char *kbuf, size_t ksiz, const char *vbuf, size_t vsiz, size_t *sp, void *opq)
{
  value *val = (value*) opq;
  *val = Val_true;
  return KCVISNOP;
}

static 
const char* exists_no_value(const char *kbuf, size_t ksiz, size_t *sp, void *opq)
{
  value *val = (value*) opq;
  *val = Val_false;
  return KCVISNOP;
}

extern CAMLprim
value kc_exists(value caml_db, value key)
{
  CAMLparam2(caml_db, key);
  CAMLlocal1(val);

  KCDB* db = (KCDB*) caml_db;
  if (! kcdbaccept(db,
    String_val(key), caml_string_length(key),
    exists_some_value, exists_no_value, &val, 0
  )) {
     RAISE(kcdbemsg(db));
  }
  
  CAMLreturn(val);
}

extern CAMLprim
value kc_remove(value caml_db, value key)
{
  CAMLparam2(caml_db, key);

  KCDB* db = (KCDB*) caml_db;
  if (! kcdbremove(db,
    String_val(key), caml_string_length(key)
  )) {
     if (kcdbecode(db) != KCENOREC) {
       RAISE(kcdbemsg(db));
     }
  }

  CAMLreturn(Val_unit);
}

extern CAMLprim
value kc_cursor_open(value caml_db)
{
  CAMLparam1(caml_db);

  KCDB* db = (KCDB*) caml_db;
  KCCUR* cur = kcdbcursor(db);
  if (! kccurjump(cur)) {
     const char *error = kccuremsg(cur);
     kccurdel(cur);
     RAISE(error);
  }

  CAMLreturn((value) cur);
}

extern CAMLprim
value kc_cursor_close(value caml_cursor)
{
  CAMLparam1(caml_cursor);
  
  KCCUR* cur = (KCCUR*) caml_cursor;
  kccurdel(cur);

  CAMLreturn(Val_unit);
}

static
const char* get_pair(const char *kbuf, size_t ksiz, const char *vbuf, size_t vsiz, size_t *sp, void *opq)
{
  CAMLlocal3(key,val,pair);

  key  = caml_alloc_string(ksiz);
  memcpy(String_val(key ), kbuf, ksiz);

  val = caml_alloc_string(vsiz);
  memcpy(String_val(val), vbuf, vsiz);

  pair = caml_alloc(2,0); // (tuple)
  Store_field(pair, 0, key); 
  Store_field(pair, 1, val); 

  value *block = (value*) opq;
  *block = pair;
  return KCVISNOP;
}

extern CAMLprim
value kc_cursor_next(value caml_cursor)
{
  CAMLparam1(caml_cursor);
  CAMLlocal2(val,pair);
  
  KCCUR* cur = (KCCUR*) caml_cursor;
  if (kccuraccept(cur, get_pair, &pair, 0, 1)) {
    val = caml_alloc(1,0); // Some(pair);
    Store_field(val, 0, pair); 
  }
  else {
     if (kccurecode(cur) == KCENOREC) {
       val = Val_int(0); // None
     }
     else {
       RAISE(kccuremsg(cur));
     }
  }
  
  CAMLreturn(val);
}

extern CAMLprim
value kc_fold(value caml_db, value caml_comb, value caml_seed)
{
  CAMLparam3(caml_db, caml_comb, caml_seed);
  CAMLlocal2(val,pair);
  val = caml_seed;

  KCDB* db = (KCDB*) caml_db;
  KCCUR* cur = kcdbcursor(db);
  if (! kccurjump(cur)) {
     const char *error = kccuremsg(cur);
     kccurdel(cur);
     RAISE(error);
  }

  int ok = 0;
  while ((ok=kccuraccept(cur, get_pair, &pair, 0, 1))) {
    val = caml_callback2(caml_comb, val, pair);
  }
  if (! ok && kccurecode(cur) != KCENOREC) {
     const char *error = kccuremsg(cur);
     kccurdel(cur);
     RAISE(error);
  }

  kccurdel(cur);
  CAMLreturn(val);
}
