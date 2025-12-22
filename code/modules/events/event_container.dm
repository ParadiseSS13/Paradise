GLOBAL_LIST_INIT(severity_to_string, alist(EVENT_LEVEL_MUNDANE = "Mundane", EVENT_LEVEL_MODERATE = "Moderate", EVENT_LEVEL_MAJOR = "Major", EVENT_LEVEL_DISASTER = "Disaster"))
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
	/// Records the initial amount of events in the available event list
	var/initial_event_count = 0

/datum/event_container/New()
	. = ..()
	initial_event_count = length(available_events)

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

		new next_event.skeleton.type(next_event, _severity = next_event.skeleton.severity)	// Events are added and removed from the processing queue in their New/kill procs

		log_debug("Starting event '[next_event.skeleton.name]' of severity [GLOB.severity_to_string[severity]].")
		SSblackbox.record_feedback("nested tally", "events", 1, list(GLOB.severity_to_string[severity], next_event.skeleton.name))
		GLOB.event_last_fired[next_event] = world.time
		var/datum/event_meta/meta = next_event
		next_event = null // When set to null, a random event will be selected next time
		// Used for checks about the event we just ran
		return meta
	else
		// If not, wait for one minute, instead of one tick, before checking again.
		next_event_time += (60 * 10)



/datum/event_container/proc/acquire_event()
	if(length(available_events) == 0)
		return
	// A list of the net available resources of each department depending on staffing and active threats/events
	var/list/total_resources = get_total_resources()

	var/list/possible_events = list()
	for(var/datum/event_meta/EM in available_events)
		var/event_weight = EM.get_weight(total_resources)
		// We use the amount of non disabled events to adjust the value of Nothing, so we count 0 weight events
		if(EM.enabled && EM.first_run_time < world.time - SSticker.time_game_started)
			possible_events[EM] = max(event_weight, 0)
			// For events like nothing we want to have their weight adjusted depending on how many events are left of the original list
			if(EM.skeleton.is_relative())
				possible_events[EM] *= (length(available_events) / initial_event_count)

	for(var/datum/event_meta/event_meta in last_event_time)
		if(!event_meta.skeleton)
			continue
		if(event_meta.skeleton.has_cooldown() && possible_events[event_meta])
			var/time_passed = world.time - GLOB.event_last_fired[event_meta]
			var/cooldown = GLOB.configuration.event.expected_round_length / 2
			var/weight_modifier = 1 - max(0, 0.5 * ((cooldown - time_passed) / cooldown))
			// Events that just ran have their base weight reduced by half, tapering to no reduction over half an hour
			var/new_weight = max(possible_events[event_meta] * weight_modifier, 0)
			if(new_weight)
				possible_events[event_meta] = new_weight

	if(length(possible_events) == 0)
		return null

	// Select an event and remove it from the pool of available events
	var/picked_event = pickweight(possible_events)
	available_events -= picked_event
	return picked_event

/datum/event_container/proc/get_playercount_modifier()
	switch(length(GLOB.player_list))
		if(0 to 10)
			return 1.1
		if(11 to 15)
			return 1.05
		if(16 to 25)
			return 1
		if(26 to 35)
			return 0.95
		if(36 to 50)
			return 0.9
		if(50 to 80)
			return 0.85
		if(80 to 10000)
			return 0.8

/datum/event_container/proc/set_event_delay()
	// If the next event time has not yet been set and we have a custom first time start
	if(next_event_time == 0 && GLOB.configuration.event.first_run_times[severity])
		var/lower = GLOB.configuration.event.first_run_times[severity]["lower"]
		var/upper = GLOB.configuration.event.first_run_times[severity]["upper"]
		var/event_delay = rand(lower, upper)
		next_event_time = world.time + event_delay
	// Otherwise, follow the standard setup process
	else
		var/event_delay = calculate_event_delay()
		next_event_time = world.time + event_delay

	log_debug("Next event of severity [GLOB.severity_to_string[severity]] in [(next_event_time - world.time)/600] minutes.")

/datum/event_container/proc/calculate_event_delay()
	return rand(GLOB.configuration.event.delay_lower_bound[severity], GLOB.configuration.event.delay_upper_bound[severity]) * delay_modifier * get_playercount_modifier()

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
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, /datum/event/nothing, 252),
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, /datum/event/pda_spam, 9),
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, /datum/event/economic_event,	7),
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, /datum/event/trivial_news, 7),
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, /datum/event/mundane_news, 7),
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, /datum/event/infestation, 11),
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, /datum/event/sentience, 15),
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, /datum/event/wallrot, 10),
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, /datum/event/wallrot/fungus, 10),
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, /datum/event/carp_migration/koi,	12),
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, /datum/event/camera_failure, 12),
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, /datum/event/fake_virus,		12),
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, /datum/event/bureaucratic_error,	12, TRUE),
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, /datum/event/disease_outbreak, 12, TRUE)
	)

