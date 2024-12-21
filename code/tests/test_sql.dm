// Unit test to check SQL version has been updated properly.,
/datum/game_test/sql_version/Run()
	// Check if the SQL version set in the code is equal to the CI DB config
	TEST_ASSERT_EQUAL(GLOB.configuration.database.version, SQL_VERSION, "SQL version error. You may need to update the example config.")
	TEST_ASSERT_EQUAL(SSdbcore.total_errors, 0, "SQL errors occurred on startup.")
