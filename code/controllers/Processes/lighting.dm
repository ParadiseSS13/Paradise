/var/list/lighting_update_lights    = list()    // List of lighting sources  queued for update.
/var/list/lighting_update_corners   = list()    // List of lighting corners  queued for update.
/var/list/lighting_update_overlays  = list()    // List of lighting overlays queued for update.

var/global/datum/controller/process/lighting/lighting_controller

/datum/controller/process/lighting/setup()
	name = "lighting"
	schedule_interval = LIGHTING_INTERVAL
	start_delay = 1
	lighting_controller = src

	create_all_lighting_overlays()
	create_all_lighting_corners()
	// Pre-process lighting once before the round starts. Wait 30 seconds so the away mission has time to load.
	spawn(300)
		doWork()

/datum/controller/process/lighting/statProcess()
	..()
	stat(null, "[last_light_count] lights, [last_overlay_count] overlays")

// Lighting process code located in modules\lighting\lighting_process.dm
