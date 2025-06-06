GLOBAL_LIST_INIT(severity_to_string, list(EVENT_LEVEL_MUNDANE = "Mundane", EVENT_LEVEL_MODERATE = "Moderate", EVENT_LEVEL_MAJOR = "Major", EVENT_LEVEL_DISASTER = "disaster"))
GLOBAL_LIST_EMPTY(event_last_fired)

/datum/event_container
	var/severity = -1
	var/delayed = 0
	var/delay_modifier = 1
	var/next_event_time = 0
	var/list/available_events
	var/list/last_event_time = list()
	var/datum/event_meta/next_event = null

	var/last_world_time = 0

/datum/event_container/process()
	if(!next_event_time)
		set_event_delay()

	if(delayed)
		next_event_time += (world.time - last_world_time)
	else if(world.time > next_event_time)
		if(GLOB.configuration.event.enable_random_events)
			start_event()

	last_world_time = world.time

/datum/event_container/proc/start_event()
	if(!next_event)	// If non-one has explicitly set an event, randomly pick one
		next_event = acquire_event()

	// Has an event been acquired?
	if(next_event)
		// Set when the event of this type was last fired, and prepare the next event start
		last_event_time[next_event] = world.time
		set_event_delay()
		next_event.enabled = !next_event.one_shot	// This event will no longer be available in the random rotation if one shot

		new next_event.skeleton.type(next_event)	// Events are added and removed from the processing queue in their New/kill procs

		log_debug("Starting event '[next_event.skeleton.name]' of severity [GLOB.severity_to_string[severity]].")
		SSblackbox.record_feedback("nested tally", "events", 1, list(GLOB.severity_to_string[severity], next_event.skeleton.name))
		GLOB.event_last_fired[next_event] = world.time
		next_event = null						// When set to null, a random event will be selected next time
	else
		// If not, wait for one minute, instead of one tick, before checking again.
		next_event_time += (60 * 10)


/datum/event_container/proc/acquire_event()
	if(length(available_events) == 0)
		return
	// A list of the amount of active players in each role/department
	var/active_with_role = number_active_with_role()
	// A list of the net available resources of each department depending on staffing and active threats/events
	var/list/total_resources = list()

	// Add resources from staffing
	for(var/assignment in active_with_role)
		if(total_resources[assignment])
			total_resources[assignment] += ASSIGNMENT_STAFFING_VALUE
		else
			total_resources[assignment] = ASSIGNMENT_STAFFING_VALUE

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

	var/list/possible_events = list()
	for(var/datum/event_meta/EM in available_events)
		var/event_weight = EM.get_weight(total_resources)
		if(EM.enabled && event_weight)
			possible_events[EM] = event_weight

	for(var/event_meta in last_event_time) if(possible_events[event_meta])
		var/time_passed = world.time - GLOB.event_last_fired[event_meta]
		var/half_of_round = GLOB.configuration.event.expected_round_length / 2
		var/weight_modifier = min(1, 1 - ((half_of_round - time_passed) / half_of_round))
		//With this formula, an event ran 30 minutes ago has half weight, and an event ran an hour ago, has 100 % weight. This works better in general for events, as super high weight events are impacted in a meaningful way.
		var/new_weight = max(possible_events[event_meta] * weight_modifier, 0)
		if(new_weight)
			possible_events[event_meta] = new_weight
		else
			possible_events -= event_meta

	if(length(possible_events) == 0)
		return null

	// Select an event and remove it from the pool of available events
	var/picked_event = pickweight(possible_events)
	available_events -= picked_event
	return picked_event

/datum/event_container/proc/get_playercount_modifier()
	switch(length(GLOB.player_list))
		if(0 to 10)
			return 1.2
		if(11 to 15)
			return 1.1
		if(16 to 25)
			return 1
		if(26 to 35)
			return 0.9
		if(36 to 50)
			return 0.8
		if(50 to 80)
			return 0.7
		if(80 to 10000)
			return 0.6

/datum/event_container/proc/set_event_delay()
	// If the next event time has not yet been set and we have a custom first time start
	if(next_event_time == 0 && GLOB.configuration.event.first_run_times[severity])
		var/lower = GLOB.configuration.event.first_run_times[severity]["lower"]
		var/upper = GLOB.configuration.event.first_run_times[severity]["upper"]
		var/event_delay = rand(lower, upper)
		next_event_time = world.time + event_delay
	// Otherwise, follow the standard setup process
	else
		var/playercount_modifier = get_playercount_modifier()

		playercount_modifier = playercount_modifier * delay_modifier

		var/event_delay = rand(GLOB.configuration.event.delay_lower_bound[severity], GLOB.configuration.event.delay_upper_bound[severity]) * playercount_modifier
		next_event_time = world.time + event_delay

	log_debug("Next event of severity [GLOB.severity_to_string[severity]] in [(next_event_time - world.time)/600] minutes.")

