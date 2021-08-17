/**
  * # Peer server
  *
  * This datum is essentially a model class to represent another instance of Paracode running
  *
  * It contains communications passes, an internal IP to communicate to, an external IP for players to connect to
  *
  */
/datum/peer_server
	// The following options will be loaded from configuration
	/// Peer server internal IP, used for communications
	var/internal_ip
	/// Port of the server
	var/server_port = 0
	/// Comms key for this server
	var/commskey

	// The following options will be pulled from the peer at runtime
	/// Peer server external IP, used for routing players around
	var/external_ip
	/// Peer server ID, used internally. Pulled from the peer on startup.
	var/server_id
	/// Peer server name, presented to players. Pulled from the peer on startup.
	var/server_name
	/// Have we done initial data discovery yet?
	var/discovered = FALSE
	/// Is the peer server online?
	var/online = FALSE
	/// Playercount of the peer server on last ping
	var/playercount
	/// Last world.time that an operation was attempted
	var/last_operation_time = 0
