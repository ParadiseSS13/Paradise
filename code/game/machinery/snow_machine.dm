/obj/machinery/snow_machine
	name = "snow machine"
	desc = "Carol singers not included."
	icon_state = "snow_machine"
	density = TRUE
	anchored = TRUE
	layer = LOW_OBJ_LAYER
	var/active = FALSE
	var/power_used_this_cycle = 0
	var/cooling_speed = 1
	var/power_efficiency = 1
	var/lower_temperature_limit = T0C - 10 //Set lower for a bigger freeze
	var/list/allowed_reagents = list("water", "holywater", "unholywater") //So it will accept "all" waters

/obj/machinery/snow_machine/New()
	..()
	create_reagents(300) //Makes 100 snow tiles!
	reagents.add_reagent("water", 300)
	container_type = REFILLABLE
	component_parts = list()
	component_parts += new /obj/item/circuitboard/snow_machine(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	RefreshParts()

/obj/machinery/snow_machine/examine(mob/user)
	..()
	to_chat(user, "<span class='notice'>The water level indicator displays it is [round(reagents.total_volume / reagents.maximum_volume * 100)]% full.</span>")

/obj/machinery/snow_machine/RefreshParts()
	power_efficiency = 0
	cooling_speed = 0
	for(var/obj/item/stock_parts/matter_bin/B in component_parts)
		cooling_speed += B.rating
	for(var/obj/item/stock_parts/micro_laser/L in component_parts)
		power_efficiency += L.rating

/obj/machinery/snow_machine/attack_hand(mob/user)
	if(turn_on_or_off(!active))
		to_chat(user, "<span class='notice'>You [active ? "turn on" : "turn off"] [src].</span>")
	return ..()

/obj/machinery/snow_machine/attackby(obj/item/I, mob/user)
	if(isscrewdriver(I))
		default_deconstruction_screwdriver(user, icon_state, icon_state, I)
		return
	if(iscrowbar(I))
		default_deconstruction_crowbar(I)
		return
	if(iswrench(I))
		anchored = !anchored
		to_chat(user, "<span class='notice'>You [anchored ? "wrench" : "unwrench"] [src].</span>")
		return
	if(istype(I, /obj/item/reagent_containers/glass))
		var/obj/item/reagent_containers/glass/beaker/G = I
		for(var/datum/reagent/R in G.reagents)
			if(R.id in allowed_reagents)
				continue
			to_chat(user, "<span class='notice'>[src] only accepts water!</span>")
			return
	return ..()

/obj/machinery/snow_machine/process()
	if(power_used_this_cycle)
		power_used_this_cycle /= power_efficiency
		use_power(power_used_this_cycle)
		power_used_this_cycle = 0
	if(!active || !anchored)
		return
	if(stat & NOPOWER)
		to_chat(world, "uh oh")
		return
	if(!reagents.has_reagent("water", 3))
		turn_on_or_off(FALSE, TRUE)
		return
	var/turf/T = get_turf(src)
	if(!issimulatedturf(T) || T.density) //If the snowmachine is on a dense tile or unsimulated turf, then it shouldn't be able to produce any snow and so will turn off
		turn_on_or_off(FALSE, TRUE)
		return
	for(var/turf/simulated/ST in range(1, src))
		affect_turf_temperature(ST, cooling_speed)
		if(prob(50))
			continue
		make_snowcloud(ST)

/obj/machinery/snow_machine/power_change()
	..()
	if(!stat & NOPOWER)
		if(active)
			turn_on_or_off(FALSE, TRUE)

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
	if(!issimulatedturf(T))
		return
	var/turf/simulated/S = T
	if(S.density)
		return
	if(S.air.temperature > T0C + 1)
		return
	if(locate(/obj/effect/snowcloud, S)) //Ice to see you
		return
	if(!reagents.remove_reagent("water", 3))
		new /obj/effect/snowcloud(S, src)
		power_used_this_cycle += 1000
		return TRUE

/obj/machinery/snow_machine/proc/turn_on_or_off(activate, give_message = FALSE)
	active = activate ? TRUE : FALSE
	if(!active && give_message)
		visible_message("<span class='warning'>[src] switches off!</span>")
	return TRUE
