#include <string.h>
#include <caml/memory.h>
#include <caml/mlvalues.h>
#include <caml/callback.h>
#include <caml/fail.h>
#include <caml/alloc.h>
#include <caml/custom.h>
#include <traildb.h>

/* -------------------- */
/* Working with errors. */
/* -------------------- */

/* Must be synchronized with TrailDB.error. */
static int const ERROR_CODES[] = {
    /* generic */

    TDB_ERR_NOMEM,
    TDB_ERR_PATH_TOO_LONG,
    TDB_ERR_UNKNOWN_FIELD,
    TDB_ERR_UNKNOWN_UUID,
    TDB_ERR_INVALID_TRAIL_ID,
    TDB_ERR_HANDLE_IS_NULL,
    TDB_ERR_HANDLE_ALREADY_OPENED,
    TDB_ERR_UNKNOWN_OPTION,
    TDB_ERR_INVALID_OPTION_VALUE,
    TDB_ERR_INVALID_UUID,

    /* io */

    TDB_ERR_IO_OPEN,
    TDB_ERR_IO_CLOSE,
    TDB_ERR_IO_WRITE,
    TDB_ERR_IO_READ,
    TDB_ERR_IO_TRUNCATE,
    TDB_ERR_IO_PACKAGE,

    /* tdb_open */

    TDB_ERR_INVALID_INFO_FILE,
    TDB_ERR_INVALID_VERSION_FILE,
    TDB_ERR_INCOMPATIBLE_VERSION,
    TDB_ERR_INVALID_FIELDS_FILE,
    TDB_ERR_INVALID_UUIDS_FILE,
    TDB_ERR_INVALID_CODEBOOK_FILE,
    TDB_ERR_INVALID_TRAILS_FILE,
    TDB_ERR_INVALID_LEXICON_FILE,
    TDB_ERR_INVALID_PACKAGE,

    /* tdb_cons */

    TDB_ERR_TOO_MANY_FIELDS,
    TDB_ERR_DUPLICATE_FIELDS,
    TDB_ERR_INVALID_FIELDNAME,
    TDB_ERR_TOO_MANY_TRAILS,
    TDB_ERR_VALUE_TOO_LONG,
    TDB_ERR_APPEND_FIELDS_MISMATCH,
    TDB_ERR_LEXICON_TOO_LARGE,
    TDB_ERR_TIMESTAMP_TOO_LARGE,
    TDB_ERR_TRAIL_TOO_LONG,

    /* querying */
    TDB_ERR_ONLY_DIFF_FILTER,
    TDB_ERR_NO_SUCH_ITEM,
    TDB_ERR_INVALID_RANGE,
    TDB_ERR_INCORRECT_TERM_TYPE
};

static int const ERR_UNKNOWN = (sizeof ERROR_CODES) / (sizeof ERROR_CODES[0]);

void raise_exception(tdb_error err)
{
  CAMLparam0();
  static value *exception_handler = NULL;

  if (exception_handler == NULL) {
    exception_handler = caml_named_value("traildb.error");
    if (exception_handler == NULL) {
      caml_failwith("Internal error: unknown exception handler: traildb.error");
    }
  }

  int i;
  for (i = 0; i < ERR_UNKNOWN; i++) {
    if (err == ERROR_CODES[i]) {
      break;
    }
  }

  if (i < ERR_UNKNOWN) caml_raise_constant(Val_int(i));
  else caml_failwith("Internal error: unknown traildb error code");

  CAMLnoreturn;
}

extern CAMLprim
value ocaml_tdb_error_str(value caml_err) {
  CAMLparam1(caml_err);
  CAMLlocal1(caml_msg);

  caml_msg = caml_copy_string(tdb_error_str (Int_val(caml_err)));

  CAMLreturn(caml_msg);
}

/* --------------------------------------- */
/* Custom wrappers and operations.         */
/* --------------------------------------- */

#define Tdb_cons_val(v) (*((tdb_cons **) Data_custom_val(v)))

static void tdb_cons_custom_finalize(value v) {
  tdb_cons_close(Tdb_cons_val(v));
}

static struct custom_operations tdb_cons_operations = {
  "tdb_cons",
  tdb_cons_custom_finalize,
  custom_compare_default,
  custom_compare_ext_default,
  custom_hash_default,
  custom_serialize_default,
  custom_deserialize_default
};

static value alloc_tdb_cons_wrapper (tdb_cons* tdb) {
  value v = alloc_custom(&tdb_cons_operations, sizeof(tdb_cons*), 0, 1);
  Tdb_cons_val(v) = tdb;
  return v;
}

#define Tdb_val(v) (*((struct _tdb **) Data_custom_val(v)))

static void tdb_custom_finalize(value v) {
  tdb_close(Tdb_val(v));
}

