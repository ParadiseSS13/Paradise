var/list/allEvents = typesof(/datum/event) - /datum/event
var/list/potentialRandomEvents = typesof(/datum/event) - /datum/event
//var/list/potentialRandomEvents = typesof(/datum/event) - /datum/event - /datum/event/spider_infestation - /datum/event/alien_infestation

var/eventTimeLower = 9000	//15 minutes
var/eventTimeUpper = 15000	//25 minutes
var/scheduledEvent = null


//Currently unused. Needs an admin panel for messing with events.
/*/proc/addPotentialEvent(var/type)
	potentialRandomEvents |= type

/proc/removePotentialEvent(var/type)
	potentialRandomEvents -= type*/


/proc/checkEvent()
	if(!scheduledEvent)
		//more players = more time between events, less players = less time between events
		var/playercount_modifier = 1
		switch(player_list.len)
			if(0 to 10)
				playercount_modifier = 1.2
			if(11 to 15)
				playercount_modifier = 1.1
			if(16 to 25)
				playercount_modifier = 1
			if(26 to 35)
				playercount_modifier = 0.9
			if(36 to 100000)
				playercount_modifier = 0.8
		var/next_event_delay = rand(eventTimeLower, eventTimeUpper) * playercount_modifier
		scheduledEvent = world.timeofday + next_event_delay
		log_debug("Next event in [next_event_delay/600] minutes.")

	else if(world.timeofday > scheduledEvent)
		spawn_dynamic_event()

		scheduledEvent = null
		checkEvent()

//unused, see proc/dynamic_event()
/*
/proc/spawnEvent()
	if(!config.allow_random_events)
		return

	var/Type = pick(potentialRandomEvents)
	if(!Type)
		return

	//The event will add itself to the MC's event list
	//and start working via the constructor.
	new Type
*/

/client/proc/forceEvent(var/type in allEvents)
	set name = "Trigger Event (Debug Only)"
	set category = "Debug"

	if(!holder)
		return

	if(ispath(type))
		new type
		message_admins("[key_name_admin(usr)] has triggered an event. ([type])", 1)



/datum/event/proc/findEventArea() //Here's a nice proc to use to find an area for your event to land in!
	var/area/candidate = null

	var/list/safe_areas = list(
	/area/turret_protected/ai,
	/area/turret_protected/ai_upload,
	/area/engine,
	/area/solar,
	/area/holodeck,
	/area/shuttle/arrival,
	/area/shuttle/escape/station,
	/area/shuttle/escape_pod1/station,
	/area/shuttle/escape_pod2/station,
	/area/shuttle/escape_pod3/station,
	/area/shuttle/escape_pod5/station,
	/area/shuttle/mining/station,
	/area/shuttle/transport1/station,
	/area/shuttle/specops/station,
	/area/shuttle/prison/station,
	/area/shuttle/administration/station
	)

	//These are needed because /area/engine has to be removed from the list, but we still want these areas to get fucked up.
	var/list/danger_areas = list(
	/area/engine/break_room,
	/area/engine/chiefs_office)

	var/list/event_areas = list()

	for (var/areapath in the_station_areas)
		event_areas += typesof(areapath)
	for (var/areapath in safe_areas)
		event_areas -= typesof(areapath)
	for (var/areapath in danger_areas)
		event_areas += typesof(areapath)

	while (event_areas.len > 0)
		var/list/event_turfs = null
		candidate = locate(pick_n_take(event_areas))
		event_turfs = get_area_turfs(candidate)
		if (event_turfs.len > 0)
			break

	return candidate

