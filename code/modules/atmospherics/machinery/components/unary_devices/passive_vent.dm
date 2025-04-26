/obj/machinery/atmospherics/unary/passive_vent
	icon = 'icons/atmos/vent_pump.dmi'
	icon_state = "map_vent"
	plane = FLOOR_PLANE
	layer = GAS_PIPE_VISIBLE_LAYER + 0.004
	layer_offset = 0.004
	name = "passive vent"
	desc = "A large air vent."

	can_unwrench = TRUE

	var/volume = 250

/obj/machinery/atmospherics/unary/passive_vent/high_volume
	name = "large passive vent"
	volume = 1000

/obj/machinery/atmospherics/unary/passive_vent/Initialize(mapload)
	. = ..()
	air_contents.volume = volume

/obj/machinery/atmospherics/unary/passive_vent/process_atmos()
	var/datum/milla_safe/passive_vent_processing/milla = new()
	milla.invoke_async(src)

/datum/milla_safe/passive_vent_processing

/datum/milla_safe/passive_vent_processing/on_run(obj/machinery/atmospherics/unary/passive_vent/vent)
	if(!vent.node)
		return FALSE

	var/turf/T = get_turf(vent)
	if(T.density) //No, you should not be able to get free air from walls
		return
	var/datum/gas_mixture/environment = get_turf_air(T)

	var/pressure_delta = vent.air_contents.return_pressure() - environment.return_pressure()

	// based on pressure_pump to equalize pressure
	// already equalized
	if(abs(pressure_delta) < 0.01)
		return 1

	if(pressure_delta > 0)
		// transfer from pipe air to environment
		if((vent.air_contents.total_moles() > 0) && (vent.air_contents.temperature() > 0))
			var/transfer_moles = pressure_delta * vent.air_contents.volume / (vent.air_contents.temperature() * R_IDEAL_GAS_EQUATION)
			transfer_moles = min(transfer_moles, vent.volume)

			var/datum/gas_mixture/removed = vent.air_contents.remove(transfer_moles)
			environment.merge(removed)
	else
		// transfer from environment to pipe air
		pressure_delta = -pressure_delta
		if((environment.total_moles() > 0) && (environment.temperature() > 0))
			var/transfer_moles = pressure_delta * vent.air_contents.volume / (environment.temperature() * R_IDEAL_GAS_EQUATION)
			transfer_moles = min(transfer_moles, vent.volume)

			var/datum/gas_mixture/removed = environment.remove(transfer_moles)
			vent.air_contents.merge(removed)

	vent.parent.update = 1
	return 1

/obj/machinery/atmospherics/unary/passive_vent/update_underlays()
	if(..())
		underlays.Cut()
		var/turf/T = get_turf(src)
		if(!istype(T))
			return
		add_underlay(T, node, dir)
		var/icon/frame = icon('icons/atmos/vent_pump.dmi', "frame")
		underlays += frame
