/obj/machinery/radar
	name = "Doppler Radar"
	desc = "An age-tested technology for measuring and predicting weather patterns. This one has been loaded with information of the local expected conditions."
	icon = 'icons/obj/machines/bluespace_tap.dmi'
	icon_state = "bluespace_tap"
	density = TRUE
	anchored = TRUE
	power_state = NO_POWER_USE // going to be used outside
	idle_power_consumption = 0
	pixel_x = -32
	// Time between callouts
	var/check_time
	// Internal radio to handle announcements over supply
	var/obj/item/radio/radio
	// for checking what was the last weather stage an alert was sent out
	var/last_stage
	// How accurate are we based off parts?
	var/accuracy_coeff
	// Base Inaccuracy
	var/inaccuracy = 5 MINUTES
	// What is our current prediction?
	var/prediction
	// dont want constant updates
	var/dont_announce = FALSE

/obj/machinery/radar/Initialize()
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/stock_parts/scanning_module(null)
	component_parts += new /obj/item/stock_parts/scanning_module(null)
	component_parts += new /obj/item/stock_parts/scanning_module(null)
	component_parts += new /obj/item/stock_parts/scanning_module(null)
	component_parts += new /obj/item/stack/cable_coil(null, 10)
	RefreshParts()
	check_time = world.time + (5 MINUTES) // short startup delay for roundstart

	AddComponent(/datum/component/multitile, list(
	list(1,		1,		1),
	list(1, 	1,		1),
	list(1, MACH_CENTER,1),
	))

	radio = new(src)
	radio.listening = FALSE
	radio.follow_target = src
	radio.config(list("Supply" = 0))

	AddComponent(/datum/component/largetransparency)

/obj/machinery/radar/process()
	if ((check_time > world.time))
		return

	for(var/datum/weather/W in SSweather.processing)
		if(W.barometer_predictable && (src.z in W.impacted_z_levels) && W.area_type == /area/lavaland/surface/outdoors)
			switch(W.stage)
				if(WEATHER_STARTUP_STAGE)
					if(last_stage == WEATHER_STARTUP_STAGE)
						return
					radio.autosay("<b>[W.name] detected converging over the local sector. Please finish any surface excavations.</b>", name, "Supply")
					last_stage = WEATHER_STARTUP_STAGE
					check_time = world.time + W.telegraph_duration + 5 SECONDS
					dont_announce = FALSE
					return
				if(WEATHER_MAIN_STAGE)
					if(last_stage == WEATHER_STARTUP_STAGE)
						return
					radio.autosay("<b>Inclement weather inbound. Seek shelter immediately.</b>", name, "Supply")
					last_stage = WEATHER_MAIN_STAGE
					check_time = world.time + (W.weather_duration / 2)
					return
				if(WEATHER_WIND_DOWN_STAGE)
					if(last_stage == WEATHER_WIND_DOWN_STAGE)
						return
					radio.autosay("<b>Incliment weather has dispersed. It is now safe to resume surface excavations.</b>", name, "Supply")
					last_stage = WEATHER_WIND_DOWN_STAGE
					dont_announce = FALSE
					return

		if(dont_announce == TRUE)
			return

		var/next_hit = SSweather.next_hit_by_zlevel["[src.z]"]
		var/next_difference = next_hit - world.time
		if(accuracy_coeff >= 4)
			if(next_difference <= 10 MINUTES)
			radio.autosay("<b>Weather patterns analyzed. Predicted weather event in [next_difference] minutes: [W.name] </b>", name, "Supply")
			dont_announce = TRUE
		else if (prob(accuracy_coeff) && next_difference < 10 MINUTES)
			radio.autosay("<b>Weather patterns analyzed. Predicted weather event in [next_difference] minutes: [W.name] </b>", name, "Supply")
			dont_announce = TRUE

/obj/machinery/radar/RefreshParts()
	for(var/obj/item/stock_parts/scanning_module/C in component_parts)
		accuracy_coeff += C.rating
	accuracy_coeff = accuracy_coeff / 4 //average all the parts










