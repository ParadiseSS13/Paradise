
/client/proc/forceEvent(type in SSevents.allEvents)
	set name = "Trigger Event"
	set category = "Event"

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
		/area/station/turret_protected/ai,
		/area/station/turret_protected/ai_upload,
		/area/station/engineering,
		/area/holodeck,
		/area/shuttle,
		/area/station/maintenance,
		/area/station/science/toxins/test,
		/area/space,
		/area/station/public/sleep))

	//These are needed because /area/station/engineering has to be removed from the list, but we still want these areas to get fucked up.
	var/list/allowed_areas = list(
		/area/station/engineering/break_room,
		/area/station/engineering/equipmentstorage,
		/area/station/engineering/controlroom)

	var/list/remove_these_areas = safe_areas - allowed_areas
	var/list/possible_areas = typecache_filter_list_reverse(SSmapping.existing_station_areas, remove_these_areas)

	if(!length(possible_areas))
		return null
	return pick(possible_areas)

/proc/findUnrestrictedEventArea() //Does almost the same as findEventArea() but hits a few more areas including maintenance and the AI sat, and also returns a list of all the areas, instead of just one area
	var/list/safe_areas = typecacheof(list(
	/area/station/engineering/solar,
	/area/station/science/toxins/test,
	/area/station/public/sleep))

	var/list/possible_areas = typecache_filter_list_reverse(SSmapping.existing_station_areas, safe_areas)

	return possible_areas

// Returns how many characters are currently active(not logged out, not AFK for more than 10 minutes)
// with a specific role.
// Note that this isn't sorted just by department, because e.g. having a roboticist shouldn't make meteors spawn.
/proc/number_active_with_role()
	var/list/active_with_role = list()
	active_with_role[ASSIGNMENT_TOTAL] = 0
	active_with_role[ASSIGNMENT_COMMAND] = 0
	active_with_role[ASSIGNMENT_ENGINEERING] = 0
	active_with_role[ASSIGNMENT_MEDICAL] = 0
	active_with_role[ASSIGNMENT_SECURITY] = 0
	active_with_role[ASSIGNMENT_SCIENCE] = 0

	for(var/mob/M in GLOB.player_list)
		if(!M.mind || !M.client || M.client.inactivity > 10 * 10 * 60) // longer than 10 minutes AFK counts them as inactive
			continue

		if(M.mind.assigned_role in (GLOB.exp_jobsmap[EXP_TYPE_CREW]["titles"]))
			active_with_role[ASSIGNMENT_TOTAL]++

		if(active_with_role[M.mind.assigned_role])
			active_with_role[M.mind.assigned_role]++
		else
			active_with_role[M.mind.assigned_role] = 1

		if(isrobot(M))
			var/mob/living/silicon/robot/R = M
			if(R.module && (R.module.name == "engineering robot module"))
				active_with_role[ASSIGNMENT_ENGINEERING]++

			if(R.module && (R.module.name == "medical robot module"))
				active_with_role[ASSIGNMENT_MEDICAL]++

			if(R.module && (R.module.name == "security robot module"))
				active_with_role[ASSIGNMENT_SECURITY]++

		if(M.mind.assigned_role in GLOB.engineering_positions)
			active_with_role[ASSIGNMENT_ENGINEERING]++

		if(M.mind.assigned_role in GLOB.medical_positions)
			active_with_role[ASSIGNMENT_MEDICAL]++

		if(M.mind.assigned_role in GLOB.active_security_positions)
			active_with_role[ASSIGNMENT_SECURITY]++

		if(M.mind.assigned_role in GLOB.science_positions)
			active_with_role[ASSIGNMENT_SCIENCE]++

		if(M.mind.assigned_role in GLOB.command_positions)
			active_with_role[ASSIGNMENT_COMMAND]++

	return active_with_role

/datum/event/proc/num_players()
	var/players = 0
	for(var/mob/living/carbon/human/P in GLOB.player_list)
		if(P.client)
			players++
	return players
