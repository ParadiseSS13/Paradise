#define RADAR_NEEDS_WELDING 0
#define RADAR_NEEDS_PLASTEEL 1
#define RADAR_NEEDS_WRENCH 2
#define RADAR_NEEDS_SCREWDRIVER 3

/obj/machinery/radar
	name = "Doppler Radar"
	desc = "An age-tested technology for measuring and predicting weather patterns. This one has been loaded with information of the local expected conditions."
	icon = 'icons/obj/machines/doppler_tower.dmi'
	icon_state = "base"
	density = TRUE
	anchored = TRUE
	layer = ABOVE_ALL_MOB_LAYER
	power_state = NO_POWER_USE // going to be used outside
	interact_offline = TRUE
	pixel_x = -32
	armor = list(MELEE = 80, BULLET = 10, LASER = 30, ENERGY = 30, BOMB = 50, RAD = 0, FIRE = 100, ACID = 100)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	/// Time between callouts
	var/check_time
	/// Internal radio to handle announcements over supply
	var/obj/item/radio/radio
	/// For checking what was the last weather stage an alert was sent out
	var/last_stage
	/// How accurate are we based off parts?
	var/accuracy_coeff
	/// Base Inaccuracy
	var/inaccuracy = 5 MINUTES
	/// What is our current prediction?
	var/prediction
	/// Don't want constant updates
	var/dont_announce = TRUE
	/// For fakeout calls
	var/correct_prediction
	/// Are we broken?
	var/construction_state = RADAR_NEEDS_WELDING
	luminosity = 1

/obj/machinery/radar/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/machine/radar(null)
	component_parts += new /obj/item/stock_parts/scanning_module(null)
	component_parts += new /obj/item/stock_parts/scanning_module(null)
	component_parts += new /obj/item/stock_parts/scanning_module(null)
	component_parts += new /obj/item/stock_parts/scanning_module(null)
	component_parts += new /obj/item/stack/cable_coil(null, 10)
	RefreshParts()
	set_light(5, 2, "#e2db98") // so the machine isnt pitch black

	AddComponent(/datum/component/multitile, list(
	list(1, 	1),
	list(1, MACH_CENTER),
	))

	radio = new(src)
	radio.listening = FALSE
	radio.follow_target = src
	radio.config(list("Supply" = 0))

	AddComponent(/datum/component/largetransparency, -1, 2, 0, 1)
	update_appearance(UPDATE_OVERLAYS)

/obj/machinery/radar/update_overlays()
	. = ..()
	if(stat & BROKEN)
		icon_state = "broken"
	else
		icon_state = "base"
		. += "chicken"
		. += "screen"

/obj/machinery/radar/process()
	if(stat & BROKEN)
		return
	if(check_time > world.time)
		return

	for(var/datum/weather/W in SSweather.processing)
		if(!W)
			break
		if(W.barometer_predictable && is_path_in_list(/area/lavaland/surface/outdoors, W.area_types))
			switch(W.stage)
				if(WEATHER_STARTUP_STAGE)
					if(last_stage == WEATHER_STARTUP_STAGE)
						return
					if(W.aesthetic)
						if(correct_prediction) // unupgraded machines should still scare the poor bastards
							radio.autosay("<b>[W.name] detected settling over the sector. No further action required.</b>", name, "Supply")
						else
							radio.autosay("<b>Ash Storm detected converging over the local sector. Please finish any surface excavations.</b>", name, "Supply")
					else
						radio.autosay("<b>[W.name] detected converging over the local sector. Please finish any surface excavations.</b>", name, "Supply")
					last_stage = WEATHER_STARTUP_STAGE
					check_time = world.time + W.telegraph_duration + 5 SECONDS
					return
				if(WEATHER_MAIN_STAGE)
					if(last_stage == WEATHER_MAIN_STAGE)
						return
					radio.autosay("<b>Inclement weather has reached the local sector. Seek shelter immediately.</b>", name, "Supply")
					last_stage = WEATHER_MAIN_STAGE
					check_time = world.time + (W.weather_duration / 2)
					return
				if(WEATHER_WIND_DOWN_STAGE)
					if(last_stage == WEATHER_WIND_DOWN_STAGE)
						return
					radio.autosay("<b>Inclement weather has dispersed. It is now safe to resume surface excavations.</b>", name, "Supply")
					last_stage = WEATHER_WIND_DOWN_STAGE
					dont_announce = FALSE
					return

	if(dont_announce)
		return

	var/datum/weather/next_weather = SSweather.next_weather_by_zlevel["[z]"]
	var/next_hit = SSweather.next_hit_by_zlevel["[z]"]
	var/next_difference = next_hit - world.time
	var/difference_rounded = DisplayTimeText(max(1, next_difference))

	if(next_weather == "0" || next_weather == null)
		return
	if(accuracy_coeff >= 4) //perfect accuracy
		if(next_difference <= (3 MINUTES))
			radio.autosay("<b>Weather patterns successfully analyzed. Predicted weather event in [difference_rounded]: [next_weather.name].</b>", name, "Supply")
			dont_announce = TRUE
			correct_prediction = TRUE
	else if(prob(accuracy_coeff) && next_difference <= 3 MINUTES && next_difference >= 30 SECONDS)
		if(next_weather == "emberfall" && !prob(10 * accuracy_coeff)) // fake callout
			radio.autosay("<b>Weather patterns successfully analyzed. Predicted weather event in [difference_rounded]: ash storm.</b>", name, "Supply")
			dont_announce = TRUE
			correct_prediction = FALSE
		else
			radio.autosay("<b>Weather patterns successfully analyzed. Predicted weather event in [difference_rounded]: [next_weather.name].</b>", name, "Supply")
			dont_announce = TRUE
			correct_prediction = TRUE

