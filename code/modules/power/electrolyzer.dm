/obj/machinery/power/electrolyzer
	name = "gas electrolyzer"
	desc = "A nifty little machine that is able to produce hydrogen when supplied with water vapor and enough power, allowing for on-the-go hydrogen production! Nanotrasen is not responsible for any accidents that may occur from sudden hydrogen combustion or explosions. It seems it needs around 350 kW of power to funtion properly."
	anchored = FALSE
	icon = 'icons/obj/atmos.dmi'
	icon_state = "electrolyzer_off"
	density = TRUE
	active_power_consumption = 350000
	/// whether or not we're actively using power/seeking water vapor in the air
	var/on = FALSE
	var/datum/gas_mixture/gas
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

/obj/machinery/power/electrolyzer/wrench_act(mob/living/user, obj/item/I)
	if(on)
		return
	. = TRUE
	if(!I.use_tool(src, user, I.tool_volume))
		return
	if(!anchored)
		connect_to_network()
		to_chat(user, SPAN_NOTICE("You secure the generator to the floor."))
	else
		disconnect_from_network()
		to_chat(user, SPAN_NOTICE("You unsecure the generator from the floor."))
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
	var/datum/gas_mixture/removed = new()
	if(env.water_vapor() > 3)
		removed.set_water_vapor(env.water_vapor())
		env.set_water_vapor(0)
	return removed

/obj/machinery/power/electrolyzer/proc/has_water_vapor(datum/gas_mixture/gas)
	if(!gas)
		return FALSE
	return gas.water_vapor() > 3

/datum/milla_safe/electrolyzer_process/on_run(obj/machinery/power/electrolyzer/electrolyzer, datum/gas_mixture)
	var/turf/T = get_turf(electrolyzer)
	var/datum/gas_mixture/env = get_turf_air(T)
	var/datum/gas_mixture/removed = electrolyzer.process_atmos_safely(T, env)

	if(electrolyzer.on && electrolyzer.has_water_vapor(removed))
		var/water_vapor_to_remove = removed.water_vapor()
		var/hydrogen_produced = water_vapor_to_remove
		var/oxygen_produced = water_vapor_to_remove / 2
		removed.set_water_vapor(removed.water_vapor() - water_vapor_to_remove)
		env.set_hydrogen(env.hydrogen() + hydrogen_produced)
		env.set_oxygen(env.oxygen() + oxygen_produced)
