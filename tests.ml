open TrailDB

let _ =
  let db = tdb_cons_open "/tmp/foo" ["unit";"value"] in
  tdb_cons_finalize db
