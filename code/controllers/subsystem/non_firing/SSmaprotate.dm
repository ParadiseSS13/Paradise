SUBSYSTEM_DEF(maprotate)
	name = "Maprotate"
	flags = SS_NO_FIRE

	var/rotation_mode = MAPROTATION_MODE_NORMAL_VOTE
	var/setup_done = FALSE

// Debugging purposes. Im not having people change this on the fly.
/datum/controller/subsystem/maprotate/vv_edit_var(var_name, var_value)
	if(((var_name == "rotation_mode") || (var_name == "setup_done")) && !check_rights(R_MAINTAINER))
		return FALSE

	. = ..()

/datum/controller/subsystem/maprotate/Initialize()
	if(!SSdbcore.IsConnected())
		return

	// Make a quick list for number to date lookups
	var/list/days = list("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday")

	// Make a map of rotation modes to descriptions
	var/list/rotation_descs = list()
	rotation_descs[MAPROTATION_MODE_NORMAL_VOTE] = "there is normal map voting."
	rotation_descs[MAPROTATION_MODE_NO_DUPLICATES] = "map votes will not include the current map."
	rotation_descs[MAPROTATION_MODE_FULL_RANDOM] = "the map for next round is randomised."
	rotation_descs[MAPROTATION_MODE_HYBRID_FPTP_NO_DUPLICATES] = "the map for next round is weighted off your preferences and past maps"

	// Yes. I am using the DB server to get a numerical weekday
	// 0 = Monday
	// 1 = Tuesday
	// 2 = Wednesday
	// 3 = Thursday
	// 4 = Friday
	// 5 = Saturday
	// 6 = Sunday

	var/datum/db_query/dbq = SSdbcore.NewQuery("SELECT WEEKDAY(NOW()) AS d")
	if(!dbq.warn_execute())
		log_startup_progress("Somehow, we failed to extract a numerical day from the DB. ?????????????")
		return

	var/day_index = 0

	// Were gonna increase the DB value by 1 so we have 1-7, therefore we can use 0 as fail
	if(dbq.NextRow())
		day_index = text2num(dbq.item[1]) + 1

	qdel(dbq)

	if(!day_index)
		log_startup_progress("Somehow, we failed to extract a valid numerical day from the DB. ?????????????")
		return

	// String interpolation is faster than num2text() for some reason
	var/dindex_str = "[day_index]"

	// Special is defined for this day
	if(dindex_str in GLOB.configuration.vote.map_vote_day_types)
		var/vote_type = GLOB.configuration.vote.map_vote_day_types[dindex_str]
		// We have an index, but is it valid
		if(vote_type in list(MAPROTATION_MODE_NORMAL_VOTE, MAPROTATION_MODE_NO_DUPLICATES, MAPROTATION_MODE_FULL_RANDOM, MAPROTATION_MODE_HYBRID_FPTP_NO_DUPLICATES))
			log_startup_progress("It is [days[day_index]], which means [rotation_descs[vote_type]]")
			rotation_mode = vote_type
			setup_done = TRUE
		// Its not valid
		else
			log_startup_progress("The defined rotation mode for this day is invalid. Please inform AA.")
	// No special defined for this day
	else
		log_startup_progress("There is no special rotation defined for this day")

/datum/controller/subsystem/maprotate/proc/decide_next_map()
	var/list/potential_maps = list()
	for(var/x in subtypesof(/datum/map))
		var/datum/map/M = x
		if(!initial(M.voteable))
			continue
		// Skip current map
		if(istype(SSmapping.map_datum, M))
			continue
		// Commenting out this check for now, as we only have 3 maps to choose from.
		// TODO: Uncomment when more maps are added back.
		// Skip last round map
//		if(istype(SSmapping.last_map, M))
//			continue
		potential_maps[M] = 0
	// We now have 3 maps. We then pick your highest priority map in the list. Does this mean votes 4 and 5 don't matter? Yeah, with this current system only your top 3 votes will ever be used. 4 and 5 are good info to know however!
	for(var/client/user_client in GLOB.clients)
		for(var/preferred_text as anything in user_client.prefs.map_vote_pref_json) // stored as a list of text
			var/datum/map/preferred_map = text2path(preferred_text)
			if(isnull(preferred_map)) // this map datum doesn't exist!!
				continue
			if(preferred_map in potential_maps)
				potential_maps[preferred_map]++
				break
	var/list/returned_text = list("Map Preference Vote Results:")
	var/list/pickable_maps = list()
	for(var/possible_next_map in potential_maps)
		var/votes = potential_maps[possible_next_map]
		var/percentage_text = ""
		if(votes > 0)
			var/actual_percentage = round((votes / length(GLOB.clients)) * 100, 0.1) // Note: Some players will not have this filled out. Too bad.
			percentage_text += "[add_lspace(actual_percentage, 5 - length("[actual_percentage]"))]%"
			pickable_maps[possible_next_map] = votes
		returned_text += "[percentage_text] | <b>[possible_next_map]</b>: [potential_maps[possible_next_map]]"
	if(!length(pickable_maps))
		pickable_maps = potential_maps // potential_maps should probably be renamed to `available_maps` or `voteable_maps`
	var/datum/map/winner = pickweight(pickable_maps) // Even if no one votes, pickweight will pick from them evenly. This means a map with zero votes *can* be chosen
	to_chat(world, "[returned_text.Join("\n")]")
	SSmapping.next_map = new winner
	to_chat(world, "<span class='interface'>Map for next round: [SSmapping.next_map.fluff_name] ([SSmapping.next_map.technical_name])</span>")
