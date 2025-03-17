/obj/machinery/power/electrolyzer
	name = "gas electrolyzer"
	anchored = FALSE
	icon = 'icons/obj/atmos.dmi'
	icon_state = "electrolyzer_off"
	density = TRUE
	var/on = FALSE
	var/open = FALSE
	var/datum/gas_mixture/gas
	var/board_path = /obj/item/circuitboard/electrolyzer

/obj/machinery/power/electrolyzer/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/electrolyzer(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/capacitor(null)
	component_parts += new /obj/item/stack/cable_coil(null, 5)
	if(!powernet)
		connect_to_network()
	RefreshParts()

/obj/machinery/power/electrolyzer/examine(mob/user)
	. = ..()
	. += "<span class='notice'>A nifty little machine that is able to produce hydrogen when supplied with water vapor and \
			enough power, allowing for on the go hydrogen production! Nanotrasen is not responsbile for any accidents that \
			may occur from sudden hydogen combustion or explosions. </span>"

/obj/machinery/power/electrolyzer/wrench_act(mob/user, obj/item/I)
	if(!on)
		. = TRUE
		default_unfasten_wrench(user, I, 4 SECONDS)
	if(on)
		to_chat(user, "<span class='warning'>[src] must be turned off first!</span>")
		return

/obj/machinery/power/electrolyzer/screwdriver_act(mob/user, obj/item/I)
	if(on)
		to_chat(user, "<span class='warning'>[src] must be turned off first!</span>")
		return
	if(!I.use_tool(src, user, 0, volume = 0))
		return
	if(!open && !on)
		SCREWDRIVER_OPEN_PANEL_MESSAGE
		open = TRUE
		icon_state = "electrolyzer_open"
	else
		SCREWDRIVER_CLOSE_PANEL_MESSAGE
		icon_state = "electrolyzer_off"
		open = FALSE

/obj/machinery/power/electrolyzer/crowbar_act(mob/living/user, obj/item/I)
	if(open)
		deconstruct(TRUE)
		to_chat(user, "<span class='notice'>You disassemble [src].</span>")
		I.play_tool_sound(user, I.tool_volume)
		return TRUE
	return FALSE

/obj/machinery/power/electrolyzer/AltClick(mob/user)
	if(anchored)
		to_chat(user, "<span class='warning'>[src] is anchored to the floor!</span>")
		return
	pixel_x = 0
	pixel_y = 0

/obj/machinery/power/electrolyzer/process()
	if(on)
		var/datum/milla_safe/electrolyzer_process/milla = new()
		milla.invoke_async(src)

// Turns the electrolyzer on and off
/obj/machinery/power/electrolyzer/attack_hand(mob/user as mob)
	if(stat & BROKEN)
		return
	if(!anchored)
		to_chat(user, "<span class='warning'>[src] must be anchored first!</span>")
		return

	. = ..()
	if(on)
		on = FALSE
		to_chat(user, "<span class='notice'>The electrolyzer switches off.</span>")
		icon_state = "electrolyzer_off"
	else
		on = TRUE
		to_chat(user, "<span class='notice'>The electrolyzer begins to hum quietly.</span>")
		icon_state = "electrolyzer_on"
	add_fingerprint(usr)

/datum/milla_safe/electrolyzer_process

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

/obj/machinery/power/electrolyzer/process()
	var/datum/milla_safe/electrolyzer_process/milla = new()
	milla.invoke_async(src)

/datum/milla_safe/electrolyzer_process/on_run(obj/machinery/power/electrolyzer/electrolyzer, datum/gas_mixture)
	var/turf/T = get_turf(electrolyzer)
	var/datum/gas_mixture/env = get_turf_air(T)
	var/datum/gas_mixture/removed = electrolyzer.process_atmos_safely(T, env)

	if(electrolyzer.on && electrolyzer.has_water_vapor(removed))
	    // Convert as much water vapor as we can into hydrogen, depending on how much power we have available
		var/power_needed_per_mole = HYDROGEN_BURN_ENERGY / WATT_TICK_TO_JOULE
		var/water_vapor_to_remove = min(removed.water_vapor(), electrolyzer.get_surplus() / power_needed_per_mole)
		var/hydrogen_produced = water_vapor_to_remove
		var/oxygen_produced = water_vapor_to_remove / 2
		removed.set_water_vapor(0)
		env.set_hydrogen(hydrogen_produced)
		env.set_oxygen(oxygen_produced)
		electrolyzer.consume_direct_power(power_needed_per_mole)

