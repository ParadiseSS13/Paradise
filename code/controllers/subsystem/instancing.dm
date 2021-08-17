SUBSYSTEM_DEF(instancing)
	name = "Instancing"
	runlevels = RUNLEVEL_INIT | RUNLEVEL_LOBBY | RUNLEVEL_SETUP | RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	/// Has our initial check complete? Used to halt init but not lag the server
	var/initial_check_complete = FALSE
	/// Is a check currently running?
	var/check_running = FALSE

/datum/controller/subsystem/instancing/Initialize(start_timeofday)
	// Do an initial peer check
	check_peers(TRUE) // Force because of time memes
	UNTIL(initial_check_complete) // Wait here a bit
	var/startup_msg = "The server [GLOB.configuration.general.server_name] is now starting up. The map is [SSmapping.map_datum.fluff_name] ([SSmapping.map_datum.technical_name])"
	message_all_peers(startup_msg)
	return ..()

/datum/controller/subsystem/instancing/fire(resumed)
	check_peers()

/**
  * Refreshes all peers on the server
  *
  * Called periodically during fire() as well as when a new peer reports itself as online
  * Only one instance of this proc may run at a time
  *
  * Arguments:
  * * force - Do we want to force check all of them
  */
/datum/controller/subsystem/instancing/proc/check_peers(force = FALSE)
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
			if(!force) // No, code review. This is not going in the same line.
				continue

		// Only run main operations once every minute anyway
		if(PS.last_operation_time + 1 MINUTES > world.time)
			if(!force)
				continue

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
	initial_check_complete = TRUE

/**
  * Message all peers
  *
  * Wrapper for [topic_all_peers] to autoformat a message topic. Will send a server-wide announcement to the other servers
  * including any relevant detail
  * Arguments:
  * * message - Message to send to the other servers
  * * include_offline - Whether to topic offline servers on the off chance they came online
  */
/datum/controller/subsystem/instancing/proc/message_all_peers(message, include_offline = FALSE)
	var/topic_string = "instance_announce&msg=[html_encode(message)]"
	topic_all_peers(topic_string, include_offline)

/**
  * Sends a topic to all peers
  *
  * Sends a raw topic to the other servers. WILL APPEND &key=[commskey] ON THE END. PLEASE ACCOUNT FOR THIS.
  *
  * Arguments:
  * * raw_topic - The raw topic to send to the other servers
  * * include_offline - Whether to topic offline servers on the off chance they came online
  */
/datum/controller/subsystem/instancing/proc/topic_all_peers(raw_topic, include_offline = FALSE)
	for(var/datum/peer_server/PS in GLOB.configuration.instancing.peers)
		if(PS.online || include_offline)
			world.Export("byond://[PS.internal_ip]:[PS.server_port]?[raw_topic]&key=[PS.commskey]")
