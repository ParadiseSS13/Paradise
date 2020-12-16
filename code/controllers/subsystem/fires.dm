SUBSYSTEM_DEF(fires)
	name = "Fires"
	priority = FIRE_PRIORITY_BURNING
	flags = SS_NO_INIT|SS_BACKGROUND
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	offline_implications = "Objects will no longer react to fires. No immediate action is needed."

	var/list/currentrun = list()
	var/list/processing = list()

/datum/controller/subsystem/fires/stat_entry()
	..("P:[processing.len]")


/datum/controller/subsystem/fires/fire(resumed = 0)
	if(!resumed)
		src.currentrun = processing.Copy()

	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun

	while(currentrun.len)
		var/obj/O = currentrun[currentrun.len]
		currentrun.len--
		if(!O || QDELETED(O))
			processing -= O
			if(MC_TICK_CHECK)
				return
			continue

		if(O.resistance_flags & ON_FIRE) //in case an object is extinguished while still in currentrun
			if(!(O.resistance_flags & FIRE_PROOF))
				O.take_damage(20, BURN, "fire", 0)
			else
				O.extinguish()

		if(MC_TICK_CHECK)
			return
