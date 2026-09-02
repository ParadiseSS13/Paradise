SUBSYSTEM_DEF(heartbeat)
	name = "Heartbeat"
	flags = SS_KEEP_TIMING
	wait = 30 SECONDS
	runlevels = RUNLEVEL_INIT | RUNLEVEL_LOBBY | RUNLEVEL_SETUP | RUNLEVEL_GAME | RUNLEVEL_POSTGAME // ALL THE THINGS
	/// Last time we got a heartbeat from TGS
	var/last_heartbeat = 0
	/// Has a warning been sent this round?
	var/warning_tripped = FALSE

/datum/controller/subsystem/heartbeat/Initialize()
	// Disable if we arent running on TGS
	if(!world.TgsAvailable())
		flags |= SS_NO_FIRE

/datum/controller/subsystem/heartbeat/fire(resumed)
	// If the last heartbeat is 0, we never got one this round
	if(last_heartbeat != 0 && (last_heartbeat + 2 MINUTES < REALTIMEOFDAY) && !warning_tripped)
		to_chat(GLOB.admins, "<hr><center>[SPAN_USERDANGER("<big>--- CRITICAL ---</big>")]<br>The server hasn't received an uptime check from the server daemon for over 2 minutes. Inform AA ASAP.</center><hr>")
		warning_tripped = TRUE
