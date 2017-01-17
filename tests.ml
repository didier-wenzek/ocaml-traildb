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

let create_simple_traildb () =
  try
    let db = tdb_cons_open "/tmp/bar" ["unit";"value"] in
    let uuid = Uuidm.(v5 ns_oid "trail_0") in
    tdb_cons_add db uuid  123456L ["temperature";"12"];
    tdb_cons_add db uuid  123457L ["temperature";"13"];
    tdb_cons_add db uuid  123458L ["temperature";"14"];
    tdb_cons_add db uuid  123459L ["temperature";"13"];
    tdb_cons_finalize db
  with Error err -> begin
    prerr_endline (tdb_error_str err);
    assert false
  end

let the = function 
  | Some x -> x
  | None -> raise Not_found

let ($) f x = f x

let read_simple_traildb () =
  try
    let db = tdb_open "/tmp/bar" in
    assert (tdb_num_trails db = 1L);
    assert (tdb_num_events db = 4L);
    assert (tdb_num_fields db = 3L);
    assert (tdb_min_timestamp db = 123456L);
    assert (tdb_max_timestamp db = 123459L);
    assert (tdb_lexicon_size db (the $ tdb_get_field db "unit") = 2L); (* "" + "temperature" *)
    assert (tdb_lexicon_size db (the $ tdb_get_field db "value") = 4L); (* "" + all values *)
    let cursor = tdb_cursor_new db in
    tdb_get_trail cursor 0L;
    assert (tdb_get_trail_length cursor = 4L);
    tdb_get_trail cursor 0L;
    let event = tdb_cursor_peek cursor in
    begin
      assert ((the event).timestamp = 123456L);
      assert (List.length (the event).values = 2);
      match (the event).values with
      | [item1;item2] ->
        assert (tdb_item_field item1 = (the $ tdb_get_field db "unit"));
        assert (tdb_get_item_value db item1 = "temperature");
        assert (tdb_item_field item2 = (the $ tdb_get_field db "value"));
        assert (tdb_get_item_value db item2 = "12");
      | _ -> assert false
    end;
    let event = tdb_cursor_next cursor in assert ((the event).timestamp = 123456L);
    let event = tdb_cursor_next cursor in assert ((the event).timestamp = 123457L);
    let event = tdb_cursor_next cursor in assert ((the event).timestamp = 123458L);
    let event = tdb_cursor_next cursor in assert ((the event).timestamp = 123459L);
    let event = tdb_cursor_next cursor in assert (event = None);
  with Error err -> begin
    prerr_endline (tdb_error_str err);
    assert false
  end

let _ =
  create_empty_traildb ();
  read_empty_traildb ();
  create_simple_traildb ();
  read_simple_traildb ()
