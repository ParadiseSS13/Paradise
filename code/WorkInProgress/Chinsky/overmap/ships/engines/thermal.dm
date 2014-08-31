//Thermal nozzle engine
/datum/ship_engine/thermal
	name = "thermal engine"

/datum/ship_engine/thermal/get_status()
	..()
	var/obj/machinery/atmospherics/unary/engine/E = engine
	return "Fuel pressure: [E.air_contents.return_pressure()]"

/datum/ship_engine/thermal/get_thrust()
	..()
	var/obj/machinery/atmospherics/unary/engine/E = engine
	if(!is_on())
		return 0
	var/pressurized_coef = E.air_contents.return_pressure()/E.effective_pressure
	return round(E.thrust_limit * E.nominal_thrust * pressurized_coef)

/datum/ship_engine/thermal/burn()
	..()
	var/obj/machinery/atmospherics/unary/engine/E = engine
	return E.burn()

/datum/ship_engine/thermal/set_thrust_limit(var/new_limit)
	..()
	var/obj/machinery/atmospherics/unary/engine/E = engine
	E.thrust_limit = new_limit

/datum/ship_engine/thermal/get_thrust_limit()
	..()
	var/obj/machinery/atmospherics/unary/engine/E = engine
	return E.thrust_limit

/datum/ship_engine/thermal/is_on()
	..()
	var/obj/machinery/atmospherics/unary/engine/E = engine
	return E.on

/datum/ship_engine/thermal/toggle()
	..()
	var/obj/machinery/atmospherics/unary/engine/E = engine
	E.on = !E.on

//Actual thermal nozzle engine object

/obj/machinery/atmospherics/unary/engine
	name = "engine nozzle"
	desc = "Simple thermal nozzle, uses heated gast to propell the ship."
	icon = 'icons/obj/ship_engine.dmi'
	icon_state = "nozzle"
	var/on = 1
	var/thrust_limit = 1	//Value between 1 and 0 to limit the resulting thrust
	var/nominal_thrust = 3000
	var/effective_pressure = 3000
	var/datum/ship_engine/thermal/controller

/obj/machinery/atmospherics/unary/engine/initialize()
	..()
	controller = new(src)

/obj/machinery/atmospherics/unary/engine/Del()
	..()
	controller.die()

/obj/machinery/atmospherics/unary/engine/proc/burn()
	if (!on)
		return
	if(air_contents.temperature > 0)
		var/transfer_moles = 100  * air_contents.volume/max(air_contents.temperature * R_IDEAL_GAS_EQUATION, 0,01)
		transfer_moles = round(thrust_limit * transfer_moles, 0.01)
		if(transfer_moles > air_contents.total_moles)
			on = !on
			return 0

		var/datum/gas_mixture/removed = air_contents.remove(transfer_moles)

		loc.assume_air(removed)
		if(air_contents.temperature > PHORON_MINIMUM_BURN_TEMPERATURE)
			var/exhaust_dir = reverse_direction(dir)
			var/turf/T = get_step(src,exhaust_dir)
			if(T)
				new/obj/effect/engine_exhaust(T,exhaust_dir,air_contents.temperature)
		return 1

//Exhaust effect
/obj/effect/engine_exhaust
	name = "engine exhaust"
	icon = 'icons/effects/effects.dmi'
	icon_state = "exhaust"
	anchored = 1

	New(var/turf/nloc, var/ndir, var/temp)
		dir = ndir
		..(nloc)

		if(nloc)
			nloc.hotspot_expose(temp,125)

		spawn(20)
			loc = null