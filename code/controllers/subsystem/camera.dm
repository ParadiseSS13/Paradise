// Subsystem that controls the camera vision tiles
SUBSYSTEM_DEF(camera)
	name = "Camera"
	flags = SS_BACKGROUND | SS_NO_INIT
	priority = FIRE_PRIORITY_AMBIENCE
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	wait = 2.5 SECONDS
	offline_implications = "AI camera view won't update. No immediate action is needed."
	var/list/chunk_queue = list()

/datum/controller/subsystem/camera/fire(resumed)
	var/static/count = 0
	var/list/queue = chunk_queue
	if(count)
		var/c = count
		count = 0 //so if we runtime on the Cut, we don't try again.
		queue.Cut(1, c + 1)

	for(var/datum/camerachunk/chunk as anything in queue)
		++count
		chunk.update()
		if(MC_TICK_CHECK)
			return

	if(count)
		queue.Cut(1, count + 1)
		count = 0

/datum/controller/subsystem/camera/proc/queue(datum/camerachunk/chunk)
	if(!chunk_queue[chunk])
		chunk_queue[chunk] = chunk

/datum/controller/subsystem/camera/proc/remove_from_queue(datum/camerachunk/chunk)
	chunk_queue -= chunk
