#include <string.h>
#include <caml/memory.h>
#include <caml/mlvalues.h>
#include <caml/callback.h>
#include <caml/fail.h>
#include <caml/alloc.h>
#include <string.h>
#include <caml/memory.h>
#include <caml/mlvalues.h>
#include <caml/callback.h>
#include <caml/fail.h>
#include <caml/alloc.h>
#include <traildb.h>

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

