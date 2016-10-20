/atom
	var/light_power = 1 // intensity of the light
	var/light_range = 0 // range in tiles of the light
	var/light_color		// Hexadecimal RGB string representing the colour of the light

	var/datum/light_source/light
	var/list/light_sources

/atom/proc/set_light(l_range, l_power, l_color)
	if(l_power != null)
		light_power = l_power
	if(l_range != null)
		light_range = l_range
	if(l_color != null)
		light_color = l_color

	update_light()

/atom/proc/update_light()
	set waitfor = FALSE

	if(!global.lighting_corners_initialised)
		sleep(20)

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
			light = new/datum/light_source(src, .)

/atom/New()
	. = ..()
	if(light_power && light_range)
		update_light()

/atom/Destroy()
	if(light)
		light.destroy()
		light = null

	if(opacity && isturf(loc))
		var/turf/T = loc
		T.has_opaque_atom = TRUE // No need to recalculate it in this case, it's guaranteed to be on afterwards anyways.

	. = ..()


/atom/movable/Destroy()
	var/turf/T = loc
	if(opacity && istype(T))
		T.reconsider_lights()
	. = ..()

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

/atom/proc/set_opacity(var/new_opacity)
	var/old_opacity = opacity
	opacity = new_opacity
	var/turf/T = loc
	if(old_opacity != new_opacity && istype(T))
		T.reconsider_lights()

// This code makes the light be queued for update when it is moved.
// Entered() should handle it, however Exited() can do it if it is being moved to nullspace (as there would be no Entered() call in that situation).
/atom/Entered(var/atom/movable/Obj, var/atom/OldLoc) //Implemented here because forceMove() doesn't call Move()
	. = ..()

	if (Obj && OldLoc != src)
		for (var/datum/light_source/L in Obj.light_sources) // Cycle through the light sources on this atom and tell them to update.
			L.source_atom.update_light()

/atom/Exited(var/atom/movable/Obj, var/atom/newloc)
	. = ..()

	if (!newloc && Obj && newloc != src) // Incase the atom is being moved to nullspace, we handle queuing for a lighting update here.
		for (var/datum/light_source/L in Obj.light_sources) // Cycle through the light sources on this atom and tell them to update.
			L.source_atom.update_light()

/obj/item/equipped()
	. = ..()
	update_light()

/obj/item/pickup()
	. = ..()
	update_light()

/obj/item/dropped()
	. = ..()
	update_light()
