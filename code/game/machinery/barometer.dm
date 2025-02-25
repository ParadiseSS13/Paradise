/obj/machinery/radar
	name = "Doppler Radar"
	desc = "An age-tested technology for measuring and predicting weather patterns. This one has been loaded with information of the local expected conditions."
	icon = 'icons/obj/machines/telecomms.dmi'
	icon_state = "error"
	density = TRUE
	anchored = TRUE
	idle_power_consumption = 1000
	pixel_x = -32	//shamelessly stolen from dna vault
	pixel_y = -32
	// Time between callouts
	var/check_time
	/// Internal radio to handle announcements over supply
	var/obj/item/radio/radio

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

	radio = new(src)
	radio.listening = FALSE
	radio.follow_target = src
	radio.config(list("Supply" = 0))
	))

/obj/machinery/rdar/Process()
	if (check_time > world.time)
		return
	check_time = world.time + (rand(30 SECONDS, 2 MINUTES)) // some fluctations in check times

	for(var/datum/weather/W in SSweather.processing)
		if(W.barometer_predictable && (src.z in W.impacted_z_levels) && weather.area_type == user_area.type)
		switch(W.stage)
			if(telegraph)

