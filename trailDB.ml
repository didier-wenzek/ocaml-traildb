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
external tdb_event_filter_new: conjunction -> tdb_event_filter = "ocaml_event_filter_new"

