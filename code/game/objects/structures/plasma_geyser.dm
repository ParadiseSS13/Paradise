
/obj/structures/plasmageyser
	name = "Plasma Vent"
	desc = "A spire of basalt rock, erupting with bubbling molten plasma. It constantly emits toxic fumes."
	anchored = TRUE
	icon = 'icons/obj/atmospherics/plasma_vent.dmi'
	icon_state = "plasma_vent"
	resistance_flags = LAVA_PROOF | FIRE_PROOF
	armor = list(MELEE = 60, BULLET = 80, LASER = 30, ENERGY = 30, BOMB = 60, RAD = 70, FIRE = 100, ACID = 100)

/obj/structures/plasmageyser/Initialize()
	START_PROCESSING(SSprocessing, src)
	. = ..()

//sanity checks
/obj/structures/plasmageyser/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	. = ..()

/obj/structures/plasmageyser/process()
	var/datum/milla_safe/plasmageyser/milla = new()
	milla.invoke_async(src)

/datum/milla_safe/plasmageyser

/datum/milla_safe/plasmageyser/on_run(obj/structures/plasmageyser/tile)
	var/max_plasma = ONE_ATMOSPHERE * 3
	var/toxins_modifier = 100
	var/agentb_modifier = 1
	var/turf/T = get_turf(tile)
	var/datum/gas_mixture/environment = get_turf_air(T)
	var/datum/gas_mixture/add_moles = new()
	var/environment_pressure = environment.return_pressure()
	//var/environment_temp = environment.temperature()
	//var/pressure_delta = min(max_plasma - environment_pressure, (max_plasma - environment_pressure))

	//adds gas and agent B to the environment
	if (environment_pressure >= max_plasma)
		return
	else
		add_moles.set_agent_b(agentb_modifier)
		add_moles.set_toxins(toxins_modifier)
		add_moles.set_temperature(500)
		environment.merge(add_moles)
