SUBSYSTEM_DEF(fluid)
	name = "Fluids"
	init_order = INIT_ORDER_FLUID
	wait = 1 SECONDS
	flags = SS_BACKGROUND
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	offline_implications = "Fluid machinery will no longer run. No immediate action required." // Fluids are not something crucial to the round

	/// A list of all datums that have to be processed
	var/list/running_datums = list()
