/datum/preferences
	var/toggles220 = TOGGLES_220_DEFAULT

/datum/preferences/load_preferences(datum/db_query/query)
	. = ..()
	if(!.)
		return

	return load_custom_preferences()

/datum/preferences/save_preferences(client/C)
	. = ..()
	if(!.)
		return

	return save_custom_preferences(C)

/datum/preference_toggle/set_toggles(client/user)
	var/datum/preferences/our_prefs = user.prefs
	switch(preftoggle_toggle)
		if(PREFTOGGLE_TOGGLE220)
			our_prefs.toggles220 ^= preftoggle_bitflag
			to_chat(user, "<span class='notice'>[(our_prefs.toggles220 & preftoggle_bitflag) ? enable_message : disable_message]</span>")
	. = ..()

/datum/preferences/proc/load_custom_preferences()
	var/datum/db_query/preferences_query = SSdbcore.NewQuery({"SELECT
		toggles
		FROM player_220
		WHERE ckey=:ckey"}, list(
			"ckey" = parent.ckey
		))

	if(!preferences_query.warn_execute())
		qdel(preferences_query)
		return FALSE

	while(preferences_query.NextRow())
		toggles220 = preferences_query.item[1]

	toggles220 = sanitize_integer(toggles220, 0, TOGGLES_220_TOTAL, initial(toggles220))

	qdel(preferences_query)
	return TRUE

/datum/preferences/proc/save_custom_preferences(client/C)
	var/datum/db_query/query = SSdbcore.NewQuery({"UPDATE player_220 SET
		toggles=:toggles
		WHERE ckey=:ckey"}, list(
			"toggles" = num2text(toggles220, CEILING(log(10, (TOGGLES_220_TOTAL)), 1)),
			"ckey" = C.ckey,
		))

	if(!query.warn_execute())
		qdel(query)
		return FALSE

	qdel(query)
	return TRUE
