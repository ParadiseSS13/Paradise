
/obj/structure/plasmageyser
	name = "Plasma Geyser"
	desc = "A mound of basalt rock, erupting with bubbling molten plasma. It constantly emits toxic fumes."
	anchored = TRUE
	icon = 'icons/obj/lavaland/geyser.dmi'
	icon_state = "geyser_plasma"
	resistance_flags = LAVA_PROOF | FIRE_PROOF
	armor = list(MELEE = 30, BULLET = 80, LASER = 90, ENERGY = 90, BOMB = 80, RAD = 100, FIRE = 100, ACID = 100)

/obj/structure/plasmageyser/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSprocessing, src)

// for sanity checks
/obj/structure/plasmageyser/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	return ..()

/obj/structure/plasmageyser/process()
	var/datum/milla_safe/plasmageyser/milla = new()
	milla.invoke_async(src)

/datum/milla_safe/plasmageyser

/datum/milla_safe/plasmageyser/on_run(obj/structure/plasmageyser/geyser)
	var/max_pressure = ONE_ATMOSPHERE * 3
	var/toxins_modifier = 100
	var/co2_modifier = 12
	var/target_temp = 1000
	var/pressure_modifier
	var/turf/T = get_turf(geyser)
	var/datum/gas_mixture/environment = get_turf_air(T)
	var/datum/gas_mixture/add_moles = new()
	var/environment_pressure = environment.return_pressure()

	// Reduces geyser effectiveness when above max_pressure
	if(environment_pressure >= max_pressure)
		pressure_modifier = 0.1
	else
		pressure_modifier = 1

	add_moles.set_toxins(toxins_modifier * pressure_modifier)
	add_moles.set_carbon_dioxide(co2_modifier * pressure_modifier)
	add_moles.set_temperature(target_temp)
	environment.merge(add_moles)
