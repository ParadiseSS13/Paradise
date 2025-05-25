/datum/game_test/dynamic_budget/Run()
	var/datum/game_mode/dynamic/dynamic = new()

	// If calculate_budgets updates, and these need to change to match, the pattern is to put an assert at the beginning and end of each distinct range of players (with 100 here standing in for a non-existent upper limit).
	TEST_ASSERT_EQUAL(dynamic.calculate_budget(0), 7, "Flat budget incorrect.")
	TEST_ASSERT_EQUAL(dynamic.calculate_budget(4), 7, "Flat budget incorrect.")

	TEST_ASSERT_EQUAL(dynamic.calculate_budget(5), 7.5, "Lowpop budget incorrect.")
	TEST_ASSERT_EQUAL(dynamic.calculate_budget(20), 15, "Lowpop budget incorrect.")

	TEST_ASSERT_EQUAL(dynamic.calculate_budget(21), 16.5, "Midpop budget incorrect.")
	TEST_ASSERT_EQUAL(dynamic.calculate_budget(30), 30, "Midpop budget incorrect.")

	TEST_ASSERT_EQUAL(dynamic.calculate_budget(31), 31, "Highpop budget incorrect.")
	TEST_ASSERT_EQUAL(dynamic.calculate_budget(100), 100, "Highpop budget incorrect.")
