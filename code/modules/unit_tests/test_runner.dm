// Logging large amounts of test failures can cause performance issues
// significant enough to hit GitHub Actions timeout thresholds. This can happen
// intentionally (if there's a lot of legitimate map errors), or accidentally if
// a test condition is written incorrectly and starts e.g. logging failures for
// every single tile.
#ifdef LOCAL_UNIT_TESTS
#define MAX_MAP_TEST_FAILURE_COUNT 100
#else
#define MAX_MAP_TEST_FAILURE_COUNT 20
#endif

/datum/test_runner
	var/datum/unit_test/current_test
	var/failed_any_test = FALSE
	var/list/test_logs = list()
	var/list/durations = list()

/datum/test_runner/proc/Start()
	//trigger things to run the whole process
	Master.sleep_offline_after_initializations = FALSE
	// This will have the ticker set the game up
	// Running the tests is part of the ticker's start function, because I cant think of any better place to put it
	SSticker.force_start = TRUE


/datum/test_runner/proc/RunMap(z_level = 2)
	CHECK_TICK

	var/list/tests = list()

	for(var/I in subtypesof(/datum/map_per_tile_test))
		tests += new I
		test_logs[I] = list()
		durations[I] = 0

	for(var/turf/T in block(1, 1, z_level, world.maxx, world.maxy, z_level))
		for(var/datum/map_per_tile_test/test in tests)
			if(test.failure_count < MAX_MAP_TEST_FAILURE_COUNT)
				var/duration = REALTIMEOFDAY
				test.CheckTile(T)
				durations[test.type] += REALTIMEOFDAY - duration

				if(test.failure_count >= MAX_MAP_TEST_FAILURE_COUNT)
					test.Fail(T, "failure threshold reached at this tile")

		CHECK_TICK

	for(var/datum/map_per_tile_test/test in tests)
		if(!test.succeeded)
			failed_any_test = TRUE
			test_logs[test.type] += test.fail_reasons

	QDEL_LIST_CONTENTS(tests)


/datum/test_runner/proc/Run()
	CHECK_TICK

	for(var/I in subtypesof(/datum/unit_test))
		var/datum/unit_test/test = new I
		test_logs[I] = list()

		current_test = test
		var/duration = REALTIMEOFDAY

		test.Run()

		durations[I] = REALTIMEOFDAY - duration
		current_test = null

		if(!test.succeeded)
			failed_any_test = TRUE
			test_logs[I] += test.fail_reasons

		qdel(test)

		CHECK_TICK

	SSticker.reboot_helper("Unit Test Reboot", "tests ended", 0)


/datum/test_runner/proc/Finalize(emit_failures = FALSE)
	var/time = world.timeofday
	set waitfor = FALSE

	#ifdef LOCAL_UNIT_TESTS
	emit_failures = TRUE
	#endif

	var/list/fail_reasons
	if(GLOB)
		if(GLOB.total_runtimes != 0)
			fail_reasons = list("Total runtimes: [GLOB.total_runtimes]")
		if(!GLOB.log_directory)
			LAZYADD(fail_reasons, "Missing GLOB.log_directory!")
		if(failed_any_test)
			LAZYADD(fail_reasons, "Unit Tests failed!")
	else
		fail_reasons = list("Missing GLOB!")

	if(!fail_reasons)
		text2file("Success!", "data/clean_run.lk")

	var/list/result = list()
	result += "RUN  [time2text(time, "YYYY-MM-DD")]T[time2text(time, "hh:mm:ss")]"

	for(var/reason in fail_reasons)
		result += "FAIL [reason]"

	for(var/test in test_logs)
		if(length(test_logs[test]) == 0)
			result += "PASS [test] [durations[test] / 10]s"
		else
			result += "FAIL [test] [durations[test] / 10]s"
			result += "\t" + test_logs[test].Join("\n\t")

	for(var/entry in result)
		log_world(entry)

	if(emit_failures)
		var/filename = "data/test_run-[time2text(time, "YYYY-MM-DD")]T[time2text(time, "hh_mm_ss")].log"
		text2file(result.Join("\n"), filename)

	sleep(0)	//yes, 0, this'll let Reboot finish and prevent byond memes
	del(world)	//shut it down

#undef MAX_MAP_TEST_FAILURE_COUNT
