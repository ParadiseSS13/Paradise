#define MAX_SAVE_SLOTS_SS220 3

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
		C.donor_character_slots()

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

/client/donor_loadout_points()
	if(!prefs)
		return

	prefs.max_gear_slots = GLOB.configuration.general.base_loadout_points

	switch(donator_level)
		if(1)
			prefs.max_gear_slots += 2
		if(2)
			prefs.max_gear_slots += 4
		if(3)
			prefs.max_gear_slots += 8
		if(4)
			prefs.max_gear_slots += 12
		if(5)
			prefs.max_gear_slots += 16

/client/proc/donor_character_slots()
	if(!prefs)
		return

	prefs.max_save_slots = MAX_SAVE_SLOTS_SS220

	switch(donator_level)
		if(1)
			prefs.max_save_slots += 2
		if(2)
			prefs.max_save_slots += 4
		if(3)
			prefs.max_save_slots += 6
		if(4)
			prefs.max_save_slots += 8
		if(5)
			prefs.max_save_slots += 10

	prefs.character_saves.len = prefs.max_save_slots

#undef MAX_SAVE_SLOTS_SS220