/datum/event_container/moderate
	severity = EVENT_LEVEL_MODERATE
	available_events = list(
		new /datum/event_meta(EVENT_LEVEL_MODERATE, /datum/event/nothing, 800),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, /datum/event/falsealarm, 20),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, /datum/event/spontaneous_appendicitis, 5, TRUE),
		new /datum/event_meta(EVENT_LEVEL_MODERATE,	/datum/event/carp_migration, 10, , TRUE),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, /datum/event/rogue_drone, 7),
		new /datum/event_meta(EVENT_LEVEL_MODERATE,	/datum/event/spacevine, 15),
		new /datum/event_meta(EVENT_LEVEL_MODERATE,	/datum/event/meteor_wave, 8, _first_run_time = 40 MINUTES),
		new /datum/event_meta(EVENT_LEVEL_MODERATE,	/datum/event/solar_flare, 12),
		new /datum/event_meta(EVENT_LEVEL_MODERATE,	/datum/event/dust/meaty, 8, _first_run_time = 40 MINUTES),
		new /datum/event_meta(EVENT_LEVEL_MODERATE,	/datum/event/communications_blackout, 10),
		new /datum/event_meta(EVENT_LEVEL_MODERATE,	/datum/event/prison_break, 7),
		//new /datum/event_meta(EVENT_LEVEL_MODERATE, "Virology Breach",			/datum/event/prison_break/virology,		0,		list(ASSIGNMENT_MEDICAL = 100)),
		//new /datum/event_meta(EVENT_LEVEL_MODERATE, "Xenobiology Breach",		/datum/event/prison_break/xenobiology,	0,		list(ASSIGNMENT_SCIENCE = 100)),
		new /datum/event_meta(EVENT_LEVEL_MODERATE,	/datum/event/apc_short, 12),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, /datum/event/electrical_storm, 12),
		new /datum/event_meta(EVENT_LEVEL_MODERATE,	/datum/event/radiation_storm, 10, TRUE),
		new /datum/event_meta(EVENT_LEVEL_MODERATE,	/datum/event/spider_infestation, 10, TRUE),
		new /datum/event_meta(EVENT_LEVEL_MODERATE,	/datum/event/ion_storm, 10),
		//new /datum/event_meta/ninja(EVENT_LEVEL_MODERATE, "Space Ninja",		/datum/event/space_ninja, 				0,		list(ASSIGNMENT_SECURITY = 15), TRUE),
		// NON-BAY EVENTS
		new /datum/event_meta(EVENT_LEVEL_MODERATE,	/datum/event/mass_hallucination,		10),
		new /datum/event_meta(EVENT_LEVEL_MODERATE,	/datum/event/brand_intelligence, 5, TRUE),
		new /datum/event_meta(EVENT_LEVEL_MODERATE,	/datum/event/tear, 15),
		new /datum/event_meta(EVENT_LEVEL_MODERATE,	/datum/event/tear/honk,	10),
		new /datum/event_meta(EVENT_LEVEL_MODERATE,	/datum/event/vent_clog,	12),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, /datum/event/disposals_clog, 12),
		new /datum/event_meta(EVENT_LEVEL_MODERATE,	/datum/event/wormholes,	15),
		new /datum/event_meta(EVENT_LEVEL_MODERATE,	/datum/event/anomaly/anomaly_pyro, 7),
		new /datum/event_meta(EVENT_LEVEL_MODERATE,	/datum/event/anomaly/anomaly_cryo, 7),
		new /datum/event_meta(EVENT_LEVEL_MODERATE,	/datum/event/anomaly/anomaly_vortex, 7),
		new /datum/event_meta(EVENT_LEVEL_MODERATE,	/datum/event/anomaly/anomaly_bluespace,	7),
		new /datum/event_meta(EVENT_LEVEL_MODERATE,	/datum/event/anomaly/anomaly_flux, 7),
		new /datum/event_meta(EVENT_LEVEL_MODERATE,	/datum/event/anomaly/anomaly_grav, 7),
		new /datum/event_meta(EVENT_LEVEL_MODERATE,	/datum/event/disease_outbreak, 15, TRUE),
		new /datum/event_meta(EVENT_LEVEL_MODERATE,	/datum/event/door_runtime, 10, TRUE),
		new /datum/event_meta(EVENT_LEVEL_MODERATE,	/datum/event/tourist_arrivals, 40, TRUE, _first_run_time = 35 MINUTES),
		new /datum/event_meta(EVENT_LEVEL_MODERATE,	/datum/event/shuttle_loan, 50, is_one_shot = TRUE),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, /datum/event/anomalous_particulate_event, 60, is_one_shot = TRUE),
	)

