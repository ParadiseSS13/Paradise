/// Exterior lights use the powernet of the wall they're installed on,
/// not the tile they're placed on. This allows them to be in a different
/// area than the area that powers them, making it possible to have a light
/// "outside" a structure that shares its power state.
/obj/machinery/light/exterior

/obj/machinery/light/exterior/Initialize(mapload)
	. = ..()

	reregister_machine()

/// Returns the area of the wall this light is mounted on, which is the area that powers it. Can return null if the light is mounted against the edge of the map.
/obj/machinery/light/exterior/proc/get_mounted_area()
	return get_area(get_step(src, dir))

/obj/machinery/light/exterior/reregister_machine()
	var/area/machine_area = get_mounted_area()
	if(!machine_area)
		log_debug("Exterior light [src] target mounted area returned NULL, local powernet could not be established.")
		return

	if(machine_powernet?.powernet_area == machine_area)
		return

	// The mounted area is not our own, so it may not have initialized yet and may not have a powernet
	// to register to. Local powernets are created on demand, so make one rather than waiting on the area.
	// see Machinery/Initialize() for how that is handled for most machinery
	var/datum/local_powernet/mounted_powernet = machine_area.powernet || machine_area.create_powernet()

	var/old_power_mode = power_state
	change_power_mode(NO_POWER_USE) // Take away our current power from the old network
	machine_powernet?.unregister_machine(src)
	mounted_powernet.register_machine(src)
	change_power_mode(old_power_mode) // add it to the new network

/obj/machinery/light/exterior/power_change()
	var/area/machine_area = get_mounted_area()
	if(!machine_area)
		return

	// This runs during Initialize() by way of the parent call, before reregister_machine() has had the
	// chance to build the mounted area's powernet. register_machine() calls us again once it has.
	var/datum/local_powernet/mounted_powernet = machine_area.powernet
	if(!mounted_powernet)
		return

	seton(machine_area.lightswitch && mounted_powernet.has_power(PW_CHANNEL_LIGHTING))

/obj/machinery/light/exterior/has_power()
	var/area/machine_area = get_mounted_area()
	if(!machine_area?.powernet)
		return FALSE
	return machine_area.lightswitch && machine_area.powernet.has_power(PW_CHANNEL_LIGHTING)

/obj/machinery/light/exterior/turned_off()
	var/area/machine_area = get_mounted_area()
	if(!machine_area?.powernet)
		return FALSE
	return !machine_area.lightswitch && machine_area.powernet.has_power(PW_CHANNEL_LIGHTING)

/obj/machinery/light/exterior/outdoors
	brightness_color = "#facd7f"
	nightshift_light_color = "#facd7f"

/obj/machinery/light/exterior/warning
	brightness_color = COLOR_RED_LIGHT
	nightshift_light_color = COLOR_RED_LIGHT
