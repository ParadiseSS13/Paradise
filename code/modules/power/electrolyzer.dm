/obj/machinery/power/electrolyzer
	name = "gas electrolyzer"
	desc = "A nifty little machine that is able to produce hydrogen when supplied with water vapor and enough power, allowing for on-the-go hydrogen production! Nanotrasen is not responsible for any accidents that may occur from sudden hydrogen combustion or explosions."
	anchored = FALSE
	icon = 'icons/obj/atmos.dmi'
	icon_state = "electrolyzer_off"
	density = TRUE
	active_power_consumption = 350000
	/// whether or not we're actively using power/seeking water vapor in the air
	var/on = FALSE
	/// minimum water vapor present before starting to process gas
	var/min_water_vapor = 3
	/// maximum water vapor we pull from the atmosphere in a single tick
	var/extraction_rate = 5
	var/board_path = /obj/item/circuitboard/electrolyzer

/obj/machinery/power/electrolyzer/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/electrolyzer(src)
	component_parts += new /obj/item/stock_parts/micro_laser(src)
	component_parts += new /obj/item/stock_parts/micro_laser(src)
	component_parts += new /obj/item/stock_parts/matter_bin(src)
	component_parts += new /obj/item/stock_parts/matter_bin(src)
	component_parts += new /obj/item/stock_parts/capacitor(src)
	component_parts += new /obj/item/stack/cable_coil(src, 5)
	if(!powernet)
		connect_to_network()

	if(powernet)
		RegisterSignal(powernet)

	RefreshParts()

/obj/machinery/power/electrolyzer/RefreshParts()
	var/laser_rating = 0
	var/bin_rating = 0
	for(var/obj/item/stock_parts/micro_laser/laser in component_parts)
		laser_rating += laser.rating
	for(var/obj/item/stock_parts/matter_bin/bin in component_parts)
		bin_rating += bin.rating
	update_active_power_consumption(power_channel, initial(active_power_consumption) * 2 / max(laser_rating, 2))
	extraction_rate = initial(extraction_rate) * max(bin_rating, 2) / 2

/obj/machinery/power/electrolyzer/upgraded/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/electrolyzer(src)
	component_parts += new /obj/item/stock_parts/micro_laser/quadultra(src)
	component_parts += new /obj/item/stock_parts/micro_laser/quadultra(src)
	component_parts += new /obj/item/stock_parts/matter_bin/bluespace(src)
	component_parts += new /obj/item/stock_parts/matter_bin/bluespace(src)
	component_parts += new /obj/item/stock_parts/capacitor/quadratic(src)
	component_parts += new /obj/item/stack/cable_coil(src, 5)
	if(!powernet)
		connect_to_network()

	if(powernet)
		RegisterSignal(powernet)

	RefreshParts()

/obj/machinery/power/electrolyzer/examine(mob/user)
	. = ..()
	. += SPAN_NOTICE("[src] needs <b>[active_power_consumption / 1000]kW</b> of power to operate.")

/obj/machinery/power/electrolyzer/wrench_act(mob/living/user, obj/item/I)
	if(on)
		return
	. = TRUE
	if(!I.use_tool(src, user, I.tool_volume))
		return
	if(!anchored)
		connect_to_network()
		WRENCH_ANCHOR_MESSAGE
	else
		disconnect_from_network()
		WRENCH_UNANCHOR_MESSAGE
	anchored = !anchored

/obj/machinery/power/electrolyzer/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	if(!anchored)
		to_chat(user, SPAN_WARNING("[src] needs to be secured down first!"))
		return
	if(on)
		to_chat(user, SPAN_WARNING("[src] needs to be turned off first!"))
		return
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	panel_open = !panel_open
	if(panel_open)
		SCREWDRIVER_OPEN_PANEL_MESSAGE
		panel_open = TRUE
		icon_state = "electrolyzer_open"
	else
		SCREWDRIVER_CLOSE_PANEL_MESSAGE
		icon_state = "electrolyzer_off"
		panel_open = FALSE

/obj/machinery/power/electrolyzer/crowbar_act(mob/living/user, obj/item/I)
	if(panel_open)
		deconstruct(TRUE)
		to_chat(user, SPAN_NOTICE("You disassemble [src]."))
		I.play_tool_sound(user, I.tool_volume)
		return TRUE
	return FALSE

/obj/machinery/power/electrolyzer/AltClick(mob/user)
	if(anchored)
		to_chat(user, SPAN_WARNING("[src] is anchored to the floor!"))
		return
	pixel_x = 0
	pixel_y = 0

/obj/machinery/power/electrolyzer/Destroy()
	if(powernet)
		UnregisterSignal(powernet, COMSIG_POWERNET_POWER_CHANGE)
	return ..()

/datum/milla_safe/electrolyzer_process

/obj/machinery/power/electrolyzer/process()
	if(on && get_surplus() >= active_power_consumption)
		consume_direct_power(active_power_consumption)
		var/datum/milla_safe/electrolyzer_process/milla = new()
		milla.invoke_async(src)

// Turns the electrolyzer on and off
/obj/machinery/power/electrolyzer/attack_hand(mob/user)
	if(stat & BROKEN)
		return
	if(!anchored)
		to_chat(user, SPAN_WARNING("[src] must be anchored first!"))
		return
	if(panel_open)
		to_chat(user, SPAN_WARNING("Close the panel first!"))
		return
	var/area/A = get_area(src)
	if(!istype(A) || !A.powernet.has_power(PW_CHANNEL_EQUIPMENT))
		to_chat(user, SPAN_WARNING("[src] must be powered!"))
		return
	. = ..()
	if(on)
		on = FALSE
		to_chat(user, SPAN_NOTICE("[src] switches off."))
		icon_state = "electrolyzer_off"
	else
		on = TRUE
		to_chat(user, SPAN_NOTICE("[src] begins to hum quietly."))
		icon_state = "electrolyzer_on"
	add_fingerprint(usr)

/obj/machinery/power/electrolyzer/proc/process_atmos_safely(turf/T, datum/gas_mixture/env)
	if(!env)
		return

	var/available_water_vapor = env.water_vapor()
	if(available_water_vapor <= min_water_vapor)
		return

	var/datum/gas_mixture/removed = new()
	var/water_vapor_to_remove = min(available_water_vapor, extraction_rate)
	removed.set_water_vapor(water_vapor_to_remove)
	// we need to make sure the temperature of the water vapor isn't just forgotten
	removed.set_temperature(env.temperature())
	env.set_water_vapor(available_water_vapor - water_vapor_to_remove)
	return removed

/datum/milla_safe/electrolyzer_process/on_run(obj/machinery/power/electrolyzer/electrolyzer, datum/gas_mixture)
	if(!electrolyzer.on)
		return

	var/turf/T = get_turf(electrolyzer)
	if(!T)
		return

	var/datum/gas_mixture/env = get_turf_air(T)
	if(!env)
		return

	var/datum/gas_mixture/removed = electrolyzer.process_atmos_safely(T, env)
	if(!removed || removed.water_vapor() <= 0)
		return

	var/water_vapor_to_remove = removed.water_vapor()
	var/hydrogen_produced = water_vapor_to_remove
	var/oxygen_produced = water_vapor_to_remove / 2
	var/datum/gas_mixture/produced = new()
	produced.set_temperature(env.temperature())
	produced.set_hydrogen(hydrogen_produced)
	produced.set_oxygen(oxygen_produced)
	env.merge(produced)
