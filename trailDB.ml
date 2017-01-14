
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
