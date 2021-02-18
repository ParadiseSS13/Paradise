/obj/machinery/atmospherics/unary/passive_vent
	icon = 'icons/atmos/vent_pump.dmi'
	icon_state = "map_vent"

	name = "passive vent"
	desc = "A large air vent"

	can_unwrench = 1

	var/volume = 250

/obj/machinery/atmospherics/unary/passive_vent/high_volume
	name = "large passive vent"
	volume = 1000

/obj/machinery/atmospherics/unary/passive_vent/New()
	..()
	air_contents.volume = volume

/obj/machinery/atmospherics/unary/passive_vent/process_atmos()
	..()

	if(!node)
		return 0

	var/datum/gas_mixture/environment = loc.return_air()

	var/pressure_delta = air_contents.return_pressure() - environment.return_pressure()

	// based on pressure_pump to equalize pressure
	// already equalized
	if(abs(pressure_delta) < 0.01)
		return 1

	if(pressure_delta > 0)
		// transfer from pipe air to environment
		if((air_contents.total_moles() > 0) && (air_contents.temperature > 0))
			var/transfer_moles = pressure_delta * environment.volume / (air_contents.temperature * R_IDEAL_GAS_EQUATION)
			transfer_moles = min(transfer_moles, volume)

			var/datum/gas_mixture/removed = air_contents.remove(transfer_moles)
			loc.assume_air(removed)
			air_update_turf()
	else
		// transfer from environment to pipe air
		pressure_delta = -pressure_delta
		if((environment.total_moles() > 0) && (environment.temperature > 0))
			var/transfer_moles = pressure_delta * air_contents.volume / (environment.temperature * R_IDEAL_GAS_EQUATION)
			transfer_moles = min(transfer_moles, volume)

			var/datum/gas_mixture/removed = loc.remove_air(transfer_moles)
			air_contents.merge(removed)
			air_update_turf()

	parent.update = 1
	return 1

/obj/machinery/atmospherics/unary/passive_vent/update_underlays()
	if(..())
		underlays.Cut()
		var/turf/T = get_turf(src)
		if(!istype(T))
			return
		add_underlay(T, node, dir)
