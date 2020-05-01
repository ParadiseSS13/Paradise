// Unit test to check SQL version has been updated properly.,
/datum/unit_test/sql_version/Run()
	if(config.sql_enabled && sql_version != SQL_VERSION)
		Fail("SQL version error: Game is running V[SQL_VERSION] but config is V[sql_version]. You may need to update tools/travis/dbconfig.txt")
