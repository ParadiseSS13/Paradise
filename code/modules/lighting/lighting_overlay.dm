/var/list/all_lighting_overlays = list() // Global list of lighting overlays.
/atom/movable/lighting_overlay
	name = ""
	mouse_opacity = 0
	simulated = 0
	anchored = 1
	flags = NOREACT
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
	var/list/L = src.color:Copy() // For some dumb reason BYOND won't allow me to use [] on a colour matrix directly.
	var/max    = 0

	for(var/datum/lighting_corner/C in T.corners)
		var/i = 0

		// Huge switch to determine i based on D.
		switch(turn(C.masters[T], 180))
			if(NORTHEAST)
				i = CL_MATRIX_AR

			if(SOUTHEAST)
				i = CL_MATRIX_GR

			if(SOUTHWEST)
				i = CL_MATRIX_RR

			if(NORTHWEST)
				i = CL_MATRIX_BR

		var/mx = max(C.lum_r, C.lum_g, C.lum_b) // Scale it so 1 is the strongest lum, if it is above 1.
		. = 1 // factor
		if(mx > 1)
			. = 1 / mx

		else if(mx < LIGHTING_SOFT_THRESHOLD)
			. = 0 // 0 means soft lighting.

		if(wa)
			to_chat(world, "[.] [mx] [max] ")

		max = max(max, mx)

		if(.)
			L[i + 0]   = C.lum_r * .
			L[i + 1]   = C.lum_g * .
			L[i + 2]   = C.lum_b * .
		else
			L[i + 0]   = LIGHTING_SOFT_THRESHOLD
			L[i + 1]   = LIGHTING_SOFT_THRESHOLD
			L[i + 2]   = LIGHTING_SOFT_THRESHOLD

	src.color  = L
	luminosity = (max > LIGHTING_SOFT_THRESHOLD)

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