static struct custom_operations tdb_operations = {
  "tdb",
  tdb_custom_finalize,
  custom_compare_default,
  custom_compare_ext_default,
  custom_hash_default,
  custom_serialize_default,
  custom_deserialize_default
};

static value alloc_tdb_wrapper (tdb* tdb) {
  value v = alloc_custom(&tdb_operations, sizeof(tdb), 0, 1);
  Tdb_val(v) = tdb;
  return v;
}

/* --------------------------------------- */
/* Working with TrailDB database builders. */
/* --------------------------------------- */

extern CAMLprim
value ocaml_tdb_cons_open(value caml_path, value caml_fields) {
  CAMLparam2(caml_path, caml_fields);
  CAMLlocal1(caml_tdb_cons);

  tdb_cons* tdb = tdb_cons_init();
  caml_tdb_cons = alloc_tdb_cons_wrapper(tdb);

  CAMLreturn(caml_tdb_cons);
}

extern CAMLprim
value ocaml_tdb_cons_add(value caml_tdb_cons, value caml_uuid, value caml_timestamp, value caml_values) {
  CAMLparam4(caml_tdb_cons, caml_uuid, caml_timestamp, caml_values);
  
  CAMLreturn(Val_unit);
}

extern CAMLprim
value ocaml_tdb_cons_append(value caml_tdb_cons, value caml_tdb) {
  CAMLparam2(caml_tdb_cons, caml_tdb);
  
  CAMLreturn(Val_unit);
}

extern CAMLprim
value ocaml_tdb_cons_finalize(value caml_tdb_cons) {
  CAMLparam1(caml_tdb_cons);
  
  tdb_cons *tdb = Tdb_cons_val(caml_tdb_cons);
  tdb_error err = tdb_cons_finalize(tdb);
  if (err) raise_exception(err);

  CAMLreturn(Val_unit);
}

/* ----------------------------------------- */
/* Working with TrailDB read-only databases. */
/* ----------------------------------------- */

extern CAMLprim
value ocaml_tdb_open(value caml_path) {
  CAMLparam1(caml_path);
  CAMLlocal1(caml_tdb);

  tdb* tdb = tdb_init();
  caml_tdb = alloc_tdb_wrapper(tdb);

  CAMLreturn(caml_tdb);
}

extern CAMLprim
value ocaml_tdb_dontneed(value caml_tdb) {
  CAMLparam1(caml_tdb);
  
  CAMLreturn(Val_unit);
}

extern CAMLprim
value ocaml_tdb_willneed(value caml_tdb) {
  CAMLparam1(caml_tdb);
  
  CAMLreturn(Val_unit);
}

extern CAMLprim
value ocaml_tdb_num_trails(value caml_tdb) {
  CAMLparam1(caml_tdb);
  CAMLlocal1(caml_num);

  CAMLreturn(caml_num);
}

extern CAMLprim
value ocaml_tdb_num_events(value caml_tdb) {
  CAMLparam1(caml_tdb);
  CAMLlocal1(caml_num);

  CAMLreturn(caml_num);
}

extern CAMLprim
value ocaml_tdb_num_fields(value caml_tdb) {
  CAMLparam1(caml_tdb);
  CAMLlocal1(caml_num);

  CAMLreturn(caml_num);
}

extern CAMLprim
value ocaml_tdb_min_timestamp(value caml_tdb) {
  CAMLparam1(caml_tdb);
  CAMLlocal1(caml_timestamp);

  CAMLreturn(caml_timestamp);
}

extern CAMLprim
value ocaml_tdb_max_timestamp(value caml_tdb) {
  CAMLparam1(caml_tdb);
  CAMLlocal1(caml_timestamp);

  CAMLreturn(caml_timestamp);
}

extern CAMLprim
value ocaml_tdb_cursor_new(value caml_tdb) {
  CAMLparam1(caml_tdb);
  CAMLlocal1(caml_cursor);

  CAMLreturn(caml_cursor);
}

extern CAMLprim
value ocaml_tdb_get_trail(value caml_cursor, value caml_trail) {
  CAMLparam2(caml_cursor, caml_trail);
  
  CAMLreturn(Val_unit);
}

extern CAMLprim
value ocaml_tdb_get_trail_length(value caml_cursor) {
  CAMLparam1(caml_cursor);
  CAMLlocal1(caml_num);

  CAMLreturn(caml_num);
}

extern CAMLprim
value ocaml_tdb_cursor_next(value caml_cursor) {
  CAMLparam1(caml_cursor);
  CAMLlocal1(caml_event_option);

  CAMLreturn(caml_event_option);
}

extern CAMLprim
value ocaml_tdb_cursor_peek(value caml_cursor) {
  CAMLparam1(caml_cursor);
  CAMLlocal1(caml_event_option);

  CAMLreturn(caml_event_option);
}
