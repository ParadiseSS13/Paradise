// Solves problems with lighting updates lagging shit
// Max constraints on number of updates per doWork():
#define MAX_LIGHT_UPDATES_PER_WORK   100
#define MAX_CORNER_UPDATES_PER_WORK  1000
#define MAX_OVERLAY_UPDATES_PER_WORK 2000

/var/lighting_overlays_initialised = FALSE

/var/list/lighting_update_lights    = list()    // List of lighting sources  queued for update.
/var/list/lighting_update_corners   = list()    // List of lighting corners  queued for update.
/var/list/lighting_update_overlays  = list()    // List of lighting overlays queued for update.

/var/list/lighting_update_lights_old    = list()    // List of lighting sources  currently being updated.
/var/list/lighting_update_corners_old   = list()    // List of lighting corners  currently being updated.
/var/list/lighting_update_overlays_old  = list()    // List of lighting overlays currently being updated.


/datum/controller/process/lighting
/datum/controller/process/lighting/setup()
	name = "lighting"

	schedule_interval = world.tick_lag // run as fast as you possibly can
	create_all_lighting_overlays()
	lighting_overlays_initialised = TRUE

	// Pre-process lighting once before the round starts. Wait 30 seconds so the away mission has time to load.
	spawn(300)
		doWork(1)

/datum/controller/process/lighting/doWork(roundstart)
	// Counters
	var/light_updates   = 0
	var/corner_updates  = 0
	var/overlay_updates = 0

	lighting_update_lights_old = lighting_update_lights //We use a different list so any additions to the update lists during a delay from scheck() don't cause things to be cut from the list without being updated.
	lighting_update_lights = list()
	for(var/datum/light_source/L in lighting_update_lights_old)
		if(light_updates >= MAX_LIGHT_UPDATES_PER_WORK && !roundstart)
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

	lighting_update_corners_old = lighting_update_corners //Same as above.
	lighting_update_corners = list()
	for(var/A in lighting_update_corners_old)
		if(corner_updates >= MAX_CORNER_UPDATES_PER_WORK && !roundstart)
			lighting_update_corners += A
			continue // DON'T break, we're adding stuff back into the update queue.

		var/datum/lighting_corner/C = A

		C.update_overlays()

		C.needs_update = FALSE

		corner_updates++

		SCHECK

	lighting_update_overlays_old = lighting_update_overlays //Same as above.
	lighting_update_overlays = list()

	for(var/atom/movable/lighting_overlay/O in lighting_update_overlays_old)
		if(overlay_updates >= MAX_OVERLAY_UPDATES_PER_WORK && !roundstart)
			lighting_update_overlays += O
			continue // DON'T break, we're adding stuff back into the update queue.

		O.update_overlay()
		O.needs_update = 0
		overlay_updates++
		SCHECK




/datum/controller/process/lighting/statProcess()
	..()
	stat(null, "[all_lighting_sources.len] light sources exist")
	stat(null, "[all_lighting_corners.len] light corners exist")
	stat(null, "[global.all_lighting_overlays.len] light overlays exist")
	stat(null, "[lighting_update_lights.len] lighting sources queued")
	stat(null, "[lighting_update_corners.len] lighting corners queued")
	stat(null, "[lighting_update_overlays.len] lighting overlays queued")

#undef MAX_LIGHT_UPDATES_PER_WORK
#undef MAX_CORNER_UPDATES_PER_WORK
#undef MAX_OVERLAY_UPDATES_PER_WORK
