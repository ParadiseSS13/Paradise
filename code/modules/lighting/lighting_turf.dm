// Causes any affecting light sources to be queued for a visibility update, for example a door got opened.
/turf/proc/reconsider_lights()
	lighting_corner_NE?.vis_update()
	lighting_corner_SE?.vis_update()
	lighting_corner_SW?.vis_update()
	lighting_corner_NW?.vis_update()

/turf/proc/lighting_clear_overlay()
	if(lighting_object)
		qdel(lighting_object, force = TRUE)

// Builds a lighting object for us, but only if our area is dynamic.
/turf/proc/lighting_build_overlay()
	if(lighting_object)
		qdel(lighting_object, force = TRUE) // Shitty fix for lighting objects persisting after death

	new /datum/lighting_object(src)

// Used to get a scaled lumcount.
/turf/proc/get_lumcount(minlum = 0, maxlum = 1)
	if(!lighting_object)
		return 1

	var/totallums = 0
	var/datum/lighting_corner/corner
	corner = lighting_corner_NE
	if(corner)
		totallums += corner.lum_r + corner.lum_b + corner.lum_g
	corner = lighting_corner_SE
	if(corner)
		totallums += corner.lum_r + corner.lum_b + corner.lum_g
	corner = lighting_corner_SW
	if(corner)
		totallums += corner.lum_r + corner.lum_b + corner.lum_g
	corner = lighting_corner_NW
	if(corner)
		totallums += corner.lum_r + corner.lum_b + corner.lum_g

	totallums /= 12 // 4 corners, each with 3 channels, get the average.

	totallums = (totallums - minlum) / (maxlum - minlum)

	return CLAMP01(totallums)

// Returns a boolean whether the turf is on soft lighting.
// Soft lighting being the threshold at which point the overlay considers
// itself as too dark to allow sight and see_in_dark becomes useful.
// So basically if this returns true the tile is unlit black.
/turf/proc/is_softly_lit()
	if(!lighting_object)
		return FALSE

	return !luminosity

/// Proc to add movable sources of opacity on the turf and let it handle lighting code.
/turf/proc/add_opacity_source(atom/movable/new_source)
	LAZYADD(opacity_sources, new_source)
	if(opacity)
		return
	recalculate_directional_opacity()

/// Proc to remove movable sources of opacity on the turf and let it handle lighting code.
/turf/proc/remove_opacity_source(atom/movable/old_source)
	LAZYREMOVE(opacity_sources, old_source)
	if(opacity) // Still opaque, no need to worry on updating.
		return
	recalculate_directional_opacity()

/// Calculate on which directions this turfs block view.
/turf/proc/recalculate_directional_opacity()
	. = directional_opacity
	if(opacity)
		directional_opacity = ALL_CARDINALS
		if(. != directional_opacity)
			reconsider_lights()
		return
	directional_opacity = NONE
	for(var/atom/movable/opacity_source in opacity_sources)
		if(opacity_source.flags & ON_BORDER)
			directional_opacity |= opacity_source.dir
		else // If fulltile and opaque, then the whole tile blocks view, no need to continue checking.
			directional_opacity = ALL_CARDINALS
			break
	if(. != directional_opacity && (. == ALL_CARDINALS || directional_opacity == ALL_CARDINALS))
		reconsider_lights() // The lighting system only cares whether the tile is fully concealed from all directions or not.

/turf/proc/change_area(area/old_area, area/new_area)
	if(SSlighting.initialized)
		if(new_area.dynamic_lighting != old_area.dynamic_lighting)
			if(new_area.dynamic_lighting)
				lighting_build_overlay()
			else
				lighting_clear_overlay()
	for(var/obj/machinery/machine in contents)
		machine.reregister_machine()

/turf/proc/generate_missing_corners()
	if(!lighting_corner_NE)
		lighting_corner_NE = new /datum/lighting_corner(src, NORTH | EAST)

	if(!lighting_corner_SE)
		lighting_corner_SE = new /datum/lighting_corner(src, SOUTH | EAST)

	if(!lighting_corner_SW)
		lighting_corner_SW = new /datum/lighting_corner(src, SOUTH | WEST)

	if(!lighting_corner_NW)
		lighting_corner_NW = new /datum/lighting_corner(src, NORTH | WEST)

	lighting_corners_initialised = TRUE
