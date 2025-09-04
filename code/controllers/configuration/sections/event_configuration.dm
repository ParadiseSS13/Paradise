/// Config holder for all stuff relating to ingame random events
/datum/configuration_section/event_configuration
	/// Do we want to enable random events at all
	var/enable_random_events = TRUE
	/// Assoc list of when the first event in a group can run. key: severity | value: assoc list with upper and low bounds (key: "upper"/"lower" | value: time in deciseconds)
	var/list/first_run_times = list(
		EVENT_LEVEL_MUNDANE = null,
		EVENT_LEVEL_MODERATE = null,
		EVENT_LEVEL_MAJOR = list("lower" = 40 MINUTES, "upper" = 50 MINUTES)
	) // <---- Whoever designed this needs to be shot

	/// Assoc list of lower bounds of event delays. key: severity | value: delay (deciseconds)
	var/list/delay_lower_bound = list(
		EVENT_LEVEL_MUNDANE = 5 MINUTES,
		EVENT_LEVEL_MODERATE = 15 MINUTES,
		EVENT_LEVEL_MAJOR = 25 MINUTES
	)
	/// Assoc list of lower bounds of event delays. key: severity | value: delay (deciseconds)
	var/list/delay_upper_bound = list(
		EVENT_LEVEL_MUNDANE = 7.5 MINUTES,
		EVENT_LEVEL_MODERATE = 22.5 MINUTES,
		EVENT_LEVEL_MAJOR = 35 MINUTES
	)
	/// Expected time of a round in deciseconds
	var/expected_round_length = 120 MINUTES // This macro is equivilent to 72,000 deciseconds

	/// the population needed to allow blobs to split consciousness
	var/blob_highpop_trigger = 60

/datum/configuration_section/event_configuration/load_data(list/data)
	// Use the load wrappers here. That way the default isnt made 'null' if you comment out the config line
	CONFIG_LOAD_BOOL(enable_random_events, data["allow_random_events"])

	// Wrapper cant be used here due to it being multiplied
	if(isnum(data["expected_round_length"]))
		expected_round_length = data["expected_round_length"] MINUTES // Convert from minutes to deciseconds

	// Load event severities. This is quite awful but needs to be done so we can account for config mistakes. This event system is awful
	if(islist(data["event_delay_lower_bounds"]))
		CONFIG_LOAD_NUM_MULT(delay_lower_bound[EVENT_LEVEL_MUNDANE], data["event_delay_lower_bounds"]["mundane"], MINUTES)
		CONFIG_LOAD_NUM_MULT(delay_lower_bound[EVENT_LEVEL_MODERATE], data["event_delay_lower_bounds"]["moderate"], MINUTES)
		CONFIG_LOAD_NUM_MULT(delay_lower_bound[EVENT_LEVEL_MAJOR], data["event_delay_lower_bounds"]["major"], MINUTES)

	// Same here. I hate this.
	if(islist(data["event_delay_upper_bounds"]))
		CONFIG_LOAD_NUM_MULT(delay_upper_bound[EVENT_LEVEL_MUNDANE], data["event_delay_upper_bounds"]["mundane"], MINUTES)
		CONFIG_LOAD_NUM_MULT(delay_upper_bound[EVENT_LEVEL_MODERATE], data["event_delay_upper_bounds"]["moderate"], MINUTES)
		CONFIG_LOAD_NUM_MULT(delay_upper_bound[EVENT_LEVEL_MAJOR], data["event_delay_upper_bounds"]["major"], MINUTES)

	// And for the worst, the first run delays. I hate this so much -aa07
	if(islist(data["event_initial_delays"]))
		for(var/list/assoclist in data["event_initial_delays"])
			var/target = null
			switch(assoclist["severity"])
				if("mundane")
					target = EVENT_LEVEL_MUNDANE
				if("moderate")
					target = EVENT_LEVEL_MODERATE
				if("major")
					target = EVENT_LEVEL_MAJOR
			ASSERT(target in list(EVENT_LEVEL_MUNDANE, EVENT_LEVEL_MODERATE, EVENT_LEVEL_MAJOR))
			first_run_times[target] = list("lower" = assoclist["lower_bound"] MINUTES, "upper" = assoclist["upper_bound"] MINUTES)

	CONFIG_LOAD_NUM(blob_highpop_trigger, data["blob_highpop_trigger"])

