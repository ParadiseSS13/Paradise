// Unit test to check SQL version has been updated properly.,
/datum/unit_test/sql_version/Run()
	// Check if the SQL version set in the code is equal to the CI DB config
	if(GLOB.configuration.database.version != SQL_VERSION)
		Fail("SQL version error: Game is running V[SQL_VERSION] but config is V[GLOB.configuration.database.version]. You may need to update the example config.")

	if(SSdbcore.total_errors > 0)
		Fail("SQL errors occured on startup. Please fix them.")


