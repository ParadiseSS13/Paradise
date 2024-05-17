/obj/machinery/atmospherics/unary/passive_vent/high_volume/shadow
	on = FALSE

/obj/machinery/atmospherics/unary/passive_vent/high_volume/shadow/process_atmos()
	if(!on)
		return
	..()

/obj/machinery/atmospherics/unary/passive_vent/high_volume/shadow/onTransitZ(old_z, new_z)
	. = ..()
	if(is_station_level(new_z))
		on = TRUE

/obj/machinery/atmospherics/trinary/filter/shadow
	name = "gas filter (Co2 Outlet)"
	dir = 1
	filter_type = 3
	on = FALSE
	target_pressure = 99999

/obj/machinery/atmospherics/trinary/filter/shadow/onTransitZ(old_z, new_z)
	. = ..()
	if(is_station_level(new_z))
		on = TRUE

/obj/machinery/igniter/shadow

/obj/machinery/igniter/shadow/onTransitZ(old_z, new_z)
	. = ..()
	if(is_station_level(new_z))
		on = TRUE
		update_icon()
