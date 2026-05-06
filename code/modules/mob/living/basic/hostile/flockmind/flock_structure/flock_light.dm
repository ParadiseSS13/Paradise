/obj/machinery/light/floor/has_bulb/flock
	light_color = "#72bfac"
	use_power = NO_POWER_USE

	base_state = "flock_floor"
	start_with_cell = FALSE
	removable_bulb = FALSE

/obj/machinery/light/floor/has_bulb/flock/try_flock_convert(datum/flock/flock, force)
	return

/obj/machinery/light/floor/has_bulb/get_flock_id()
	return "Light emitter"

/obj/machinery/light/flock
	icon = 'goon/icons/obj/lighting.dmi'

	light_color = "#72bfac"
	use_power = NO_POWER_USE

	base_state = "flock"
	start_with_cell = FALSE
	removable_bulb = FALSE

/obj/machinery/light/flock/try_flock_convert(datum/flock/flock, force)
	return

/obj/machinery/light/flock/get_flock_id()
	return "Light emitter"
