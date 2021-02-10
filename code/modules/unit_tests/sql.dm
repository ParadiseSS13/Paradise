// Unit test to check SQL version has been updated properly.,
/datum/unit_test/sql_version/Run()
	// Check if the SQL version set in the code is equal to the CI DB config
	if(config.sql_enabled && sql_version != SQL_VERSION)
		Fail("SQL version error: Game is running V[SQL_VERSION] but config is V[sql_version]. You may need to update tools/ci/dbconfig.txt")
	// Check if the CI DB config is up to date with the example dbconfig
	// This proc is a little unclean but it works
	var/example_db_version
	var/list/Lines = file2list("config/example/dbconfig.txt")
	for(var/t in Lines)
		if(!t)	continue

		t = trim(t)
		if(length(t) == 0)
			continue
		else if(copytext(t, 1, 2) == "#")
			continue

		var/pos = findtext(t, " ")
		var/name = null
		var/value = null

		if(pos)
			name = lowertext(copytext(t, 1, pos))
			value = copytext(t, pos + 1)
		else
			name = lowertext(t)

		if(!name)
			continue

		switch(name)
			if("db_version")
				example_db_version = text2num(value)

	if(!example_db_version)
		Fail("SQL version error: File config/example/dbconfig.txt does not have a valid SQL version set!")

	if(example_db_version != SQL_VERSION)
		Fail("SQL version error: Game is running V[SQL_VERSION] but config/example/dbconfig.txt is V[example_db_version].")

	if(SSdbcore.total_errors > 0)
		Fail("SQL errors occured on startup. Please fix them.")


