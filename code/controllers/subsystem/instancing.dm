SUBSYSTEM_DEF(instancing)
	name = "Instancing"
	runlevels = RUNLEVEL_INIT | RUNLEVEL_LOBBY | RUNLEVEL_SETUP | RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	/// Have we announced startup yet
	var/startup_announced = FALSE
	/// Is a check currently running?
	var/check_running = FALSE

/datum/controller/subsystem/instancing/Initialize(start_timeofday)
	// Do an initial peer check
	check_peers()
	return ..()

/datum/controller/subsystem/instancing/fire(resumed)
	check_peers()


/**
  * Refreshes all peers on the server
  *
  * Called periodically during fire() as well as when a new peer reports itself as online
  * Only one instance of this proc may run at a time
  *
  */
/datum/controller/subsystem/instancing/proc/check_peers()
	set waitfor = FALSE // This has sleeps if it cant topic so we dont want to bog things down
	if(check_running)
		return

	check_running = TRUE // Dont allow multiple of these
	// A NOTE TO ANYONE ELSE WHO LOOKS AT THIS
	// THESE TIMINGS ARE A FUCKING NIGHTMARE AND YOU WILL NEED DEBUG LOGGING TO TEST THEM
	// DO NOT FUCK WITH THE TIMINGS -aa
	for(var/datum/peer_server/PS in GLOB.configuration.instancing.peers)
		// If the server hasnt been discovered and its been more than 5 minutes
		if((!PS.discovered && PS.last_operation_time + 5 MINUTES > world.time))
			continue

		if(PS.last_operation_time + 1 MINUTES > world.time)
			continue // Only run main operations once every minute anyway

		var/peer_response = world.Export("byond://[PS.internal_ip]:[PS.server_port]?server_discovery&key=[PS.commskey]")
		if(!peer_response)
			PS.online = FALSE // Peer is offline
			PS.last_operation_time = world.time
			continue

		// We got a response
		PS.discovered = TRUE
		PS.online = TRUE
		var/list/peer_data = json_decode(peer_response)

		PS.external_ip = peer_data["external_ip"]
		PS.server_id = peer_data["server_id"]
		PS.server_name = peer_data["server_name"]
		PS.playercount = peer_data["playercount"]

		PS.last_operation_time = world.time

	check_running = FALSE

/datum/controller/subsystem/instancing/proc/message_all_peers(include_offline = FALSE)
	return
