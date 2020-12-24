/*
Usage:
Override /Run() to run your test code
Call Fail() to fail the test (You should specify a reason)
You may use /New() and /Destroy() for setup/teardown respectively
You can use the run_loc_bottom_left and run_loc_top_right to get turfs for testing
*/

/// VARS FOR UNIT TESTS
GLOBAL_DATUM(current_test, /datum/unit_test)
GLOBAL_VAR_INIT(failed_any_test, FALSE)
GLOBAL_VAR(test_log)

/datum/unit_test
	//Bit of metadata for the future maybe
	var/list/procs_tested

	//usable vars
	var/turf/run_loc_bottom_left
	var/turf/run_loc_top_right

	//internal shit
	var/succeeded = TRUE
	var/list/fail_reasons

/datum/unit_test/New()
	run_loc_bottom_left = locate(1, 1, 1)
	run_loc_top_right = locate(5, 5, 1)

/datum/unit_test/Destroy()
	//clear the test area
	for(var/atom/movable/AM in block(run_loc_bottom_left, run_loc_top_right))
		qdel(AM)
	return ..()

/datum/unit_test/proc/Run()
	Fail("Run() called parent or not implemented")

/datum/unit_test/proc/Fail(reason = "No reason")
	succeeded = FALSE

	if(!istext(reason))
		reason = "FORMATTED: [reason != null ? reason : "NULL"]"

	LAZYADD(fail_reasons, reason)

/proc/RunUnitTests()
	CHECK_TICK

	for(var/I in subtypesof(/datum/unit_test))
		var/datum/unit_test/test = new I

		GLOB.current_test = test
		var/duration = REALTIMEOFDAY

		test.Run()

		duration = REALTIMEOFDAY - duration
		GLOB.current_test = null
		GLOB.failed_any_test |= !test.succeeded

		var/list/log_entry = list("[test.succeeded ? "PASS" : "FAIL"]: [I] [duration / 10]s")
		var/list/fail_reasons = test.fail_reasons

		qdel(test)

		for(var/J in 1 to LAZYLEN(fail_reasons))
			log_entry += "\tREASON #[J]: [fail_reasons[J]]"
		log_world(log_entry.Join("\n"))

		CHECK_TICK

	world.Reboot("Unit Test Reboot", "tests ended", 0)


// OTHER MISC PROCS RELATED TO UNIT TESTS //

/world/proc/HandleTestRun()
	//trigger things to run the whole process
	Master.sleep_offline_after_initializations = FALSE
	// This will have the ticker set the game up
	// Running the tests is part of the ticker's start function, because I cant think of any better place to put it
	SSticker.force_start = TRUE

/world/proc/FinishTestRun()
	set waitfor = FALSE
	var/list/fail_reasons
	if(GLOB)
		if(GLOB.total_runtimes != 0)
			fail_reasons = list("Total runtimes: [GLOB.total_runtimes]")
		if(!GLOB.log_directory)
			LAZYADD(fail_reasons, "Missing GLOB.log_directory!")
		if(GLOB.failed_any_test)
			LAZYADD(fail_reasons, "Unit Tests failed!")
	else
		fail_reasons = list("Missing GLOB!")
	if(!fail_reasons)
		text2file("Success!", "data/clean_run.lk")
	else
		log_world("Test run failed!\n[fail_reasons.Join("\n")]")
	sleep(0)	//yes, 0, this'll let Reboot finish and prevent byond memes
	del(src)	//shut it down
