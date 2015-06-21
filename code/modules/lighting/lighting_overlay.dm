/atom/movable/lighting_overlay
	name = ""
	mouse_opacity = 0
	simulated = 0
	anchored = 1
	flags = NOREACT
	icon = LIGHTING_ICON
	layer = LIGHTING_LAYER
	invisibility = INVISIBILITY_LIGHTING
	blend_mode = BLEND_MULTIPLY
	color = "#000000"

	var/lum_r
	var/lum_g
	var/lum_b

	#if LIGHTING_RESOLUTION != 1
	var/xoffset
	var/yoffset
	#endif

	var/needs_update

/atom/movable/lighting_overlay/New()
	. = ..()
	verbs.Cut()

/atom/movable/lighting_overlay/proc/get_clamped_lum(var/minlum = 0, var/maxlum = 1)
	var/lum = max(lum_r, lum_g, lum_b)
	if(lum <= minlum)
		return 0
	else if(lum >= maxlum)
		return 1
	else
		return (lum - minlum) / (maxlum - minlum)

/atom/movable/lighting_overlay/proc/update_lumcount(delta_r, delta_g, delta_b)
	if(!delta_r && !delta_g && !delta_b) //Nothing is being changed all together.
		return

	var/should_update = 0

	if(!needs_update) //If this isn't true, we're already updating anyways.
		if(max(lum_r, lum_g, lum_b) < 1) //Any change that could happen WILL change appearance.
			should_update = 1

		else if(max(lum_r + delta_r, lum_g + delta_g, lum_b + delta_b) < 1) //The change would bring us under 1 max lum, again, guaranteed to change appearance.
			should_update = 1

		else //We need to make sure that the colour ratios won't change in this code block.
			var/mx1 = max(lum_r, lum_g, lum_b)
			var/mx2 = max(lum_r + delta_r, lum_g + delta_g, lum_b + delta_b)

			if(lum_r / mx1 != (lum_r + delta_r) / mx2 || lum_g / mx1 != (lum_g + delta_g) / mx2 || lum_b / mx1 != (lum_b + delta_b) / mx2) //Stuff would change.
				should_update = 1

	lum_r += delta_r
	lum_g += delta_g
	lum_b += delta_b

	if(!needs_update && should_update)
		needs_update = 1
		lighting_update_overlays += src

/atom/movable/lighting_overlay/proc/update_overlay()
	var/mx = max(lum_r, lum_g, lum_b)
	. = 1 // factor
	if(mx > 1)
		. = 1/mx
	#if LIGHTING_TRANSITIONS == 1
	animate(src,
		color = rgb(lum_r * 255 * ., lum_g * 255 * ., lum_b * 255 * .),
		LIGHTING_TRANSITION_SPEED
	)
	#else
	color = rgb(lum_r * 255 * ., lum_g * 255 * ., lum_b * 255 * .)
	#endif

	var/turf/T = loc

	if(istype(T)) //Incase we're not on a turf, pool ourselves, something happened.
		if(color != "#000000")
			T.luminosity = 1
		else  //No light, set the turf's luminosity to 0 to remove it from view()
			#if LIGHTING_TRANSITIONS == 1
			spawn(LIGHTING_TRANSITION_SPEED)
				T.luminosity = 0
			#else
			T.luminosity = 0
			#endif

	else
		warning("A lighting overlay realised it's loc was NOT a turf (actual loc: [loc], [loc.type]) in update_overlay() and got qdel'd!")
		qdel(src)

/atom/movable/lighting_overlay/singularity_act()
	return

/atom/movable/lighting_overlay/singularity_pull()
	return

/atom/movable/lighting_overlay/Destroy()
	lighting_update_overlays -= src

	var/turf/T = loc
	if(istype(T))
		#if LIGHTING_RESOLUTION == 1
		T.lighting_overlay = null
		#else
		T.lighting_overlays -= src
		#endif
		for(var/datum/light_source/D in T.affecting_lights) //Remove references to us on the light sources affecting us.
			D.effect_r -= src
			D.effect_g -= src
			D.effect_b -= src