/datum/event_container/proc/SelectEvent()
	var/datum/event_meta/EM = input("Select an event to queue up.", "Event Selection", null) as null|anything in available_events
	if(!EM)
		return
	if(next_event)
		available_events += next_event
	available_events -= EM
	next_event = EM
	return EM

/datum/event_container/mundane
	severity = EVENT_LEVEL_MUNDANE
	available_events = list(
		// Severity level, event name, event type, base weight, role weights, one shot, min weight, max weight. Last two only used if set.
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, /datum/event/nothing, 1100),
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, /datum/event/pda_spam, 0, FALSE, 25, 50),
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, /datum/event/economic_event,	300),
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, /datum/event/trivial_news, 		400),
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, /datum/event/mundane_news, 300),
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, /datum/event/infestation, 100),
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, /datum/event/sentience, 50),
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, /datum/event/wallrot, 0),
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, /datum/event/wallrot/fungus, 50),
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, /datum/event/carp_migration/koi,		80),
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, /datum/event/camera_failure, 100),
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, /datum/event/fake_virus,		50),
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, /datum/event/bureaucratic_error,	40, TRUE),
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, /datum/event/disease_outbreak, 50, TRUE)
	)

/datum/event_container/moderate
	severity = EVENT_LEVEL_MODERATE
	available_events = list(
		new /datum/event_meta(EVENT_LEVEL_MODERATE, /datum/event/nothing, 1230),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, /datum/event/falsealarm, 200),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, /datum/event/spontaneous_appendicitis, 	0, TRUE),
		new /datum/event_meta(EVENT_LEVEL_MODERATE,	/datum/event/carp_migration, 200, , TRUE),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, /datum/event/rogue_drone, 0),
		new /datum/event_meta(EVENT_LEVEL_MODERATE,	/datum/event/spacevine, 250),
		new /datum/event_meta(EVENT_LEVEL_MODERATE,	/datum/event/meteor_wave, 0),
		new /datum/event_meta(EVENT_LEVEL_MODERATE,	/datum/event/solar_flare, 0),
		new /datum/event_meta(EVENT_LEVEL_MODERATE,	/datum/event/dust/meaty, 0),
		new /datum/event_meta(EVENT_LEVEL_MODERATE,	/datum/event/communications_blackout, 500),
		new /datum/event_meta(EVENT_LEVEL_MODERATE,	/datum/event/prison_break, 0),
		//new /datum/event_meta(EVENT_LEVEL_MODERATE, "Virology Breach",			/datum/event/prison_break/virology,		0,		list(ASSIGNMENT_MEDICAL = 100)),
		//new /datum/event_meta(EVENT_LEVEL_MODERATE, "Xenobiology Breach",		/datum/event/prison_break/xenobiology,	0,		list(ASSIGNMENT_SCIENCE = 100)),
		new /datum/event_meta(EVENT_LEVEL_MODERATE,	/datum/event/apc_short, 200),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, /datum/event/electrical_storm, 250),
		new /datum/event_meta(EVENT_LEVEL_MODERATE,	/datum/event/radiation_storm, 25, TRUE),
		new /datum/event_meta(EVENT_LEVEL_MODERATE,	/datum/event/spider_infestation, 100, TRUE),
		new /datum/event_meta(EVENT_LEVEL_MODERATE,	/datum/event/ion_storm, 0),
		//new /datum/event_meta/ninja(EVENT_LEVEL_MODERATE, "Space Ninja",		/datum/event/space_ninja, 				0,		list(ASSIGNMENT_SECURITY = 15), TRUE),
		// NON-BAY EVENTS
		new /datum/event_meta(EVENT_LEVEL_MODERATE,	/datum/event/mass_hallucination,		300),
		new /datum/event_meta(EVENT_LEVEL_MODERATE,	/datum/event/brand_intelligence, 50, TRUE),
		new /datum/event_meta(EVENT_LEVEL_MODERATE,	/datum/event/tear, 0),
		new /datum/event_meta(EVENT_LEVEL_MODERATE,	/datum/event/tear/honk,	0),
		new /datum/event_meta(EVENT_LEVEL_MODERATE,	/datum/event/vent_clog,	250),
		new /datum/event_meta(EVENT_LEVEL_MODERATE,	/datum/event/wormholes,	150),
		new /datum/event_meta(EVENT_LEVEL_MODERATE,	/datum/event/anomaly/anomaly_pyro, 75),
		new /datum/event_meta(EVENT_LEVEL_MODERATE,	/datum/event/anomaly/anomaly_cryo, 75),
		new /datum/event_meta(EVENT_LEVEL_MODERATE,	/datum/event/anomaly/anomaly_vortex, 75),
		new /datum/event_meta(EVENT_LEVEL_MODERATE,	/datum/event/anomaly/anomaly_bluespace,	75),
		new /datum/event_meta(EVENT_LEVEL_MODERATE,	/datum/event/anomaly/anomaly_flux, 75),
		new /datum/event_meta(EVENT_LEVEL_MODERATE,	/datum/event/anomaly/anomaly_grav, 200),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, /datum/event/revenant, 150),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, /datum/event/spawn_morph, 40, is_one_shot = TRUE),
		new /datum/event_meta(EVENT_LEVEL_MODERATE,	/datum/event/disease_outbreak, 50, TRUE),
		new /datum/event_meta(EVENT_LEVEL_MODERATE,	/datum/event/door_runtime, 50, TRUE),
		new /datum/event_meta(EVENT_LEVEL_MODERATE,	/datum/event/tourist_arrivals, 100, TRUE)
	)

