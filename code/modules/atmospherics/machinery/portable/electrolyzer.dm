/obj/machinery/atmospherics/portable/electrolyzer
	name = "gas electrolyzer"
	anchored = FALSE
	icon = 'icons/obj/atmos.dmi'
	icon_state = "electrolyzer_off"
	density = TRUE
	var/open = FALSE
	var/datum/gas_mixture/gas
	var/board_path = /obj/item/circuitboard/electrolyzer
	on = FALSE

/obj/machinery/atmospherics/portable/electrolyzer/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/electrolyzer(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stack/cable_coil(null, 5)
	RefreshParts()

/obj/machinery/atmospherics/portable/electrolyzer/examine(mob/user)
	. = ..()
	. += "<span class='notice'>A nifty little machine that is able to produce hydrogen when supplied with water vapor, \
			allowing for on the go hydorgen production! Nanotrasen is not responsbile for any accidents that may occur \
			from sudden hydogen combustion or explosions. </span>"

/obj/machinery/atmospherics/portable/electrolyzer/wrench_act(mob/user, obj/item/I)
	if(!on)
		. = TRUE
		default_unfasten_wrench(user, I, 4 SECONDS)
	if(on)
		to_chat(user, "<span class='warning'>[src] must be turned off first!</span>")
		return

/obj/machinery/atmospherics/portable/electrolyzer/screwdriver_act(mob/user, obj/item/I)
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

/obj/machinery/atmospherics/portable/electrolyzer/crowbar_act(mob/living/user, obj/item/I)
	if(!open)
		default_deconstruction_crowbar(user, I)

/obj/machinery/atmospherics/portable/electrolyzer/AltClick(mob/user)
	if(anchored)
		to_chat(user, "<span class='warning'>[src] is anchored to the floor!</span>")
		return
	pixel_x = 0
	pixel_y = 0

// Turns the electrolyzer on and off
/obj/machinery/atmospherics/portable/electrolyzer/attack_hand(mob/user as mob)
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

/obj/machinery/atmospherics/portable/electrolyzer/process()
	var/datum/milla_safe/electrolyzer_process/milla = new()
	milla.invoke_async(src)

/datum/milla_safe/electrolyzer_process

/obj/machinery/atmospherics/portable/electrolyzer/proc/process_atmos_safely(turf/T, datum/gas_mixture/env)
	var/datum/gas_mixture/removed = new()
	if(env.water_vapor() > 3)
		removed.set_water_vapor(env.water_vapor())
		env.set_water_vapor(0)
	return removed

/obj/machinery/atmospherics/portable/electrolyzer/proc/has_water_vapor(datum/gas_mixture/gas)
	if(!gas)
		return FALSE
	return gas.water_vapor() > 3

/datum/milla_safe/electrolyzer_process/on_run(obj/machinery/atmospherics/portable/electrolyzer/electrolyzer, datum/gas_mixture)
	var/turf/T = get_turf(electrolyzer)
	var/datum/gas_mixture/env = get_turf_air(T)
	var/datum/gas_mixture/removed = electrolyzer.process_atmos_safely(T, env)
	if(electrolyzer.on && electrolyzer.has_water_vapor(removed))
		var/water_vapor_to_remove = removed.water_vapor()
		var/hydrogen_produced = water_vapor_to_remove
		var/oxygen_produced = water_vapor_to_remove / 2
		removed.set_water_vapor(0)
		env.set_hydrogen(hydrogen_produced)
		env.set_oxygen(oxygen_produced)