/datum/event_container/major
	severity = EVENT_LEVEL_MAJOR
	available_events = list(
		new /datum/event_meta(EVENT_LEVEL_MAJOR, /datum/event/nothing, 275),
		new /datum/event_meta(EVENT_LEVEL_MAJOR, /datum/event/carp_migration, 13, TRUE),
		//new /datum/event_meta(EVENT_LEVEL_MAJOR,	/datum/event/prison_break/station,	10),
		//new /datum/event_meta(EVENT_LEVEL_MAJOR, /datum/event/apc_overload,	11),
		new /datum/event_meta(EVENT_LEVEL_MAJOR, /datum/event/meteor_wave, 9, TRUE, _first_run_time = 40 MINUTES),
		new /datum/event_meta(EVENT_LEVEL_MAJOR, /datum/event/abductor, 12, TRUE),
		new /datum/event_meta(EVENT_LEVEL_MAJOR, /datum/event/traders, 13, is_one_shot = TRUE, _first_run_time = 35 MINUTES),
		new /datum/event_meta(EVENT_LEVEL_MAJOR, /datum/event/spawn_slaughter, 8, is_one_shot = TRUE),
		new /datum/event_meta(EVENT_LEVEL_MAJOR, /datum/event/spawn_slaughter/shadow, 8, is_one_shot = TRUE),
		new /datum/event_meta(EVENT_LEVEL_MAJOR, /datum/event/immovable_rod, 9, TRUE, _first_run_time = 40 MINUTES),
		new /datum/event_meta(EVENT_LEVEL_MAJOR, /datum/event/demon_incursion, 10, TRUE, _first_run_time = 35 MINUTES),
		new /datum/event_meta(EVENT_LEVEL_MAJOR, /datum/event/disease_outbreak, 8, TRUE),
		new /datum/event_meta(EVENT_LEVEL_MAJOR, /datum/event/revenant, 9),
		new /datum/event_meta(EVENT_LEVEL_MAJOR, /datum/event/swarmers, 9),
		new /datum/event_meta(EVENT_LEVEL_MAJOR, /datum/event/spawn_morph, 16, is_one_shot = TRUE),
		//new /datum/event_meta(EVENT_LEVEL_MAJOR,	/datum/event/spawn_floor_cluwne,	15, is_one_shot = TRUE)
		//new /datum/event_meta(EVENT_LEVEL_MAJOR,	/datum/event/spawn_pulsedemon,	20,	is_one_shot = TRUE)
	)

// The weights here are set up to roll an event about 1 in 3 rounds, assuming you roll as much as possible
/datum/event_container/disaster
	severity = EVENT_LEVEL_DISASTER
	available_events = list(
		new /datum/event_meta(EVENT_LEVEL_DISASTER, /datum/event/nothing, 5730),
		new /datum/event_meta(EVENT_LEVEL_DISASTER, /datum/event/blob, 100, TRUE),
		new /datum/event_meta(EVENT_LEVEL_DISASTER, /datum/event/alien_infestation, 100, TRUE),
		new /datum/event_meta(EVENT_LEVEL_DISASTER, /datum/event/spider_terror, 100, TRUE)
		)
	var/activation_counter = 0
	var/event_rolls = 0

/datum/event_container/disaster/get_playercount_modifier()
	return 1

/datum/event_container/disaster/acquire_event()
	// We should only be getting one none nothing disaster roll per round, and doing it this way leaves more room for admins to play around with it.
	if(activation_counter > 0)
		for(var/datum/event_meta/meta in available_events)
			if(istype(meta.skeleton, /datum/event/nothing))
				return meta
	event_rolls++
	. = ..()

/datum/event_container/disaster/start_event()
	. = ..()
	var/datum/event_meta/meta = .
	if(!istype(meta.skeleton, /datum/event/nothing))
		activation_counter++

/datum/event_container/disaster/calculate_event_delay()
	. = ..()
	if(world.time - SSticker.time_game_started + . <= 120 MINUTES && world.time - SSticker.time_game_started + . >= 95 MINUTES)
		. += 30 MINUTES
	return
