/datum/super_early_init

/datum/super_early_init/New()
	// This exists so that world.Profile() is THE FIRST PROC TO RUN in the init sequence.
	// This allows us to get the real details of everything lagging at server start.
	world.Profile(PROFILE_START)
	#if defined(ENABLE_BYOND_TRACY)
	var/tracy_init = CALL_EXT("prof.dll", "init")() // Setup Tracy integration
	if(tracy_init != "0")
		CRASH("Tracy init error: [tracy_init]")
	#endif
	// After that, the debugger is initialized.
	// Doing it this early makes it possible to set breakpoints in the New()
	// of things assigned to global variables or objects included in a compiled map file.
	world.enable_auxtools_debugger()

GLOBAL_REAL(super_early_init, /datum/super_early_init) = new
