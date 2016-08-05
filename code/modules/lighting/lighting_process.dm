#define MAX_LIGHT_UPDATES_PER_WORK   100
#define MAX_CORNER_UPDATES_PER_WORK  1000
#define MAX_OVERLAY_UPDATES_PER_WORK 2000

/datum/controller/process/lighting
	var/last_light_count = 0
	var/last_overlay_count = 0

/datum/controller/process/lighting/doWork()
	// Counters
	var/light_updates   = 0
	var/corner_updates  = 0
	var/overlay_updates = 0

	var/list/lighting_update_lights_old = lighting_update_lights //We use a different list so any additions to the update lists during a delay from SCHECK don't cause things to be cut from the list without being updated.
	last_light_count = lighting_update_lights.len
	lighting_update_lights = list()
	for(var/datum/light_source/L in lighting_update_lights_old)
		if(light_updates >= MAX_LIGHT_UPDATES_PER_WORK)
			lighting_update_lights += L
			continue // DON'T break, we're adding stuff back into the update queue.

		if(L.check() || L.destroyed || L.force_update)
			L.remove_lum()
			if(!L.destroyed)
				L.apply_lum()

		else if(L.vis_update)	//We smartly update only tiles that became (in) visible to use.
			L.smart_vis_update()

		L.vis_update   = FALSE
		L.force_update = FALSE
		L.needs_update = FALSE

		light_updates++

		SCHECK

	var/list/lighting_update_corners_old = lighting_update_corners //Same as above.
	lighting_update_corners = list()
	for(var/A in lighting_update_corners_old)
		if(corner_updates >= MAX_CORNER_UPDATES_PER_WORK)
			lighting_update_corners += A
			continue // DON'T break, we're adding stuff back into the update queue.

		var/datum/lighting_corner/C = A

		C.update_overlays()

		C.needs_update = FALSE

		corner_updates++

		SCHECK

	var/list/lighting_update_overlays_old = lighting_update_overlays //Same as above.
	last_overlay_count = lighting_update_overlays.len
	lighting_update_overlays = list()

	for(var/atom/movable/lighting_overlay/O in lighting_update_overlays_old)
		if(overlay_updates >= MAX_OVERLAY_UPDATES_PER_WORK)
			lighting_update_overlays += O
			continue // DON'T break, we're adding stuff back into the update queue.

		O.update_overlay()
		O.needs_update = 0
		overlay_updates++
		SCHECK
