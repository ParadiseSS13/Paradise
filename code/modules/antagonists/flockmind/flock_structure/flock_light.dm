/obj/machinery/light/floor/has_bulb/flock
	color = "#72bfac"
	light_color = "#72bfac"
	brightness_color = "#72bfac"
	base_state = "flock_floor"
	glow_icon = 'icons/goonstation/objects/lighting.dmi'
	glow_icon_state = "flock_floor"
	nightshift_allowed = FALSE
	no_emergency = TRUE

/obj/machinery/light/floor/has_bulb/flock/try_flock_convert(datum/flock/flock, force)
	return

/obj/machinery/light/floor/has_bulb/get_flock_id()
	return "Light emitter"

/obj/machinery/light/flock
	icon = 'icons/goonstation/objects/lighting.dmi'
	color = "#72bfac"
	light_color = "#72bfac"
	brightness_color = "#72bfac"
	base_state = "flock"
	glow_icon = 'icons/goonstation/objects/lighting.dmi'
	glow_icon_state = "flock"
	nightshift_allowed = FALSE
	no_emergency = TRUE

/obj/machinery/light/flock/try_flock_convert(datum/flock/flock, force)
	return

/obj/machinery/light/flock/get_flock_id()
	return "Light emitter"
