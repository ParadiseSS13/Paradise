#define ASSIGNMENT_ANY "Any"
#define ASSIGNMENT_AI "AI"
#define ASSIGNMENT_CYBORG "Cyborg"
#define ASSIGNMENT_ENGINEER "Engineer"
#define ASSIGNMENT_BOTANIST "Botanist"
#define ASSIGNMENT_JANITOR "Janitor"
#define ASSIGNMENT_MEDICAL "Medical"
#define ASSIGNMENT_SCIENTIST "Scientist"
#define ASSIGNMENT_SECURITY "Security"

GLOBAL_LIST_INIT(severity_to_string, list(EVENT_LEVEL_MUNDANE = "Mundane", EVENT_LEVEL_MODERATE = "Moderate", EVENT_LEVEL_MAJOR = "Major"))
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

		new next_event.event_type(next_event)	// Events are added and removed from the processing queue in their New/kill procs

		log_debug("Starting event '[next_event.name]' of severity [GLOB.severity_to_string[severity]].")
		SSblackbox.record_feedback("nested tally", "events", 1, list(GLOB.severity_to_string[severity], next_event.name))
		GLOB.event_last_fired[next_event] = world.time
		next_event = null						// When set to null, a random event will be selected next time
	else
		// If not, wait for one minute, instead of one tick, before checking again.
		next_event_time += (60 * 10)


/datum/event_container/proc/acquire_event()
	if(available_events.len == 0)
		return
	var/active_with_role = number_active_with_role()

	var/list/possible_events = list()
	for(var/datum/event_meta/EM in available_events)
		var/event_weight = EM.get_weight(active_with_role)
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

	if(possible_events.len == 0)
		return null

	// Select an event and remove it from the pool of available events
	var/picked_event = pickweight(possible_events)
	available_events -= picked_event
	return picked_event

/datum/event_container/proc/set_event_delay()
	// If the next event time has not yet been set and we have a custom first time start
	if(next_event_time == 0 && GLOB.configuration.event.first_run_times[severity])
		var/lower = GLOB.configuration.event.first_run_times[severity]["lower"]
		var/upper = GLOB.configuration.event.first_run_times[severity]["upper"]
		var/event_delay = rand(lower, upper)
		next_event_time = world.time + event_delay
	// Otherwise, follow the standard setup process
	else
		var/playercount_modifier = 1
		switch(GLOB.player_list.len)
			if(0 to 10)
				playercount_modifier = 1.2
			if(11 to 15)
				playercount_modifier = 1.1
			if(16 to 25)
				playercount_modifier = 1
			if(26 to 35)
				playercount_modifier = 0.9
			if(36 to 50)
				playercount_modifier = 0.8
			if(50 to 80)
				playercount_modifier = 0.7
			if(80 to 10000)
				playercount_modifier = 0.6

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
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, "Nothing",			/datum/event/nothing,			1100),
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, "PDA Spam",			/datum/event/pda_spam, 			0, 		list(ASSIGNMENT_ANY = 4), FALSE, 25, 50),
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, "Economic News",		/datum/event/economic_event,	300),
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, "Trivial News",		/datum/event/trivial_news, 		400),
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, "Mundane News", 		/datum/event/mundane_news, 		300),
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, "Vermin Infestation",/datum/event/infestation, 		100,	list(ASSIGNMENT_JANITOR = 100)),
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, "Sentience",			/datum/event/sentience,			50),
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, "Wallrot",			/datum/event/wallrot, 			0,		list(ASSIGNMENT_ENGINEER = 30, ASSIGNMENT_GARDENER = 50)),
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, "Koi School",		/datum/event/carp_migration/koi,		80),
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, "Camera Failure",	/datum/event/camera_failure,		100, list(ASSIGNMENT_ENGINEER = 10)),
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, "Fake Virus",		/datum/event/fake_virus,		50),
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, "Bureaucratic Error",/datum/event/bureaucratic_error,					80, TRUE),
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, "Disease Outbreak",	/datum/event/disease_outbreak, 			50,		list(ASSIGNMENT_MEDICAL = 25), TRUE)
	)

