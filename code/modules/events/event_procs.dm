
/client/proc/forceEvent(type in SSevents.allEvents)
	set name = "Trigger Event"
	set category = "Debug"

	if(!check_rights(R_EVENT))
		return

	if(ispath(type))
		new type(new /datum/event_meta(EVENT_LEVEL_MAJOR))
		message_admins("[key_name_admin(usr)] has triggered an event. ([type])", 1)

/client/proc/event_manager_panel()
	set name = "Event Manager Panel"
	set category = "Event"
	if(SSevents)
		SSevents.Interact(usr)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Event Manager") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

/proc/findEventArea() //Here's a nice proc to use to find an area for your event to land in!
	var/list/safe_areas = typecacheof(list(
	/area/turret_protected/ai,
	/area/turret_protected/ai_upload,
	/area/engine,
	/area/solar,
	/area/holodeck,
	/area/shuttle,
	/area/maintenance,
	/area/toxins/test_area,
	/area/crew_quarters/sleep))

	//These are needed because /area/engine has to be removed from the list, but we still want these areas to get fucked up.
	var/list/danger_areas = list(
	/area/engine/break_room,
	/area/engine/equipmentstorage,
	/area/engine/chiefs_office,
	/area/engine/controlroom)

	var/list/allowed_areas = list()

	allowed_areas = typecacheof(GLOB.the_station_areas) - safe_areas + danger_areas
	var/list/possible_areas = typecache_filter_list(SSmapping.existing_station_areas, allowed_areas)

	return pick(possible_areas)

/proc/findUnrestrictedEventArea() //Does almost the same as findEventArea() but hits a few more areas including maintenance and the AI sat, and also returns a list of all the areas, instead of just one area
	var/list/safe_areas = typecacheof(list(
	/area/solar,
	/area/toxins/test_area,
	/area/crew_quarters/sleep))

	var/list/allowed_areas = list()

	allowed_areas = typecacheof(GLOB.the_station_areas) - safe_areas
	var/list/possible_areas = typecache_filter_list(SSmapping.existing_station_areas, allowed_areas)

	return possible_areas

// Returns how many characters are currently active(not logged out, not AFK for more than 10 minutes)
// with a specific role.
// Note that this isn't sorted by department, because e.g. having a roboticist shouldn't make meteors spawn.
/proc/number_active_with_role()
	var/list/active_with_role = list()
	active_with_role["Engineer"] = 0
	active_with_role["Medical"] = 0
	active_with_role["Security"] = 0
	active_with_role["Scientist"] = 0
	active_with_role["AI"] = 0
	active_with_role["Cyborg"] = 0
	active_with_role["Janitor"] = 0
	active_with_role["Botanist"] = 0
	active_with_role["Any"] = GLOB.player_list.len

	for(var/mob/M in GLOB.player_list)
		if(!M.mind || !M.client || M.client.inactivity > 10 * 10 * 60) // longer than 10 minutes AFK counts them as inactive
			continue

		if(isrobot(M))
			var/mob/living/silicon/robot/R = M
			if(R.module && (R.module.name == "engineering robot module"))
				active_with_role["Engineer"]++

			if(R.module && (R.module.name == "medical robot module"))
				active_with_role["Medical"]++

			if(R.module && (R.module.name == "security robot module"))
				active_with_role["Security"]++

		if(M.mind.assigned_role in list("Chief Engineer", "Station Engineer"))
			active_with_role["Engineer"]++

		if(M.mind.assigned_role in list("Chief Medical Officer", "Medical Doctor"))
			active_with_role["Medical"]++

		if(M.mind.assigned_role in GLOB.active_security_positions)
			active_with_role["Security"]++

		if(M.mind.assigned_role in list("Research Director", "Scientist"))
			active_with_role["Scientist"]++

		if(M.mind.assigned_role == "AI")
			active_with_role["AI"]++

		if(M.mind.assigned_role == "Cyborg")
			active_with_role["Cyborg"]++

		if(M.mind.assigned_role == "Janitor")
			active_with_role["Janitor"]++

		if(M.mind.assigned_role == "Botanist")
			active_with_role["Botanist"]++

	return active_with_role

/datum/event/proc/num_players()
	var/players = 0
	for(var/mob/living/carbon/human/P in GLOB.player_list)
		if(P.client)
			players++
	return players
