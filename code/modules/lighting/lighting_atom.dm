/atom
	var/light_power = 1 // intensity of the light
	var/light_range = 0 // range in tiles of the light
	var/light_color		// Hexadecimal RGB string representing the colour of the light

	var/datum/light_source/light
	var/list/light_sources

// Nonsensical value for l_color default, so we can detect if it gets set to null.
#define NONSENSICAL_VALUE -99999
/atom/proc/set_light(l_range, l_power, l_color = NONSENSICAL_VALUE)
	if(l_power != null)
		light_power = l_power

	if(l_range != null)
		light_range = l_range

	if(l_color != NONSENSICAL_VALUE)
		light_color = l_color

	update_light()

#undef NONSENSICAL_VALUE

/atom/proc/update_light()
	set waitfor = FALSE

	if(!light_power || !light_range)
		if(light)
			light.destroy()
			light = null
	else
		if(!istype(loc, /atom/movable))
			. = src
		else
			. = loc

		if(light)
			light.update(.)
		else
			light = new /datum/light_source(src, .)

/atom/proc/extinguish_light()
	return

/atom/Destroy()
	if(light)
		light.destroy()
		light = null
	return ..()

/atom/movable/Destroy()
	var/turf/T = loc
	if(opacity && istype(T))
		T.reconsider_lights()
	return ..()

/atom/movable/Move()
	var/turf/old_loc = loc
	. = ..()

	if(loc != old_loc)
		for(var/datum/light_source/L in light_sources)
			L.source_atom.update_light()

	var/turf/new_loc = loc
	if(istype(old_loc) && opacity)
		old_loc.reconsider_lights()

	if(istype(new_loc) && opacity)
		new_loc.reconsider_lights()

/atom/proc/set_opacity(new_opacity)
	if(new_opacity == opacity)
		return

	opacity = new_opacity
	var/turf/T = loc
	if(!isturf(T))
		return

	if(new_opacity == TRUE)
		T.has_opaque_atom = TRUE
		T.reconsider_lights()
	else
		var/old_has_opaque_atom = T.has_opaque_atom
		T.recalc_atom_opacity()
		if(old_has_opaque_atom != T.has_opaque_atom)
			T.reconsider_lights()

/obj/item/equipped()
	. = ..()
	update_light()

/obj/item/pickup()
	. = ..()
	update_light()

/obj/item/dropped()
	. = ..()
	update_light()
