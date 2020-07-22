SUBSYSTEM_DEF(nanoui)
	name = "Nanoui"
	wait = 9
	flags = SS_NO_INIT
	priority = FIRE_PRIORITY_NANOUI
	runlevels = RUNLEVEL_LOBBY | RUNLEVELS_DEFAULT

	var/list/currentrun = list()
	var/list/open_uis = list() // A list of open UIs, grouped by src_object and ui_key.
	var/list/processing_uis = list() // A list of processing UIs, ungrouped.

/datum/controller/subsystem/nanoui/Shutdown()
	close_all_uis()

/datum/controller/subsystem/nanoui/stat_entry()
	..("P:[processing_uis.len]")

/datum/controller/subsystem/nanoui/fire(resumed = 0)
	if(!resumed)
		src.currentrun = processing_uis.Copy()
	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun

	while(currentrun.len)
		var/datum/nanoui/ui = currentrun[currentrun.len]
		currentrun.len--
		if(ui && ui.user && ui.src_object)
			ui.process()
		else
			processing_uis.Remove(ui)
		if(MC_TICK_CHECK)
			return

