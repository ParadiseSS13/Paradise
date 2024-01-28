// All the stuff in here is related to the auxtools debugger, supplied as part of the DM Language Server VSCode extension
// These procs are named EXACTLY as they are since the debugger itself will hook into these procs internally
// Do not change these names. Please. -aa

/proc/auxtools_stack_trace(msg)
	CRASH(msg)

/proc/enable_debugging(mode, port)
	CRASH("auxtools not loaded")

/proc/auxtools_expr_stub()
	CRASH("auxtools not loaded")

/world/proc/enable_auxtools_debugger()
	var/debug_server = world.GetConfig("env", "AUXTOOLS_DEBUG_DLL")
	if(debug_server)
		CALL_EXT(debug_server, "auxtools_init")()
		enable_debugging()

// Called in world/Del(). This is VERY important, otherwise you get phantom threads which try to lookup RAM they arent allowed to
/world/proc/disable_auxtools_debugger()
	var/debug_server = world.GetConfig("env", "AUXTOOLS_DEBUG_DLL")
	if(debug_server)
		CALL_EXT(debug_server, "auxtools_shutdown")()
