
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

/proc/findMaintananceEventArea() // For maintanance events ONLY
	var/list/maintanance_area = typecacheof(list(/area/station/maintenance))

	var/list/possible_areas = typecache_filter_list(SSmapping.existing_station_areas, maintanance_area)

	return pick(possible_areas)

// Returns how many characters are currently active(not logged out, not AFK for more than 10 minutes)
// with a specific role.
// Note that this isn't sorted just by department, because e.g. having a roboticist shouldn't make meteors spawn.
/proc/number_active_with_role()

	var/list/active_with_role = list()
	active_with_role[ASSIGNMENT_CREW] = 0
	active_with_role[ASSIGNMENT_COMMAND] = 0
	active_with_role[ASSIGNMENT_ENGINEERING] = 0
	active_with_role[ASSIGNMENT_MEDICAL] = 0
	active_with_role[ASSIGNMENT_SECURITY] = 0
	active_with_role[ASSIGNMENT_SCIENCE] = 0
	active_with_role[ASSIGNMENT_CARGO] = 0

	if(length(SSevents.debug_resources))
		active_with_role = SSevents.debug_resources.Copy()

	for(var/mob/player in GLOB.player_list)
		if(!player.mind?.assigned_role || player.stat == DEAD || !player.client || player.client.inactivity > 10 * 10 * 60) // longer than 10 minutes AFK counts them as inactive
			continue

		var/capacity = player.get_event_capacity()

		if(!capacity)
			continue

		if(player.mind.assigned_role in (GLOB.exp_jobsmap[EXP_TYPE_CREW]["titles"]))
			active_with_role[ASSIGNMENT_CREW] += capacity

		if(active_with_role[player.mind.assigned_role])
			active_with_role[player.mind.assigned_role]+= capacity
		else
			active_with_role[player.mind.assigned_role] = capacity

		if(isrobot(player))
			var/mob/living/silicon/robot/R = player
			if(R.module && (R.module.name == "engineering robot module"))
				active_with_role[ASSIGNMENT_ENGINEERING]+= capacity

			if(R.module && (R.module.name == "medical robot module"))
				active_with_role[ASSIGNMENT_MEDICAL]+= capacity

			if(R.module && (R.module.name == "security robot module"))
				active_with_role[ASSIGNMENT_SECURITY]+= capacity

		if(player.mind.assigned_role in GLOB.engineering_positions)
			active_with_role[ASSIGNMENT_ENGINEERING]+= capacity

		if(player.mind.assigned_role in GLOB.medical_positions)
			active_with_role[ASSIGNMENT_MEDICAL]+= capacity

		if(player.mind.assigned_role in GLOB.active_security_positions)
			active_with_role[ASSIGNMENT_SECURITY]+= capacity

		if(player.mind.assigned_role in GLOB.science_positions)
			active_with_role[ASSIGNMENT_SCIENCE]+= capacity

		if(player.mind.assigned_role in GLOB.supply_positions)
			active_with_role[ASSIGNMENT_CARGO]+= capacity

		if(player.mind.assigned_role in GLOB.command_positions)
			active_with_role[ASSIGNMENT_COMMAND]+= capacity

	return active_with_role

/datum/event/proc/num_players()
	var/players = 0
	for(var/mob/living/carbon/human/P in GLOB.player_list)
		if(P.client)
			players++
	return players

/proc/event_category_cost(category)
	. = list()
	if(!category)
		return
	for(var/datum/component/event_tracker/tracker in GLOB.event_trackers["[category]"])
		var/costs = tracker.event_cost()
		for(var/key in costs)
			.["[key]"] += costs[key]

/proc/event_total_cost()
	. = list()
	for(var/category in GLOB.event_trackers)
		var/costs = event_category_cost(category)
		for(var/key in costs)
			.["[key]"] += costs[key]

/// Returns the net resources available for event rolling
/proc/get_total_resources()
	// A list of the amount of active players in each role/department
	var/active_with_role = number_active_with_role()
	// A list of the net available resources of each department depending on staffing and active threats/events
	var/list/total_resources = list()

	// Add resources from staffing
	for(var/assignment in active_with_role)
		total_resources[assignment] += active_with_role[assignment] * ASSIGNMENT_STAFFING_VALUE

	// Subtract resources from active antags
	for(var/datum/antagonist/active in GLOB.antagonists)
		var/list/antag_costs = active.antag_event_resource_cost()
		for(var/assignment in antag_costs)
			if(total_resources[assignment])
				total_resources[assignment] -= antag_costs[assignment]
			else
				total_resources[assignment] = -antag_costs[assignment]

	// Subtract resources from active events
	for(var/datum/event/active in SSevents.active_events)
		var/list/event_costs = active.event_resource_cost()
		for(var/assignment in event_costs)
			if(total_resources[assignment])
				total_resources[assignment] -= event_costs[assignment]
			else
				total_resources[assignment] = -event_costs[assignment]

	// Subtract resources from various elements
	var/list/misc_costs = event_total_cost()
	for(var/assignment in misc_costs)
		if(total_resources[assignment])
			total_resources[assignment] -= misc_costs[assignment]
		else
			total_resources[assignment] = -misc_costs[assignment]

	return total_resources
