/datum/milla_safe_must_sleep/late_setup_level

// Ensures that atmos and environment are set up.
/datum/milla_safe_must_sleep/late_setup_level/on_run(turf/bot_left, turf/top_right, smoothTurfs)
	if(!smoothTurfs)
		smoothTurfs = block(bot_left, top_right)

	/* setup_allturfs is superfluous during server initialization because
	 * air subsystem will call subsequently call setup_allturfs with _every_
	 * turf in the world */
	if(SSair && SSair.initialized)
		SSair.setup_turfs(bot_left, top_right)
	set_zlevel_freeze(bot_left.z, FALSE)

	for(var/turf/T in smoothTurfs)
		if(T.smoothing_flags)
			QUEUE_SMOOTH(T)
		for(var/R in T)
			var/atom/A = R
			if(A.smoothing_flags)
				QUEUE_SMOOTH(A)

/proc/empty_rect(low_x,low_y, hi_x,hi_y, z)
	empty_region(block(low_x, low_y, z, hi_x, hi_y, z))

/proc/empty_region(list/turfs)
	for(var/thing in turfs)
		var/turf/T = thing
		for(var/otherthing in T)
			qdel(otherthing)
		T.ChangeTurf(T.baseturf)

/datum/milla_safe/freeze_z_level
	var/done = FALSE

// Ensures that atmos is frozen before loading
/datum/milla_safe/freeze_z_level/on_run(z)
	set_zlevel_freeze(z, TRUE)
	done = TRUE
