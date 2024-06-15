SUBSYSTEM_DEF(fires)
	name = "Fires"
	priority = FIRE_PRIORITY_BURNING
	flags = SS_NO_INIT|SS_BACKGROUND
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	cpu_display = SS_CPUDISPLAY_LOW // Trust me, this isnt atmos fires, this is paper and stuff being lit with lighters and stuff
	offline_implications = "Objects will no longer react to fires. No immediate action is needed."

	var/list/currentrun = list()
	var/list/processing = list()

/datum/controller/subsystem/fires/get_stat_details()
	return "P:[length(processing)]"


/datum/controller/subsystem/fires/get_metrics()
	. = ..()
	var/list/cust = list()
	cust["processing"] = length(processing)
	.["custom"] = cust

/datum/controller/subsystem/fires/fire(resumed = 0)
	if(!resumed)
		src.currentrun = processing.Copy()

	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun

	while(length(currentrun))
		var/obj/O = currentrun[length(currentrun)]
		currentrun.len--
		if(!O || QDELETED(O))
			processing -= O
			if(MC_TICK_CHECK)
				return
			continue

		if(O.resistance_flags & ON_FIRE) //in case an object is extinguished while still in currentrun
			if(!(O.resistance_flags & FIRE_PROOF))
				O.take_damage(20, BURN, FIRE, 0)
			else
				O.extinguish()

		if(MC_TICK_CHECK)
			return
