PROCESSING_SUBSYSTEM_DEF(fluid)
	name = "Fluids"
	priority = FIRE_PRIORITY_OBJ
	wait = 0.5 SECONDS
	flags = SS_NO_INIT
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	offline_implications = "Fluid machinery will no longer run. No immediate action required." // Fluids are not something crucial to the round
