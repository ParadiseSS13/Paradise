/datum/game_test/room_test/ventcrawl
	var/mob/living/simple_animal/slime = null
	var/obj/machinery/vent = null
	var/obj/structure/table/table = null
	var/setup_complete = FALSE

/datum/milla_safe_must_sleep/ventcrawl_test_setup

/datum/milla_safe_must_sleep/ventcrawl_test_setup/on_run(datum/game_test/room_test/ventcrawl/test)
	// I'm sure get_area_turfs is totally deterministic and this will never go wrong
	var/turf/run_loc_bottom_left = test.available_turfs[1]
	// This setup creates turfs that initialize themselves in MILLA on creation, which is why we need to be MILLA-safe.
	var/datum/map_template/template = GLOB.map_templates["test_ventcrawl.dmm"]
	if(!template.load(run_loc_bottom_left))
		test.Fail("Failed to load 'test_ventcrawl.dmm'")

	test.slime = new /mob/living/simple_animal/slime/unit_test_dummy(run_loc_bottom_left)
	test.vent = test.find_spawned_test_object(run_loc_bottom_left, /obj/machinery/atmospherics/unary/vent_pump)
	test.table = test.find_spawned_test_object(get_step(run_loc_bottom_left, EAST), /obj/structure/table)
	test.setup_complete = TRUE

/datum/game_test/room_test/ventcrawl/proc/find_spawned_test_object(turf/location as turf, test_object_type)
	for(var/content in location.contents)
		if(istype(content, test_object_type))
			return content
	TEST_FAIL("Couldn't find spawned test object of type: [test_object_type].")

/datum/game_test/room_test/ventcrawl/Run()
	var/datum/milla_safe_must_sleep/ventcrawl_test_setup/milla = new()
	milla.invoke_async(src)
	while(!setup_complete)
		sleep(world.tick_lag)

	// Enter vent
	vent.AltClick(slime)
	TEST_ASSERT_EQUAL(slime.loc, vent, "failed to crawl into vent.")

	// Movement
	slime.loc.relaymove(slime, EAST)
	TEST_ASSERT_NOTEQUAL(slime.loc, vent, "failed to step EAST while ventcrawling.")

	// Try to flip table on top of pipe, while inside pipe (shouldn't work)
	table.AltShiftClick(slime)
	TEST_ASSERT_NOT(table.flipped, "Shouldn't be possible to flip structures while inside vent.")

	// Exit vent
	slime.loc.relaymove(slime, EAST)
	TEST_ASSERT(isturf(slime.loc), "wasn't able to ventcrawl out of vent.")
