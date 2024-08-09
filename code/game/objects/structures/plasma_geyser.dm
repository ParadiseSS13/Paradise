
/obj/structures/plasmageyser
	name = "Plasma Vent"
	desc = "A mound of basalt rock, erupting with bubbling molten plasma. It constantly emits toxic fumes."
	anchored = TRUE
	icon = 'icons/obj/lavaland/geyser.dmi'
	icon_state = "geyser_plasma"
	resistance_flags = LAVA_PROOF | FIRE_PROOF
	armor = list(MELEE = 30, BULLET = 80, LASER = 90, ENERGY = 90, BOMB = 80, RAD = 100, FIRE = 100, ACID = 100)

/obj/structures/plasmageyser/Initialize()
	START_PROCESSING(SSprocessing, src)
	. = ..()

// for sanity checks
/obj/structures/plasmageyser/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	. = ..()

/obj/structures/plasmageyser/process()
	var/datum/milla_safe/plasmageyser/milla = new()
	milla.invoke_async(src)

/datum/milla_safe/plasmageyser

/datum/milla_safe/plasmageyser/on_run(obj/structures/plasmageyser/tile)
	var/max_pressure = ONE_ATMOSPHERE * 3
	var/toxins_modifier = 100
	var/agentb_modifier = 1
	var/target_temp = 1000
	var/turf/T = get_turf(tile)
	var/datum/gas_mixture/environment = get_turf_air(T)
	var/datum/gas_mixture/add_moles = new()
	var/environment_pressure = environment.return_pressure()

	// adds gas and agent B to the environment if below max_pressure
	if(environment_pressure >= max_pressure)
		return
	add_moles.set_agent_b(agentb_modifier)
	add_moles.set_toxins(toxins_modifier)
	add_moles.set_temperature(target_temp)
	environment.merge(add_moles)
