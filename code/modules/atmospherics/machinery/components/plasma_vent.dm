
/obj/machinery/atmospherics/plasmavent
	name = "Plasma Vent"
	desc = "A spire of basalt rock, erupting with bubbling molten plasma. It constantly emits toxic fumes."
	anchored = TRUE
	icon = 'icons/obj/atmospherics/plasma_vent.dmi'
	icon_state = "plasma_vent"

/obj/machinery/atmospherics/plasmavent/process_atmos()
	var/datum/milla_safe/plasmavent/milla = new()
	milla.invoke_async(src)

/datum/milla_safe/plasmavent

/datum/milla_safe/plasmavent/on_run()
	var/max_plasma = ONE_ATMOSPHERE
	var/turf/T = get_turf(src)
	var/datum/gas_mixture/environment = get_turf_air(T)
	var/datum/gas_mixture/add_moles = new
	var/environment_pressure = environment.return_pressure()
	var/pressure_delta = min(max_plasma - environment_pressure, (max_plasma - environment_pressure) / 2)

	//only add gas if below max_plasma
	to_chat(world,"Checking For Pressure")
	if (environment_pressure <= max_plasma)
		to_chat(world, "Pressure Check: Adding plasma")
		add_moles.set_toxins(pressure_delta * environment_pressure / (R_IDEAL_GAS_EQUATION))
		add_moles.set_agent_b((pressure_delta * environment_pressure / (R_IDEAL_GAS_EQUATION)) / 100)
		environment.merge(add_moles)
	else
		to_chat(world, "pressure check: Over pressure")
		return
