var/global/datum/controller/process/spacedrift/drift_master

/datum/controller/process/spacedrift
	var/list/processing_list = list()

/datum/controller/process/spacedrift/setup()
	name = "spacedrift"
	schedule_interval = 5
	start_delay = 20
	log_startup_progress("Spacedrift starting up.")

/datum/controller/process/spacedrift/statProcess()
	..()
	stat(null, "P:[processing_list.len]")

/datum/controller/process/spacedrift/doWork()
	var/list/currentrun = processing_list.Copy()

	while(currentrun.len)
		var/atom/movable/AM = currentrun[currentrun.len]
		currentrun.len--
		if(!AM)
			processing_list -= AM
			SCHECK
			continue

		if(AM.inertia_next_move > world.time)
			SCHECK
			continue

		if(!AM.loc || AM.loc != AM.inertia_last_loc || AM.Process_Spacemove(0))
			AM.inertia_dir = 0

		if(!AM.inertia_dir)
			AM.inertia_last_loc = null
			processing_list -= AM
			SCHECK
			continue

		var/old_dir = AM.dir
		var/old_loc = AM.loc
		AM.inertia_moving = TRUE
		step(AM, AM.inertia_dir)
		AM.inertia_moving = FALSE
		AM.inertia_next_move = world.time + AM.inertia_move_delay
		if(AM.loc == old_loc)
			AM.inertia_dir = 0

		AM.setDir(old_dir)
		AM.inertia_last_loc = AM.loc
		SCHECK

DECLARE_GLOBAL_CONTROLLER(spacedrift, drift_master)