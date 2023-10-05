/datum/client_login_processor/donator_check/process_result(datum/db_query/Q, client/C)
	if(IsGuestKey(C.ckey))
		return

	if(check_rights_client(R_ADMIN, FALSE, C))
		C.donator_level = DONATOR_LEVEL_MAX
		C.donor_loadout_points()
		return

	while(Q.NextRow())
		var/total = Q.item[1]
		switch(total)
			if(220 to 439)
				C.donator_level = 1
			if(440 to 999)
				C.donator_level = 2
			if(1000 to 2219)
				C.donator_level = 3
			if(2220 to 9999)
				C.donator_level = 4
			if(10000 to INFINITY)
				C.donator_level = DONATOR_LEVEL_MAX
		C.donor_loadout_points()

/datum/client_login_processor/donator_check/get_query(client/C)
	var/datum/db_query/query = SSdbcore.NewQuery({"
		SELECT CAST(SUM(amount) as UNSIGNED INTEGER) FROM budget
		WHERE ckey=:ckey
			AND is_valid=true
			AND date_start <= NOW()
			AND (NOW() < date_end OR date_end IS NULL)
		GROUP BY ckey
	"}, list("ckey" = C.ckey))

	return query
