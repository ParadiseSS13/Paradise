/// Damage on a steel floor is an overlay, so the floor itself should keep its look
/datum/game_test/room_test/floor_keeps_icon_when_damaged/Run()
	var/datum/test_puppeteer/player = new(src)
	var/turf/simulated/floor/plasteel/floor = player.change_turf_nearby(/turf/simulated/floor/plasteel, EAST)
	// Paint it like a floor painter would
	floor.icon_regular_floor = "tile_dark_standard"
	floor.icon_state = "tile_dark_standard"

	floor.burn_tile()
	TEST_ASSERT_EQUAL(floor.icon_state, "tile_dark_standard", "burning a dark steel floor changed how it looks")

	// A state that isn't in the floor's icon should still fall back to the plain tile
	floor.icon_regular_floor = "not_a_floor_icon_state"
	floor.update_icon()
	TEST_ASSERT_EQUAL(floor.icon_state, "tile_standard", "a floor with a missing icon state didn't fall back to the plain tile")
