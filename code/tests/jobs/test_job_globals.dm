/datum/game_test/job_globals/Run()
	return

/datum/game_test/job_globals/proc/is_list_unique(list/L)
	var/list_length = length(L)
	var/unique_list = uniqueList(L)
	var/unique_list_length = length(unique_list)
	return list_length == unique_list_length

/datum/game_test/job_globals/proc/validate_list(list/L, list_name)
	if(!is_list_unique(L))
		TEST_FAIL("job_globals list '[list_name]' contains duplicate values.")

/datum/game_test/job_globals/no_duplicates/Run()
	validate_list(GLOB.station_departments, "station_departments")
	validate_list(GLOB.command_positions, "command_positions")
	validate_list(GLOB.command_head_positions, "command_head_positions")
	validate_list(GLOB.engineering_positions, "engineering_positions")
	validate_list(GLOB.medical_positions, "medical_positions")
	validate_list(GLOB.science_positions, "science_positions")
	validate_list(GLOB.supply_positions, "supply_positions")
	validate_list(GLOB.service_positions, "service_positions")
	validate_list(GLOB.security_positions, "security_positions")
	validate_list(GLOB.active_security_positions, "active_security_positions")
	validate_list(GLOB.assistant_positions, "assistant_positions")
	validate_list(GLOB.nonhuman_positions, "nonhuman_positions")
