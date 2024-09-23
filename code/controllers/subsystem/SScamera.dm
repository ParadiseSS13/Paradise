// Subsystem that controls the camera vision tiles
SUBSYSTEM_DEF(camera)
	name = "Camera"
	flags = SS_BACKGROUND | SS_NO_INIT
	priority = FIRE_PRIORITY_CAMERA
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	wait = 2.5 SECONDS
	offline_implications = "AI camera view won't update. No immediate action is needed."
	var/list/chunk_queue = list()

/datum/controller/subsystem/camera/fire(resumed)
	for(var/datum/camerachunk/chunk as anything in chunk_queue)
		chunk.update()
		chunk_queue -= chunk
		if(MC_TICK_CHECK)
			return


/datum/controller/subsystem/camera/proc/queue(datum/camerachunk/chunk)
	if(!chunk_queue[chunk])
		chunk_queue[chunk] = chunk

/datum/controller/subsystem/camera/proc/remove_from_queue(datum/camerachunk/chunk)
	chunk_queue -= chunk
