SUBSYSTEM_DEF(instancing)
	name = "Instancing"
	runlevels = RUNLEVEL_INIT | RUNLEVEL_LOBBY | RUNLEVEL_SETUP | RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	wait = 30 SECONDS
	flags = SS_KEEP_TIMING

/datum/controller/subsystem/instancing/Initialize(start_timeofday)
	// Dont even bother if we arent connected
	if(!SSdbcore.IsConnected())
		flags |= SS_NO_FIRE
		return ..()
	update_heartbeat() // Make sure you do this before announcing to peers, or no one will hear your announcement
	var/startup_msg = "The server <code>[GLOB.configuration.general.server_name]</code> is now starting up. The map is [SSmapping.map_datum.fluff_name] ([SSmapping.map_datum.technical_name]). You can connect with the <code>Switch Server</code> verb."
	message_all_peers(startup_msg)
	return ..()

/datum/controller/subsystem/instancing/fire(resumed)
	update_heartbeat()
	update_playercache()

/**
  * Playercache updater
  *
  * Updates the player cache in the DB. Different from heartbeat so we can force invoke it on player operations
  */
/datum/controller/subsystem/instancing/proc/update_playercache(optional_ckey)
	// You may be wondering, why the fuck is an "optional ckey" variable here
	// Well, this is invoked in client/New(), and needs to read from GLOB.clients
	// However, this proc sleeps, and if you sleep during client/New() once the client is in GLOB.clients, stuff breaks bad
	// (See my comment rambling in client/New())
	// By passing the ckey through, we can sleep in this proc and still get the data
	if(!SSdbcore.IsConnected())
		return
	// First iterate clients to get ckeys
	var/list/ckeys = list()
	for(var/client/C in GLOB.clients) // No code review. I am not doing the `as anything` bullshit, because we *do* need the type checks here to avoid null clients which do happen sometimes
		ckeys += C.ckey
	// Add our optional
	if(optional_ckey)
		ckeys += optional_ckey
	// Note: We dont have to sort the list here. The only time this is read for is a search,
	// and order doesnt matter for that.
	var/ckey_json = json_encode(ckeys)

	// Yes I care about performance savings this much here to mass execute this shit
	var/list/datum/db_query/queries = list()
	queries += SSdbcore.NewQuery("UPDATE instance_data_cache SET key_value=:json WHERE key_name='playerlist' AND server_id=:sid", list(
		"json" = ckey_json,
		"sid" = GLOB.configuration.system.instance_id
	))
	queries += SSdbcore.NewQuery("UPDATE instance_data_cache SET key_value=:count WHERE key_name='playercount' AND server_id=:sid", list(
		"count" = length(ckeys),
		"sid" = GLOB.configuration.system.instance_id
	))

	SSdbcore.MassExecute(queries, TRUE, TRUE, FALSE, FALSE)

/**
  * Heartbeat updater
  *
  * Updates the heartbeat in the DB. Used so other servers can see when this one was alive
  */
/datum/controller/subsystem/instancing/proc/update_heartbeat()
	// this could probably just go in fire() but clean code and profiler ease who cares
	var/datum/db_query/dbq = SSdbcore.NewQuery("UPDATE instance_data_cache SET key_value=NOW() WHERE key_name='heartbeat' AND server_id=:sid", list(
		"sid" = GLOB.configuration.system.instance_id
	))
	dbq.warn_execute()
	qdel(dbq)

/**
  * Seed data
  *
  * Seeds all our data into the DB for other servers to discover from.
  * This is called during world/New() instead of on initialize so it can be done *instantly*
  */
