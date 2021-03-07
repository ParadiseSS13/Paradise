/obj/machinery/snow_machine
	name = "snow machine"
	desc = "Just add water and you too can have your own winter wonderland! Carol singers not included."
	icon_state = "snow_machine_off"
	density = TRUE
	anchored = FALSE
	layer = OBJ_LAYER
	var/active = FALSE
	var/power_used_this_cycle = 0
	var/cooling_speed = 1
	var/power_efficiency = 1
	var/lower_temperature_limit = T0C - 10 //Set lower for a bigger freeze
	var/infinite_snow = FALSE //Set this to have it not use water

/obj/machinery/snow_machine/New()
	..()
	create_reagents(300) //Makes 100 snow tiles!
	reagents.add_reagent("water", 300) //But any reagent will do
	reagents.flags |= REAGENT_NOREACT //Because a) this doesn't need to process and b) this way we can use any reagents without needing to worry about explosions and shit
	container_type = REFILLABLE
	component_parts = list()
	component_parts += new /obj/item/circuitboard/snow_machine(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	RefreshParts()

/obj/machinery/snow_machine/examine(mob/user)
	. = ..()
	. += "<span class='notice'>The internal reservoir indicates it is [infinite_snow ? "100" : round(reagents.total_volume / reagents.maximum_volume * 100)]% full.</span>"

/obj/machinery/snow_machine/RefreshParts()
	power_efficiency = 0
	cooling_speed = 0
	for(var/obj/item/stock_parts/matter_bin/B in component_parts)
		cooling_speed += B.rating
	for(var/obj/item/stock_parts/micro_laser/L in component_parts)
		power_efficiency += L.rating

/obj/machinery/snow_machine/attack_hand(mob/user)
	if(!powered() || !anchored)
		return
	if(turn_on_or_off(!active))
		to_chat(user, "<span class='notice'>You [active ? "turn on" : "turn off"] [src].</span>")
	return ..()

/obj/machinery/snow_machine/crowbar_act(mob/user, obj/item/I)
	if(default_deconstruction_crowbar(user, I))
		return TRUE

/obj/machinery/snow_machine/screwdriver_act(mob/user, obj/item/I)
	if(default_deconstruction_screwdriver(user, "snow_machine_openpanel", "snow_machine_off", I))
		turn_on_or_off(FALSE)
		return TRUE

/obj/machinery/snow_machine/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	anchored = !anchored
	to_chat(user, "<span class='notice'>You [anchored ? "tighten" : "loosen"] [src]'s wheels.</span>")
	turn_on_or_off(FALSE)

/obj/machinery/snow_machine/process()
	if(power_used_this_cycle)
		power_used_this_cycle /= power_efficiency
		use_power(power_used_this_cycle)
		power_used_this_cycle = 0
	if(!active || !anchored)
		return
	if(!powered())
		return
	if(!reagents.has_reagent(reagents.get_master_reagent_id(), 3))
		return //This means you don't need to top it up constantly to keep the nice snowclouds going
	var/turf/T = get_turf(src)
	if(isspaceturf(T) || T.density) //If the snowmachine is on a dense tile or in space, then it shouldn't be able to produce any snow and so will turn off
		turn_on_or_off(FALSE, TRUE)
		return
	for(var/turf/TF in range(1, src))
		if(issimulatedturf(TF))
			var/turf/simulated/S = TF
			affect_turf_temperature(S, cooling_speed)
		if(prob(50))
			continue
		make_snowcloud(TF)

/obj/machinery/snow_machine/power_change()
	..()
	if(!powered())
		turn_on_or_off(FALSE, TRUE)
	update_icon()

/obj/machinery/snow_machine/update_icon()
	..()
	if(panel_open)
		icon_state = "snow_machine_openpanel"
	else
		icon_state = "snow_machine_[active ? "on" : "off"]"

/obj/machinery/snow_machine/proc/affect_turf_temperature(turf/T, modifier)
	if(!issimulatedturf(T) || T.density)
		return
	var/turf/simulated/S = T
	var/initial_temperature = S.air.temperature
	if(initial_temperature <= lower_temperature_limit) //Can we actually cool this?
		return
	var/old_thermal_energy = S.air.thermal_energy()
	var/amount_cooled = initial_temperature - modifier * 8000 / S.air.heat_capacity()
	S.air.temperature = max(amount_cooled, lower_temperature_limit)
	air_update_turf()
	var/new_thermal_energy = S.air.thermal_energy()
	power_used_this_cycle += (old_thermal_energy - new_thermal_energy) / 100

/obj/machinery/snow_machine/proc/make_snowcloud(turf/T)
	if(isspaceturf(T))
		return
	if(T.density)
		return
	if(issimulatedturf(T))
		var/turf/simulated/S = T
		if(S.air.temperature > T0C + 1)
			return
	if(locate(/obj/effect/snowcloud, T)) //Ice to see you
		return
	if(infinite_snow || !reagents.remove_reagent(reagents.get_master_reagent_id(), 3))
		new /obj/effect/snowcloud(T, src)
		power_used_this_cycle += 1000
		return TRUE

/obj/machinery/snow_machine/proc/turn_on_or_off(activate, give_message = FALSE)
	active = activate ? TRUE : FALSE
	if(!active && give_message)
		visible_message("<span class='warning'>[src] switches off!</span>")
		playsound(loc, 'sound/machines/buzz-sigh.ogg', 50, FALSE)
	update_icon()
	return TRUE
