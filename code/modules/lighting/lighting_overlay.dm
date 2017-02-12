/var/list/all_lighting_overlays = list() // Global list of lighting overlays.
/atom/movable/lighting_overlay
	name = ""
	mouse_opacity = 0
	simulated = 0
	anchored = 1
	icon = LIGHTING_ICON
	layer = LIGHTING_LAYER
	invisibility = INVISIBILITY_LIGHTING
	color = LIGHTING_BASE_MATRIX
	icon_state = "light1"
	auto_init = 0 // doesn't need special init
	blend_mode = BLEND_MULTIPLY

	var/lum_r = 0
	var/lum_g = 0
	var/lum_b = 0

	var/needs_update = FALSE
	var/wa = FALSE

/atom/movable/lighting_overlay/New(var/atom/loc, var/no_update = FALSE)
	. = ..()
	verbs.Cut()
	global.all_lighting_overlays += src

	var/turf/T = loc //If this runtimes atleast we'll know what's creating overlays outside of turfs.
	T.lighting_overlay = src
	T.luminosity = 0
	if(no_update)
		return
	update_overlay()

/atom/movable/lighting_overlay/proc/update_overlay()
	var/turf/T = loc
	if(!istype(T)) // Erm...
		if(loc)
			warning("A lighting overlay realised its loc was NOT a turf (actual loc: [loc], [loc.type]) in update_overlay() and got pooled!")
		else
			warning("A lighting overlay realised it was in nullspace in update_overlay() and got pooled!")
		qdel(src)
	// To the future coder who sees this and thinks
	// "Why didn't he just use a loop?"
	// Well my man, it's because the loop performed like shit.
	// And there's no way to improve it because
	// without a loop you can make the list all at once which is the fastest you're gonna get.
	// Oh it's also shorter line wise.
	// Including with these comments.

	// See LIGHTING_CORNER_DIAGONAL in lighting_corner.dm for why these values are what they are.
	// No I seriously cannot think of a more efficient method, fuck off Comic.
	var/datum/lighting_corner/cr  = T.corners[3] || dummy_lighting_corner
	var/datum/lighting_corner/cg  = T.corners[2] || dummy_lighting_corner
	var/datum/lighting_corner/cb  = T.corners[4] || dummy_lighting_corner
	var/datum/lighting_corner/ca  = T.corners[1] || dummy_lighting_corner

	var/max = max(cr.cache_mx, cg.cache_mx, cb.cache_mx, ca.cache_mx)

	color  = list(
		cr.cache_r, cr.cache_g, cr.cache_b, 0,
		cg.cache_r, cg.cache_g, cg.cache_b, 0,
		cb.cache_r, cb.cache_g, cb.cache_b, 0,
		ca.cache_r, ca.cache_g, ca.cache_b, 0,
		0, 0, 0, 1
	)
	luminosity = max > LIGHTING_SOFT_THRESHOLD
	// Variety of overrides so the overlays don't get affected by weird things.

/atom/movable/lighting_overlay/proc/get_clamped_lum(var/minlum = 0, var/maxlum = 1)
	var/lum = max(lum_r, lum_g, lum_b)
	if(lum <= minlum)
		return 0
	else if(lum >= maxlum)
		return 1
	else
		return (lum - minlum) / (maxlum - minlum)

/atom/movable/lighting_overlay/singularity_act()
	return

/atom/movable/lighting_overlay/singularity_pull()
	return

/atom/movable/lighting_overlay/Destroy()
	global.all_lighting_overlays -= src
	var/turf/T = loc
	if(istype(T))
		T.lighting_overlay = null
		T.luminosity = 1
	return ..()