/datum/event_container/major
	severity = EVENT_LEVEL_MAJOR
	available_events = list(
		new /datum/event_meta(EVENT_LEVEL_MAJOR, /datum/event/nothing, 590),
		new /datum/event_meta(EVENT_LEVEL_MAJOR, /datum/event/carp_migration, 10, TRUE),
		//new /datum/event_meta(EVENT_LEVEL_MAJOR, "Containment Breach",	/datum/event/prison_break/station,	0,			list(ASSIGNMENT_ANY = 5)),
		new /datum/event_meta(EVENT_LEVEL_MAJOR, /datum/event/apc_overload,	0),
		new /datum/event_meta(EVENT_LEVEL_MAJOR, /datum/event/meteor_wave, 0, TRUE),
		new /datum/event_meta(EVENT_LEVEL_MAJOR, /datum/event/abductor, 20, TRUE),
		new /datum/event_meta(EVENT_LEVEL_MAJOR, /datum/event/traders, 85, 	is_one_shot = TRUE),
		new /datum/event_meta(EVENT_LEVEL_MAJOR, /datum/event/spawn_slaughter, 20, is_one_shot = TRUE),
		new /datum/event_meta(EVENT_LEVEL_MAJOR, /datum/event/spawn_slaughter/shadow, 20, is_one_shot = TRUE),
		new /datum/event_meta(EVENT_LEVEL_MAJOR, /datum/event/immovable_rod, 0, TRUE)
		//new /datum/event_meta(EVENT_LEVEL_MAJOR, "Floor Cluwne",	/datum/event/spawn_floor_cluwne,	15, is_one_shot = TRUE)
		//new /datum/event_meta(EVENT_LEVEL_MAJOR, "Pulse Demon Infiltration",	/datum/event/spawn_pulsedemon,	20,	is_one_shot = TRUE)
	)

/datum/event_container/disaster
	severity = EVENT_LEVEL_DISASTER
	available_events = list(
		new /datum/event_meta(EVENT_LEVEL_DISASTER, /datum/event/nothing, 590),
		new /datum/event_meta(EVENT_LEVEL_DISASTER, /datum/event/blob, 20, TRUE),
		new /datum/event_meta(EVENT_LEVEL_DISASTER, /datum/event/alien_infestation, 15, TRUE),
		new /datum/event_meta(EVENT_LEVEL_DISASTER, /datum/event/spider_terror, 15, TRUE)
		)
	var/activation_counter = 0

/datum/event_container/disaster/get_playercount_modifier()
	return 1

/datum/event_container/disaster/acquire_event()
	if(activation_counter > 1) // Disaster level events should normally roll up to 2 times per round. Doing it this way makes adminbus easier.
		return new /datum/event_meta(EVENT_LEVEL_DISASTER, /datum/event/nothing, 590)
	. = ..()

/datum/event_container/disaster/start_event()
	activation_counter++
	. = ..()
