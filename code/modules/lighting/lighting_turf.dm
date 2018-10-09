/turf
	var/dynamic_lighting = DYNAMIC_LIGHTING_ENABLED
	luminosity           = 1

	var/tmp/lighting_corners_initialised = FALSE

	var/tmp/list/datum/light_source/affecting_lights       // List of light sources affecting this turf.
	var/tmp/atom/movable/lighting_overlay/lighting_overlay // Our lighting overlay.
	var/tmp/list/datum/lighting_corner/corners
	var/tmp/has_opaque_atom = FALSE // Not to be confused with opacity, this will be TRUE if there's any opaque atom on the tile.

/turf/New()
	. = ..()

	if(opacity)
		has_opaque_atom = TRUE

// Causes any affecting light sources to be queued for a visibility update, for example a door got opened.
/turf/proc/reconsider_lights()
	var/datum/light_source/L
	var/thing
	for(thing in affecting_lights)
		L = thing
		L.vis_update()

/turf/proc/lighting_clear_overlay()
	if (lighting_overlay)
		qdel(lighting_overlay, TRUE)

	var/datum/lighting_corner/C
	var/thing
	for (thing in corners)
		if(!thing)
			continue
		C = thing
		C.update_active()

// Builds a lighting overlay for us, but only if our area is dynamic.
/turf/proc/lighting_build_overlay()
	if(lighting_overlay)
		return

	var/area/A = loc
	if(A.dynamic_lighting)
		if(!lighting_corners_initialised)
			generate_missing_corners()

		new /atom/movable/lighting_overlay(src)

		for(var/datum/lighting_corner/C in corners)
			if(!C.active) // We would activate the corner, calculate the lighting for it.
				for(var/L in C.affecting)
					var/datum/light_source/S = L
					S.recalc_corner(C)

				C.active = TRUE

// Used to get a scaled lumcount.
/turf/proc/get_lumcount(var/minlum = 0, var/maxlum = 1)
	if(!lighting_overlay)
		return 1

	var/totallums = 0
	var/thing
	var/datum/lighting_corner/L
	for (thing in corners)
		if(!thing)
			continue
		L = thing
		totallums += L.lum_r + L.lum_b + L.lum_g

	totallums /= 12 // 4 corners, each with 3 channels, get the average.

	totallums =(totallums - minlum) /(maxlum - minlum)

	return CLAMP01(totallums)

// Returns a boolean whether the turf is on soft lighting.
// Soft lighting being the threshold at which point the overlay considers
// itself as too dark to allow sight and see_in_dark becomes useful.
// So basically if this returns true the tile is unlit black.
/turf/proc/is_softly_lit()
	if (!lighting_overlay)
		return FALSE

	return !lighting_overlay.luminosity

// Can't think of a good name, this proc will recalculate the has_opaque_atom variable.
/turf/proc/recalc_atom_opacity()
	has_opaque_atom = opacity
	if(!has_opaque_atom)
		for(var/atom/A in src.contents) // Loop through every movable atom on our tile PLUS ourselves (we matter too...)
			if(A.opacity)
				has_opaque_atom = TRUE
				break

// If an opaque movable atom moves around we need to potentially update visibility.
/turf/Entered(var/atom/movable/Obj, var/atom/OldLoc)
	. = ..()

	if(Obj && Obj.opacity)
		has_opaque_atom = TRUE // Make sure to do this before reconsider_lights(), incase we're on instant updates. Guaranteed to be on in this case.
		reconsider_lights()

/turf/Exited(var/atom/movable/Obj, var/atom/newloc)
	. = ..()

	if(Obj && Obj.opacity)
		recalc_atom_opacity() // Make sure to do this before reconsider_lights(), incase we're on instant updates.
		reconsider_lights()

/turf/proc/get_corners()
	if(has_opaque_atom)
		return null // Since this proc gets used in a for loop, null won't be looped though.

	return corners

/turf/proc/generate_missing_corners()
	lighting_corners_initialised = TRUE
	if(!corners)
		corners = list(null, null, null, null)

	for(var/i = 1 to 4)
		if(corners[i]) // Already have a corner on this direction.
			continue

		corners[i] = new /datum/lighting_corner(src, LIGHTING_CORNER_DIAGONAL[i])
