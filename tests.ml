let _ =
  let db = TrailDB.tdb_cons_open "/tmp/foo" ["unit";"value"] in
  TrailDB.tdb_cons_finalize db;
  TrailDB.tdb_cons_close db
