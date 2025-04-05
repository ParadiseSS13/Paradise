// This exists so that logs are the designated format. If they arent, it breaks logging tooling. Also 8601 is king.
#define TEST_MESSAGE "Log time format test"
#define TEST_LOG_FILE "data/ci_testing.log"

/proc/generate_test_log_message(time)
	var/date_portion = time2text(time, "YYYY-MM-DD")
	var/time_portion = time2text(time, "hh:mm:ss")
	return "\[[date_portion]T[time_portion]] [TEST_MESSAGE]"


/datum/game_test/log_format/Run()
	// Generate a list of valid log timestamps. It can be the current time, or up to 2 seconds later to account for spurious CI lag
	var/valid_lines = list(
		"[generate_test_log_message(world.timeofday)]",
		"[generate_test_log_message(world.timeofday + 10)]",
		"[generate_test_log_message(world.timeofday + 20)]",
	)

	rustlibs_log_write(TEST_LOG_FILE, TEST_MESSAGE)

	var/list/lines = file2list(TEST_LOG_FILE)
	TEST_ASSERT(lines[1] in valid_lines, \
		"Rustlibs log format is not valid 8601 format. Expected '[generate_test_log_message(world.timeofday)]', got '[lines[1]]'")

#undef TEST_MESSAGE
#undef TEST_LOG_FILE