/datum/event_container/moderate
	severity = EVENT_LEVEL_MODERATE
	available_events = list(
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Nothing",					/datum/event/nothing,					1230),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "False Alarm",				/datum/event/falsealarm,					200),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Appendicitis", 			/datum/event/spontaneous_appendicitis, 	0,		list(ASSIGNMENT_MEDICAL = 10), TRUE),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Carp School",				/datum/event/carp_migration,			200, 	list(ASSIGNMENT_ENGINEER = 10, ASSIGNMENT_SECURITY = 20), TRUE),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Rogue Drones",				/datum/event/rogue_drone, 				0,		list(ASSIGNMENT_SECURITY = 20)),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Space Vines",				/datum/event/spacevine, 				250,	list(ASSIGNMENT_ENGINEER = 10)),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Meteor Shower",			/datum/event/meteor_wave,				0,		list(ASSIGNMENT_ENGINEER = 25)),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Solar Flare",				/datum/event/solar_flare,				0,		list(ASSIGNMENT_ENGINEER = 25)),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Meaty Ores",				/datum/event/dust/meaty,				0,		list(ASSIGNMENT_ENGINEER = 20)),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Communication Blackout",	/datum/event/communications_blackout,	500,	list(ASSIGNMENT_AI = 150, ASSIGNMENT_SECURITY = 120)),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Prison Break",				/datum/event/prison_break,				0,		list(ASSIGNMENT_SECURITY = 100)),
		//new /datum/event_meta(EVENT_LEVEL_MODERATE, "Virology Breach",			/datum/event/prison_break/virology,		0,		list(ASSIGNMENT_MEDICAL = 100)),
		//new /datum/event_meta(EVENT_LEVEL_MODERATE, "Xenobiology Breach",		/datum/event/prison_break/xenobiology,	0,		list(ASSIGNMENT_SCIENCE = 100)),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "APC Short",				/datum/event/apc_short, 				200,	list(ASSIGNMENT_ENGINEER = 60)),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Electrical Storm",			/datum/event/electrical_storm, 			250,	list(ASSIGNMENT_ENGINEER = 20, ASSIGNMENT_JANITOR = 150)),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Radiation Storm",			/datum/event/radiation_storm, 			25,		list(ASSIGNMENT_MEDICAL = 50), TRUE),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Spider Infestation",		/datum/event/spider_infestation, 		100,	list(ASSIGNMENT_SECURITY = 30), TRUE),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Ion Storm",				/datum/event/ion_storm, 				0,		list(ASSIGNMENT_AI = 50, ASSIGNMENT_CYBORG = 50, ASSIGNMENT_ENGINEER = 15, ASSIGNMENT_SCIENTIST = 5)),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Immovable Rod",			/datum/event/immovable_rod,				0,		list(ASSIGNMENT_ENGINEER = 30), TRUE),
		//new /datum/event_meta/ninja(EVENT_LEVEL_MODERATE, "Space Ninja",		/datum/event/space_ninja, 				0,		list(ASSIGNMENT_SECURITY = 15), TRUE),
		// NON-BAY EVENTS
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Mass Hallucination",		/datum/event/mass_hallucination,		300),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Brand Intelligence",		/datum/event/brand_intelligence,		50, 	list(ASSIGNMENT_ENGINEER = 25),	TRUE),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Dimensional Tear",			/datum/event/tear,						0,		list(ASSIGNMENT_SECURITY = 35)),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Honknomoly",				/datum/event/tear/honk,						0),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Vent Clog",				/datum/event/vent_clog,					250),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Wormholes",				/datum/event/wormholes,					150),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Pyro Anomaly",				/datum/event/anomaly/anomaly_pyro,		75,		list(ASSIGNMENT_ENGINEER = 60)),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Cryo Anomaly",				/datum/event/anomaly/anomaly_cryo,		75,		list(ASSIGNMENT_ENGINEER = 60)),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Vortex Anomaly",			/datum/event/anomaly/anomaly_vortex,	75,		list(ASSIGNMENT_ENGINEER = 25)),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Bluespace Anomaly",		/datum/event/anomaly/anomaly_bluespace,	75,		list(ASSIGNMENT_ENGINEER = 25)),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Flux Anomaly",				/datum/event/anomaly/anomaly_flux,		75,		list(ASSIGNMENT_ENGINEER = 50)),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Gravitational Anomaly",	/datum/event/anomaly/anomaly_grav,		200),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Revenant", 				/datum/event/revenant, 					150),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Morph Spawn", 				/datum/event/spawn_morph, 				40,		list(ASSIGNMENT_SECURITY = 10), is_one_shot = TRUE),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Disease Outbreak",			/datum/event/disease_outbreak, 			50,		list(ASSIGNMENT_MEDICAL = 30), TRUE),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Door Runtime",				/datum/event/door_runtime,				50,		list(ASSIGNMENT_ENGINEER = 25, ASSIGNMENT_AI = 150), TRUE)
	)

