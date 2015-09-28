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

/obj/machinery/atmospherics/unary/passive_vent/process()
	..()
	
	if(!node)
		return

	var/datum/gas_mixture/removed = air_contents.remove(volume)
	loc.assume_air(removed)	
	air_update_turf()

/obj/machinery/atmospherics/unary/passive_vent/update_underlays()
	if(..())
		underlays.Cut()
		var/turf/T = get_turf(src)
		if(!istype(T))
			return
		add_underlay(T, node, dir)
