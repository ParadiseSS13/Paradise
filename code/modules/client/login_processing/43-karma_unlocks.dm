/datum/client_login_processor/karma_unlocks
	priority = 43

/datum/client_login_processor/karma_unlocks/get_query(client/C)
	var/datum/db_query/query = SSdbcore.NewQuery("SELECT job, species FROM whitelist WHERE ckey=:ckey", list(
		"ckey" = C.ckey
	))
	return query

/datum/client_login_processor/karma_unlocks/process_result(datum/db_query/Q, client/C)
	while(Q.NextRow())
		// Lets split stuff apart
		C.karmaholder.unlocked_jobs = splittext(Q.item[1], ",")
		C.karmaholder.unlocked_species = splittext(Q.item[2], ",") // these should really be JSON

		for(var/i in 1 to length(C.karmaholder.unlocked_jobs))
			C.karmaholder.unlocked_jobs[i] = trim(C.karmaholder.unlocked_jobs[i]) // Trim whitespace

		for(var/i in 1 to length(C.karmaholder.unlocked_species))
			C.karmaholder.unlocked_species[i] = trim(C.karmaholder.unlocked_species[i]) // Trim whitespace