/datum/event_container/major
	severity = EVENT_LEVEL_MAJOR
	available_events = list(
		new /datum/event_meta(EVENT_LEVEL_MAJOR, "Nothing",				/datum/event/nothing,			590),
		new /datum/event_meta(EVENT_LEVEL_MAJOR, "Carp Migration",		/datum/event/carp_migration,	10,		list(ASSIGNMENT_SECURITY =  3), TRUE),
		//new /datum/event_meta(EVENT_LEVEL_MAJOR, "Containment Breach",	/datum/event/prison_break/station,	0,			list(ASSIGNMENT_ANY = 5)),
		new /datum/event_meta(EVENT_LEVEL_MAJOR, "APC Overload",		/datum/event/apc_overload,		0),
		new /datum/event_meta(EVENT_LEVEL_MAJOR, "Blob",				/datum/event/blob, 				30,		list(ASSIGNMENT_ENGINEER =  5), TRUE),
		new /datum/event_meta(EVENT_LEVEL_MAJOR, "Meteor Wave",			/datum/event/meteor_wave,		0,		list(ASSIGNMENT_ENGINEER =  10),	TRUE),
		new /datum/event_meta(EVENT_LEVEL_MAJOR, "Abductor Visit",		/datum/event/abductor, 		    20, 	list(ASSIGNMENT_SECURITY =  3), TRUE),
		new /datum/event_meta(EVENT_LEVEL_MAJOR, "Alien Infestation",	/datum/event/alien_infestation, 20,		list(ASSIGNMENT_SECURITY = 4), TRUE),
		new /datum/event_meta(EVENT_LEVEL_MAJOR, "Traders",				/datum/event/traders,			85, 	is_one_shot = TRUE),
		new /datum/event_meta(EVENT_LEVEL_MAJOR, "Terror Spiders",		/datum/event/spider_terror, 	20,		list(ASSIGNMENT_SECURITY = 4), TRUE),
		new /datum/event_meta(EVENT_LEVEL_MAJOR, "Slaughter Demon",		/datum/event/spawn_slaughter,	20,  	is_one_shot = TRUE),
		new /datum/event_meta(EVENT_LEVEL_MAJOR, "Shadow Demon", /datum/event/spawn_slaughter/shadow,	20, 	is_one_shot = TRUE)
		//new /datum/event_meta(EVENT_LEVEL_MAJOR, "Floor Cluwne",	/datum/event/spawn_floor_cluwne,	15, is_one_shot = TRUE)
	)


#undef ASSIGNMENT_ANY
#undef ASSIGNMENT_AI
#undef ASSIGNMENT_CYBORG
#undef ASSIGNMENT_ENGINEER
#undef ASSIGNMENT_BOTANIST
#undef ASSIGNMENT_JANITOR
#undef ASSIGNMENT_MEDICAL
#undef ASSIGNMENT_SCIENTIST
#undef ASSIGNMENT_SECURITY
