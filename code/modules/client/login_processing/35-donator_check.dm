/datum/client_login_processor/donator_check
	priority = 35

/datum/client_login_processor/donator_check/get_query(client/C)
	var/datum/db_query/query = SSdbcore.NewQuery("SELECT ckey, tier, active FROM donators WHERE ckey=:ckey", list(
		"ckey" = C.ckey
	))
	return query

/datum/client_login_processor/donator_check/process_result(datum/db_query/Q, client/C)
	if(IsGuestKey(C.key))
		return

	// Admins get all donor perks
	if(check_rights_client(R_ADMIN, FALSE, C))
		C.donator_level = DONATOR_LEVEL_MAX
		C.donor_loadout_points()
		return

	while(Q.NextRow())
		if(!text2num(Q.item[3]))
			// Inactive donator.
			C.donator_level = 0
			return

		C.donator_level = text2num(Q.item[2])
		C.donor_loadout_points()
