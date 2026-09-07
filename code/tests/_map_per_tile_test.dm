/**
  * Map per-tile test.
  *
  * Per-tile map tests iterate over each tile of a map to perform a check, and
  * fails the test if a tile does not pass the check. A new test can be
  * written by extending /datum/map_per_tile_test, and implementing the check
  * in CheckTile.
  */
/datum/map_per_tile_test
	var/succeeded = TRUE
	var/list/fail_reasons
	var/failure_count = 0

/datum/map_per_tile_test/proc/CheckTile(turf/T)
	Fail("CheckTile() called parent or not implemented")

/datum/map_per_tile_test/proc/Fail(turf/T, reason)
	succeeded = FALSE
	LAZYADD(fail_reasons, "[T.x],[T.y],[T.z]: [reason]")
	failure_count++
