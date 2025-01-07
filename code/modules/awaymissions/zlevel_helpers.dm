/datum/milla_safe_must_sleep/late_setup_level

// Ensures that atmos and environment are set up.
/datum/milla_safe_must_sleep/late_setup_level/on_run(turf/bot_left, turf/top_right, smoothTurfs)
	var/total_timer = start_watch()
	var/subtimer = start_watch()
	if(!smoothTurfs)
		smoothTurfs = block(bot_left, top_right)

	log_debug("Setting up atmos")
	/* setup_allturfs is superfluous during server initialization because
	 * air subsystem will call subsequently call setup_allturfs with _every_
	 * turf in the world */
	if(SSair && SSair.initialized)
		SSair.setup_turfs(bot_left, top_right)
	log_debug("\tTook [stop_watch(subtimer)]s")

	subtimer = start_watch()
	log_debug("Smoothing tiles")
	for(var/turf/T in smoothTurfs)
		if(T.smoothing_flags)
			QUEUE_SMOOTH(T)
		for(var/R in T)
			var/atom/A = R
			if(A.smoothing_flags)
				QUEUE_SMOOTH(A)
	log_debug("\tTook [stop_watch(subtimer)]s")
	log_debug("Late setup finished - took [stop_watch(total_timer)]s")

/proc/empty_rect(low_x,low_y, hi_x,hi_y, z)
	var/timer = start_watch()
	log_debug("Emptying region: ([low_x], [low_y]) to ([hi_x], [hi_y]) on z '[z]'")
	empty_region(block(low_x, low_y, z, hi_x, hi_y, z))
	log_debug("Took [stop_watch(timer)]s")

/proc/empty_region(list/turfs)
	for(var/thing in turfs)
		var/turf/T = thing
		for(var/otherthing in T)
			qdel(otherthing)
		T.ChangeTurf(T.baseturf)
