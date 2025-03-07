/obj/machinery/atmospherics/portable/electrolyzer
	name = "gas electrolyzer"
	anchored = FALSE
	icon = 'icons/obj/atmos.dmi'
	icon_state = "electrolyzer_off"
	density = TRUE
	var/datum/gas_mixture/gas
	var/board_path = /obj/item/circuitboard/electrolyzer
	on = FALSE


/obj/machinery/atmospherics/portable/electrolyzer/examine(mob/user)
	. = ..()
	. += "<span class='notice'>A nifty little machine that is able to produce hydrogen when supplied with water vapor, \
			allowing for on the go hydorgen production! Nanotrasen is not responsbile for any accidents that may occur \
			from sudden hydogen combustion or explosions. </span>"

/obj/machinery/atmospherics/portable/electrolyzer/wrench_act(mob/user, obj/item/I)
	. = TRUE
	default_unfasten_wrench(user, I, 4 SECONDS)

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
		var/hydrogen_produced = (water_vapor_to_remove / 3) * 2
		var/oxygen_produced = water_vapor_to_remove / 2
		removed.set_water_vapor(0)
		env.set_hydrogen(hydrogen_produced)
		env.set_oxygen(oxygen_produced)

