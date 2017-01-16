type tdb_cons
type tdb
type path = string
type uuid
type timestamp = int64
type field_name = string
type field_value = string
type trail_id
type tdb_event
type tdb_item
type tdb_cursor
type tdb_event_filter
type literal = Pos of tdb_item | Neg of tdb_item
type disjunction = Or of literal list
type conjunction = And of disjunction list

type error = 
    (* generic *)
    | TDB_ERR_NOMEM
    | TDB_ERR_PATH_TOO_LONG
    | TDB_ERR_UNKNOWN_FIELD
    | TDB_ERR_UNKNOWN_UUID
    | TDB_ERR_INVALID_TRAIL_ID
    | TDB_ERR_HANDLE_IS_NULL
    | TDB_ERR_HANDLE_ALREADY_OPENED
    | TDB_ERR_UNKNOWN_OPTION
    | TDB_ERR_INVALID_OPTION_VALUE
    | TDB_ERR_INVALID_UUID

    (* io *)
    | TDB_ERR_IO_OPEN
    | TDB_ERR_IO_CLOSE
    | TDB_ERR_IO_WRITE
    | TDB_ERR_IO_READ
    | TDB_ERR_IO_TRUNCATE
    | TDB_ERR_IO_PACKAGE

    (* tdb_open *)
    | TDB_ERR_INVALID_INFO_FILE
    | TDB_ERR_INVALID_VERSION_FILE
    | TDB_ERR_INCOMPATIBLE_VERSION
    | TDB_ERR_INVALID_FIELDS_FILE
    | TDB_ERR_INVALID_UUIDS_FILE
    | TDB_ERR_INVALID_CODEBOOK_FILE
    | TDB_ERR_INVALID_TRAILS_FILE
    | TDB_ERR_INVALID_LEXICON_FILE
    | TDB_ERR_INVALID_PACKAGE

    (* tdb_cons *)
    | TDB_ERR_TOO_MANY_FIELDS
    | TDB_ERR_DUPLICATE_FIELDS
    | TDB_ERR_INVALID_FIELDNAME
    | TDB_ERR_TOO_MANY_TRAILS
    | TDB_ERR_VALUE_TOO_LONG
    | TDB_ERR_APPEND_FIELDS_MISMATCH
    | TDB_ERR_LEXICON_TOO_LARGE
    | TDB_ERR_TIMESTAMP_TOO_LARGE
    | TDB_ERR_TRAIL_TOO_LONG

    (* querying *)
    | TDB_ERR_ONLY_DIFF_FILTER
    | TDB_ERR_NO_SUCH_ITEM
    | TDB_ERR_INVALID_RANGE
    | TDB_ERR_INCORRECT_TERM_TYPE

exception Error of error

let _ =
  Callback.register_exception "traildb.error" (Error(TDB_ERR_NOMEM))

external tdb_cons_open: path -> field_name list -> tdb_cons = "ocaml_tdb_cons_open"
external tdb_cons_add: tdb_cons -> uuid -> timestamp -> field_value list -> unit = "ocaml_tdb_cons_add"
external tdb_cons_finalize: tdb_cons -> unit = "ocaml_tdb_cons_finalize"
external tdb_cons_close: tdb_cons -> unit = "ocaml_tdb_cons_close"
external tdb_cons_append: tdb_cons -> tdb -> unit = "ocaml_tdb_cons_append"
external tdb_open: path -> tdb = "ocaml_tdb_open"
external tdb_close: tdb -> unit = "ocaml_tdb_close"
external tdb_dontneed: tdb -> unit = "ocaml_tdb_dontneed"
external tdb_willneed: tdb -> unit = "ocaml_tdb_willneed"
external tdb_num_trails: tdb -> int64 = "ocaml_tdb_num_trails"
external tdb_num_events: tdb -> int64 = "ocaml_tdb_num_events"
external tdb_min_timestamp: tdb -> timestamp = "ocaml_tdb_min_timestamp"
external tdb_max_timestamp: tdb -> timestamp = "ocaml_tdb_max_timestamp"
external tdb_num_fields: tdb -> int64 = "ocaml_tdb_num_fields"
external tdb_cursor_new: tdb -> tdb_cursor = "ocaml_tdb_cursor_new"
external tdb_cursor_free: tdb_cursor -> unit = "ocaml_tdb_cursor_free"
external tdb_get_trail: tdb_cursor -> trail_id -> unit = "ocaml_tdb_get_trail"
external tdb_get_trail_length: tdb_cursor -> int64 = "ocaml_tdb_get_trail_length"
external tdb_cursor_next: tdb_cursor -> tdb_event option = "ocaml_tdb_cursor_next"
external tdb_cursor_peek: tdb_cursor -> tdb_event option = "ocaml_tdb_cursor_peek"
external tdb_error_str: error -> string = "ocaml_tdb_error_str"

let tdb_event_filter_new conjunction = raise (Invalid_argument "TODO")