/obj/machinery/radar/examine(mob/user)
	. = ..()
	if(!(stat & BROKEN))
		return

	switch(construction_state)
		if(RADAR_NEEDS_WELDING)
			. += "<span class='notice'>The framework is damaged, and needs welding.</span>"
		if(RADAR_NEEDS_PLASTEEL)
			. += "<span class='notice'>The framework needs new plasteel plating.</span>"
		if(RADAR_NEEDS_WRENCH)
			. += "<span class='notice'>The plating needs wrenching into place.</span>"
		if(RADAR_NEEDS_SCREWDRIVER)
			. += "<span class='notice'>The cover screws are loose.</span>"

// Interaction

//		REPAIRS		//
// Step 1
// (stolen from gav gen teehee)
/obj/machinery/radar/welder_act(mob/user, obj/item/I)
	if(construction_state != RADAR_NEEDS_WELDING)
		return
	. = TRUE
	if(!I.use_tool(src, user, null, 1, I.tool_volume))
		return
	to_chat(user, "<span class='notice'>You mend the damaged framework.</span>")
	construction_state = RADAR_NEEDS_PLASTEEL

// Step 2
/obj/machinery/radar/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(construction_state != RADAR_NEEDS_PLASTEEL)
		return ..()

	if(istype(used, /obj/item/stack/sheet/plasteel))
		var/obj/item/stack/sheet/plasteel/PS = used
		if(PS.amount < 10)
			to_chat(user, "<span class='warning'>You need 10 sheets of plasteel.</span>")
			return ITEM_INTERACT_COMPLETE

		to_chat(user, "<span class='notice'>You add new plating to the framework.</span>")
		construction_state = RADAR_NEEDS_WRENCH
		update_icon()
		return ITEM_INTERACT_COMPLETE

	return ..()

// Step 3
/obj/machinery/radar/wrench_act(mob/living/user, obj/item/I)
	if(construction_state != RADAR_NEEDS_WRENCH)
		return
	. = TRUE
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return
	to_chat(user, "<span class='notice'>You secure the plating to the framework.</span>")
	construction_state = RADAR_NEEDS_SCREWDRIVER


// Step 4
/obj/machinery/radar/screwdriver_act(mob/living/user, obj/item/I)
	if(!(stat & BROKEN)) // Not actually broken
		return
	if(construction_state != RADAR_NEEDS_SCREWDRIVER)
		return
	. = TRUE
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return
	to_chat(user, "<span class='notice'>You screw the covers back into place.</span>")
	set_fixed()

/obj/machinery/radar/RefreshParts()
	accuracy_coeff = 0
	for(var/obj/item/stock_parts/scanning_module/C in component_parts)
		accuracy_coeff += C.rating
	accuracy_coeff = (accuracy_coeff / 4) //average all the parts

// We dont want them to rebuild this in random places. but if it does somehow delete, we should log it
/obj/machinery/radar/Destroy()
	investigate_log("was destroyed!", "radar")
	qdel(radio)
	component_parts -= /obj/item/circuitboard/machine/radar // dont let them get the board
	new /obj/item/circuitboard/machine/radar/broken(src)
	. = ..()

/obj/machinery/radar/ex_act(severity)
	if(severity == EXPLODE_DEVASTATE) // Very sturdy.
		set_broken()

/obj/machinery/radar/proc/set_broken()
	stat |= BROKEN
	investigate_log("has broken down.", "radar")
	update_icon()

/obj/machinery/radar/proc/set_fixed()
	stat &= ~BROKEN
	construction_state = initial(construction_state)
	update_icon()

/obj/item/circuitboard/machine/radar
	board_name = "Doppler Radar"
	icon_state = "supply"
	build_path = /obj/machinery/radar
	origin_tech = "engineering=2"
	req_components = list(
		/obj/item/stack/cable_coil = 5,
		/obj/item/stack/sheet/glass = 10,
		/obj/item/stock_parts/scanning_module = 4,
	)

/obj/item/circuitboard/machine/radar/broken
	desc = "Bits of char, plastic, and ash cling to the boards surface. How it was working before was nothing short of a miracle. It's probably not going to work again."
	icon_state = "command_broken"

#undef RADAR_NEEDS_WELDING
#undef RADAR_NEEDS_PLASTEEL
#undef RADAR_NEEDS_WRENCH
#undef RADAR_NEEDS_SCREWDRIVER
