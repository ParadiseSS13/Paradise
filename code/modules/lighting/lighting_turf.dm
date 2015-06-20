/turf
	var/list/affecting_lights
	#if LIGHTING_RESOLUTION == 1
	var/atom/movable/lighting_overlay/lighting_overlay
	#else
	var/list/lighting_overlays[0]
	#endif

/turf/proc/reconsider_lights()
	for(var/datum/light_source/L in affecting_lights)
		L.force_update()

/turf/proc/lighting_clear_overlays()
	#if LIGHTING_RESOLUTION == 1
	if(lighting_overlay)
		qdel(lighting_overlay)
	#else
	for(var/atom/movable/lighting_overlay/L in lighting_overlays)
		qdel(L)
	#endif

/turf/proc/lighting_build_overlays()
	#if LIGHTING_RESOLUTION == 1
	if(lighting_overlay)
	#else
	if(lighting_overlays.len)
	#endif
		return

	var/state = "light[LIGHTING_RESOLUTION]"
	var/area/A = loc
	if(A.lighting_use_dynamic)
		#if LIGHTING_RESOLUTION == 1
		var/atom/movable/lighting_overlay/O = new(src)
		O.icon_state = state
		lighting_overlay = O
		#else
		for(var/i = 0; i < LIGHTING_RESOLUTION; i++)
			for(var/j = 0; j < LIGHTING_RESOLUTION; j++)
				var/atom/movable/lighting_overlay/O = new(src)
				O.pixel_x = i * (32 / LIGHTING_RESOLUTION)
				O.pixel_y = j * (32 / LIGHTING_RESOLUTION)
				O.xoffset = (((2*i + 1) / (LIGHTING_RESOLUTION * 2)) - 0.5)
				O.yoffset = (((2*j + 1) / (LIGHTING_RESOLUTION * 2)) - 0.5)
				O.icon_state = state
				lighting_overlays += O
		#endif