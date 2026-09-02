#define RADIATION_CAPACITY 30000 //Radiation isn't particularly effective (TODO BALANCE)
/obj/machinery/atmospherics/unary/thermal_plate
//Based off Heat Reservoir and Space Heater
//Transfers heat between a pipe system and environment, based on which has a greater thermal energy concentration
	icon = 'icons/obj/atmospherics/cold_sink.dmi'
	icon_state = "off"

	can_unwrench = TRUE

	name = "thermal tansfer plate"
	desc = "Transfers heat to and from an area."

/obj/machinery/atmospherics/unary/thermal_plate/update_icon_state()
	var/prefix = ""
	//var/suffix="_idle" // Also available: _heat, _cool
	if(level == 1 && issimulatedturf(loc))
		prefix = "h"
	icon_state = "[prefix]off"

/obj/machinery/atmospherics/unary/thermal_plate/process_atmos()
	var/datum/milla_safe/thermal_plate_process/milla = new()
	milla.invoke_async(src)

/datum/milla_safe/thermal_plate_process

/datum/milla_safe/thermal_plate_process/on_run(obj/machinery/atmospherics/unary/thermal_plate/plate)
	var/turf/T = get_turf(plate)
	var/datum/gas_mixture/environment = get_turf_air(T)

	//Get processable air sample and thermal info from environment

	var/transfer_moles = 0.25 * environment.total_moles()
	var/datum/gas_mixture/external_removed = environment.remove(transfer_moles)

	if(!external_removed)
		return plate.radiate()

	if(external_removed.total_moles() < 10)
		return plate.radiate()

	//Get same info from connected gas

	var/internal_transfer_moles = 0.25 * plate.air_contents.total_moles()
	var/datum/gas_mixture/internal_removed = plate.air_contents.remove(internal_transfer_moles)

	if(!internal_removed)
		environment.merge(external_removed)
		return 1

	var/combined_heat_capacity = internal_removed.heat_capacity() + external_removed.heat_capacity()
	var/combined_energy = internal_removed.temperature() * internal_removed.heat_capacity() + external_removed.heat_capacity() * external_removed.temperature()

	if(!combined_heat_capacity) combined_heat_capacity = 1
	var/final_temperature = combined_energy / combined_heat_capacity

	external_removed.set_temperature(final_temperature)
	environment.merge(external_removed)

	internal_removed.set_temperature(final_temperature)
	plate.air_contents.merge(internal_removed)

	plate.parent.update = 1

	return 1

/obj/machinery/atmospherics/unary/thermal_plate/proc/radiate()
	var/internal_transfer_moles = 0.25 * air_contents.total_moles()
	var/datum/gas_mixture/internal_removed = air_contents.remove(internal_transfer_moles)

	if(!internal_removed)
		return 1

	var/combined_heat_capacity = internal_removed.heat_capacity() + RADIATION_CAPACITY
	var/combined_energy = internal_removed.temperature() * internal_removed.heat_capacity() + (RADIATION_CAPACITY * 6.4)

	var/final_temperature = combined_energy / combined_heat_capacity

	internal_removed.set_temperature(final_temperature)
	air_contents.merge(internal_removed)

	parent.update = 1

	return 1

#undef RADIATION_CAPACITY
