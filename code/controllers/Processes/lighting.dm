var/global/datum/controller/process/lighting/lighting_controller

/datum/controller/process/lighting/setup()
	name = "lighting"
	schedule_interval = LIGHTING_INTERVAL
	start_delay = 1
	lighting_controller = src

	create_lighting_overlays()
	// Pre-process lighting once before the round starts. Wait 30 seconds so the away mission has time to load.
	spawn(300)
		doWork()

/datum/controller/process/lighting/statProcess()
	..()
	stat(null, "[last_light_count] lights, [last_overlay_count] overlays")

#undef MAX_LIGHT_UPDATES_PER_WORK
#undef MAX_CORNER_UPDATES_PER_WORK
#undef MAX_OVERLAY_UPDATES_PER_WORK
