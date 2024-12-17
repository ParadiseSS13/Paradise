/datum/preferences
	var/species_whitelist

/datum/preferences/proc/get_species_whitelist()
	. = TRUE

	if(species_whitelist)
		return

	var/datum/db_query/preferences_query = SSdbcore.NewQuery("SELECT species_whitelist FROM player WHERE ckey=:ckey", list(
			"ckey" = parent.ckey
		))

	if(!preferences_query.warn_execute())
		qdel(preferences_query)
		return FALSE

	while(preferences_query.NextRow())
		var/species_whitelist_json = preferences_query.item[1]
		if(species_whitelist_json)
			species_whitelist = json_decode(preferences_query.item[1])

	qdel(preferences_query)

/datum/preferences/load_preferences(datum/db_query/query)
	. = ..()
	if(!.)
		return

	return get_species_whitelist()
