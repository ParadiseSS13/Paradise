/// Exterior lights use the powernet of the wall they're installed on,
/// not the tile they're placed on. This allows them to be in a different
/// area than the area that powers them, making it possible to have a light
/// "outside" a structure that shares its power state.
/obj/machinery/light/exterior

/obj/machinery/light/exterior/Initialize(mapload)
	. = ..()

	reregister_machine()

/obj/machinery/light/exterior/reregister_machine()
	var/turf/mounted = get_step(src, dir)
	var/area/machine_area = get_area(mounted)

	if(machine_powernet?.powernet_area != machine_area)
		if(machine_area)
			var/old_power_mode = power_state
			change_power_mode(NO_POWER_USE) // Take away our current power from the old network
			machine_powernet?.unregister_machine(src)
			machine_powernet = machine_area.powernet
			machine_powernet.register_machine(src)
			change_power_mode(old_power_mode) // add it to the new network

/obj/machinery/light/exterior/power_change()
	var/turf/mounted = get_step(src, dir)
	var/area/machine_area = get_area(mounted)

	if(machine_area)
		seton(machine_area.lightswitch && machine_area.powernet.has_power(PW_CHANNEL_LIGHTING))

/obj/machinery/light/exterior/outdoors
	brightness_color = "#facd7f"
	nightshift_light_color = "#facd7f"

/obj/machinery/light/exterior/warning
	brightness_color = COLOR_RED_LIGHT
	nightshift_light_color = COLOR_RED_LIGHT
