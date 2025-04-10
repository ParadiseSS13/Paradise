

//Used for all kinds of weather, ex. lavaland ash storms.
SUBSYSTEM_DEF(weather)
	name = "Weather"
	flags = SS_BACKGROUND
	wait = 10
	runlevels = RUNLEVEL_GAME
	offline_implications = "Ash storms will no longer trigger. No immediate action is needed."
	var/list/processing = list()
	var/list/eligible_traits = list()
	var/list/next_hit_by_zlevel = list() //Used by barometers to know when the next storm is coming
	var/list/next_weather_by_zlevel = list() // For the weather radar detection
	cpu_display = SS_CPUDISPLAY_LOW

/datum/controller/subsystem/weather/get_metrics()
	. = ..()
	var/list/cust = list()
	cust["processing"] = length(processing)
	.["custom"] = cust

/datum/controller/subsystem/weather/fire()
	// process active weather
	for(var/V in processing)
		var/datum/weather/W = V
		if(W.aesthetic || W.stage != WEATHER_MAIN_STAGE)
			continue
		for(var/i in GLOB.mob_living_list)
			var/mob/living/L = i
			if(W.can_weather_act(L))
				W.weather_act(L)
		if(W.area_act == TRUE)
			W.area_act()

	// start random weather on relevant levels
	while(length(eligible_traits))
		var/trait = eligible_traits[length(eligible_traits)]
		var/possible_weathers = eligible_traits[trait]
		var/datum/weather/W = pickweight(possible_weathers)
		var/randTime = rand(3000, 6000)
		var/list/zlevels = levels_by_trait(trait)
		for(var/z in zlevels)
			addtimer(CALLBACK(src, PROC_REF(make_eligible), trait, possible_weathers), randTime + initial(W.weather_duration_upper), TIMER_UNIQUE) //Around 5-10 minutes between weathers
			next_hit_by_zlevel["[z]"] = world.time + randTime + initial(W.telegraph_duration)
			next_weather_by_zlevel["[z]"] = W
		run_weather(W, zlevels)

		eligible_traits.len--

/datum/controller/subsystem/weather/Initialize()
	if(!GLOB.configuration.general.enable_default_weather_events)
		log_debug("disabling default weather events due to configuration")
		return

	for(var/V in subtypesof(/datum/weather))
		var/datum/weather/W = V
		// any weather with a probability set may occur at random
		if(W::probability)
			LAZYINITLIST(eligible_traits[W::target_trait])
			eligible_traits[W::target_trait][W] = W::probability

/datum/controller/subsystem/weather/proc/run_weather(datum/weather/weather_datum_type)
	if(istext(weather_datum_type))
		for(var/V in subtypesof(/datum/weather))
			var/datum/weather/W = V
			if(initial(W.name) == weather_datum_type)
				weather_datum_type = V
				break
	if(!ispath(weather_datum_type, /datum/weather))
		CRASH("run_weather called with invalid weather_datum_type: [weather_datum_type || "null"]")

	var/list/zlevels = levels_by_trait(weather_datum_type::target_trait)
	var/datum/weather/W = new weather_datum_type(zlevels)
	W.telegraph()
	SSblackbox.record_feedback("tally", "weather_event", 1, "[weather_datum_type]")

/datum/controller/subsystem/weather/proc/make_eligible(trait, list/possible_weathers)
	eligible_traits[trait] = possible_weathers
	for(var/zlevel in levels_by_trait(trait))
		next_hit_by_zlevel["[zlevel]"] = null
		next_weather_by_zlevel["[zlevel]"] = null

/datum/controller/subsystem/weather/proc/get_weather(z, area/active_area)
	var/datum/weather/A
	for(var/V in processing)
		var/datum/weather/W = V
		if((z in W.impacted_z_levels) && is_path_in_list(active_area, W.area_types))
			A = W
			break
	return A