/datum/controller/subsystem/instancing/proc/seed_data()
	// We need to seed a lot of keys, so lets just use a key-value-pair-map to do this easily
	var/list/kvp_map = list()
	kvp_map["server_name"] = GLOB.configuration.general.server_name // Name of the server
	kvp_map["server_port"] = world.port // Server port (used for redirection and topics)
	kvp_map["topic_key"] = GLOB.configuration.system.topic_key // Server topic key (used for topics)
	kvp_map["internal_ip"] = GLOB.configuration.system.internal_ip // Server internal IP (used for topics)
	kvp_map["playercount"] = length(GLOB.clients) // Server client count (used for status info)
	kvp_map["playerlist"] = json_encode(list()) // Server client list. Used for dupe login checks. This gets filled in later
	kvp_map["heartbeat"] = SQLtime() // SQL timestamp for heartbeat purposes. Any server without a heartbeat in the last 60 seconds can be considered dead
	// Also note for above. You may say "But AA you dont need to JSON encode it, just use "\[]"."
	// Well to that I say, no. This is meant to be JSON regardless, and it should represent that. This proc is ran once during world/New()
	// An extra nanosecond of load will make zero difference.

	for(var/key in kvp_map)
		var/datum/db_query/dbq = SSdbcore.NewQuery("INSERT INTO instance_data_cache (server_id, key_name, key_value) VALUES (:sid, :kn, :kv) ON DUPLICATE KEY UPDATE key_value=:kv2", // Is this necessary? Who knows!
			list(
				"sid" = GLOB.configuration.system.instance_id,
				"kn" = key,
				"kv" = "[kvp_map[key]]", // String encoding IS necessary since these tables use strings, not ints
				"kv2" = "[kvp_map[key]]", // Dont know if I need the second but better to be safe
			)
		)
		dbq.warn_execute(FALSE) // Do NOT async execute here because world/New() shouldnt sleep. EVER. You get issues if you do.
		qdel(dbq)


/**
  * Message all peers
  *
  * Wrapper for [topic_all_peers] to format the input into a message topic. Will send a server-wide announcement to the other servers
  *
  * Arguments:
  * * message - Message to send to the other servers
  */
/datum/controller/subsystem/instancing/proc/message_all_peers(message)
	if(!SSdbcore.IsConnected())
		return
	var/topic_string = "instance_announce&msg=[url_encode(message)]"
	topic_all_peers(topic_string)

/**
  * Sends a topic to all peers
  *
  * Sends a raw topic to the other servers. WILL APPEND &key=[commskey] ON THE END. PLEASE ACCOUNT FOR THIS.
  *
  * Arguments:
  * * raw_topic - The raw topic to send to the other servers
  */
/datum/controller/subsystem/instancing/proc/topic_all_peers(raw_topic)
	// Someone here is going to say "AA you shouldnt put load on the DB server you can do sorting in BYOND"
	// Well let me put it this way. The DB server is an entirely different machine to BYOND, with this entire dataset being stored in its RAM, not even on disk
	// By making the DB server do the work, we can offload from BYOND, which is already strained
	var/datum/db_query/dbq1 = SSdbcore.NewQuery({"
		SELECT server_id, key_name, key_value FROM instance_data_cache WHERE server_id IN
		(SELECT server_id FROM instance_data_cache WHERE server_id !=:sid AND
		key_name='heartbeat' AND last_updated BETWEEN NOW() - INTERVAL 60 SECOND AND NOW())
		AND key_name IN ("topic_key", "internal_ip", "server_port")"}, list(
		"sid" = GLOB.configuration.system.instance_id
	))
	if(!dbq1.warn_execute())
		qdel(dbq1)
		return

	var/servers_outer = list()
	while(dbq1.NextRow())
		if(!servers_outer[dbq1.item[1]])
			servers_outer[dbq1.item[1]] = list()

		servers_outer[dbq1.item[1]][dbq1.item[2]] = dbq1.item[3] // This should assoc load our data

	qdel(dbq1)

	for(var/server in servers_outer)
		var/server_data = servers_outer[server]
		world.Export("byond://[server_data["internal_ip"]]:[server_data["server_port"]]?[raw_topic]&key=[server_data["topic_key"]]")


/**
  * Player checker
  *
  * Check all connected peers to see if a player exists in the player cache
  * This is used to make sure players dont log into 2 servers at once
  * Arguments:
  * ckey - The ckey to check if they are logged into another server
  */
/datum/controller/subsystem/instancing/proc/check_player(ckey)
	// Please see above rant on L127
	var/datum/db_query/dbq1 = SSdbcore.NewQuery({"
		SELECT server_id, key_value FROM instance_data_cache WHERE server_id IN
		(SELECT server_id FROM instance_data_cache WHERE server_id != :sid AND
		key_name='heartbeat' AND last_updated BETWEEN NOW() - INTERVAL 60 SECOND AND NOW())
		AND key_name IN ("playerlist")"}, list(
		"sid" = GLOB.configuration.system.instance_id
	))
	if(!dbq1.warn_execute())
		qdel(dbq1)
		return

	while(dbq1.NextRow())
		var/list/other_server_cache = json_decode(dbq1.item[2])
		if(ckey in other_server_cache)
			var/target_server = dbq1.item[1] // Yes. This var is necessary.
			qdel(dbq1)
			return target_server

	qdel(dbq1)
	return null // If we are here, it means we didnt find our player on another server
