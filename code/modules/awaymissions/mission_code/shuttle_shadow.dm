/obj/machinery/atmospherics/unary/passive_vent/high_volume/shadow

/obj/machinery/atmospherics/unary/passive_vent/high_volume/shadow/process_atmos()
	if(!on)
		return
	..()

/obj/machinery/atmospherics/unary/passive_vent/high_volume/shadow/on_changed_z_level(turf/old_turf, turf/new_turf)
	. = ..()
	if(is_station_level(new_turf?.z))
		on = TRUE

/obj/machinery/atmospherics/trinary/filter/shadow
	name = "gas filter (Co2 Outlet)"
	dir = 1
	filter_type = 3
	target_pressure = 99999

/obj/machinery/atmospherics/trinary/filter/shadow/on_changed_z_level(turf/old_turf, turf/new_turf)
	. = ..()
	if(is_station_level(new_turf?.z))
		on = TRUE

/obj/machinery/igniter/shadow

/obj/machinery/igniter/shadow/on_changed_z_level(turf/old_turf, turf/new_turf)
	. = ..()
	if(is_station_level(new_turf?.z))
		on = TRUE
		update_icon()
