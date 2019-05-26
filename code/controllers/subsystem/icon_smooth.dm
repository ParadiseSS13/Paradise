SUBSYSTEM_DEF(icon_smooth)
	name = "Icon Smoothing"
	init_order = INIT_ORDER_ICON_SMOOTHING
	wait = 1
	priority = FIRE_PRIOTITY_SMOOTHING
	flags = SS_TICKER

	var/list/smooth_queue = list()

/datum/controller/subsystem/icon_smooth/fire()
	while(smooth_queue.len)
		var/atom/A = smooth_queue[smooth_queue.len]
		smooth_queue.len--
		smooth_icon(A)
		if(MC_TICK_CHECK)
			return
	if(!smooth_queue.len)
		can_fire = 0

/datum/controller/subsystem/icon_smooth/Initialize()
	smooth_zlevel(1,TRUE)
	smooth_zlevel(2,TRUE)
	var/queue = smooth_queue
	smooth_queue = list()
	for(var/V in queue)
		var/atom/A = V
		if(!A || A.z <= 2)
			continue
		smooth_icon(A)
		CHECK_TICK
	// Smooth those atoms
	var/s_watch = start_watch()
	log_startup_progress("Smoothing atoms...")
	for(var/turf/T in world)
		if(T.smooth)
			queue_smooth(T)
		for(var/A in T)
			var/atom/AA = A
			if(AA.smooth)
				queue_smooth(AA)
	log_startup_progress("Smoothed atoms in [stop_watch(s_watch)]s.")
	// Reticulate those splines, baby!
	var/r_watch = start_watch()
	log_startup_progress("Reticulating splines...")
	for(var/turf/simulated/mineral/M in GLOB.mineral_turfs)
		M.add_edges()
	log_startup_progress("Splines reticulated in [stop_watch(r_watch)]s.")
	return ..()
