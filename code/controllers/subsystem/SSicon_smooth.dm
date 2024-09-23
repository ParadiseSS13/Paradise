SUBSYSTEM_DEF(icon_smooth)
	name = "Icon Smoothing"
	init_order = INIT_ORDER_ICON_SMOOTHING
	wait = 1
	priority = FIRE_PRIORITY_SMOOTHING
	flags = SS_TICKER
	offline_implications = "Objects will no longer smooth together properly. No immediate action is needed."
	cpu_display = SS_CPUDISPLAY_LOW

	var/list/smooth_queue = list()

/datum/controller/subsystem/icon_smooth/fire()
	while(length(smooth_queue))
		var/atom/A = smooth_queue[length(smooth_queue)]
		smooth_queue.len--
		A.smooth_icon()
		if(MC_TICK_CHECK)
			return
	if(!length(smooth_queue))
		can_fire = 0

/datum/controller/subsystem/icon_smooth/Initialize()
	log_startup_progress("Smoothing atoms...")
	// Smooth EVERYTHING in the world
	for(var/turf/T in world)
		if(T.smoothing_flags)
			T.smooth_icon()
		for(var/A in T)
			var/atom/AA = A
			if(AA.smoothing_flags)
				AA.smooth_icon()
				CHECK_TICK

	// Incase any new atoms were added to the smoothing queue for whatever reason
	var/queue = smooth_queue
	smooth_queue = list()
	for(var/V in queue)
		var/atom/A = V
		if(!A || A.z <= 2)
			continue
		A.smooth_icon()
		CHECK_TICK


/datum/controller/subsystem/icon_smooth/proc/add_to_queue(atom/thing)
	if(thing.smoothing_flags & SMOOTH_QUEUED)
		return
	thing.smoothing_flags |= SMOOTH_QUEUED
	smooth_queue += thing
	if(!can_fire)
		can_fire = TRUE

/datum/controller/subsystem/icon_smooth/proc/remove_from_queues(atom/thing)
	thing.smoothing_flags &= ~SMOOTH_QUEUED
	smooth_queue -= thing
