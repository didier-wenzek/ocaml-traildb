open TrailDB

let create_empty_traildb () =
  try
    let db = tdb_cons_open "/tmp/foo" ["unit";"value"] in
    tdb_cons_finalize db
  with Error err -> begin
    prerr_endline (tdb_error_str err);
    assert false
  end

let read_empty_traildb () =
  try
    let db = tdb_open "/tmp/foo" in
    assert (tdb_num_trails db = 0L);
    assert (tdb_num_events db = 0L);
    assert (tdb_num_fields db = 3L);
    assert (tdb_get_field_name db 0L = Some "time");
    assert (tdb_get_field_name db 1L = Some "unit");
    assert (tdb_get_field db "value" = Some 2L);
    assert (tdb_get_field_name db 6L = None);
    assert (tdb_get_field db "foo" = None)
  with Error err -> begin
    prerr_endline (tdb_error_str err);
    assert false
  end

let _ =
  create_empty_traildb ();
  read_empty_traildb ()
