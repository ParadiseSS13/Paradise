SUBSYSTEM_DEF(acid)
	name = "Acid"
	priority = FIRE_PRIORITY_ACID
	flags = SS_NO_INIT|SS_BACKGROUND
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	cpu_display = SS_CPUDISPLAY_LOW
	offline_implications = "Objects will no longer react to acid. No immediate action is needed."

	var/list/currentrun = list()
	var/list/processing = list()

/datum/controller/subsystem/acid/get_stat_details()
	return "P:[length(processing)]"

/datum/controller/subsystem/acid/get_metrics()
	. = ..()
	var/list/cust = list()
	cust["processing"] = length(processing)
	.["custom"] = cust

/datum/controller/subsystem/acid/fire(resumed = 0)
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

		if(!(O.acid_level && O.acid_processing()))
			O.cut_overlay(GLOB.acid_overlay, TRUE)
			processing -= O

		if(MC_TICK_CHECK)
			return
