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
  let db = tdb_open "/tmp/foo" in
  Format.printf "tdb_num_fields = %Ld\n%!" (tdb_num_fields db);
  assert (tdb_num_trails db = 0L);
  assert (tdb_num_events db = 0L);
  assert (tdb_num_fields db = 3L)

let _ =
  create_empty_traildb ();
  read_empty_traildb ()
