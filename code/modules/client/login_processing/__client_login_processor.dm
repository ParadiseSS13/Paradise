/**
  * # Client Login Processor Framework
  *
  * The holder class for all client data processing
  *
  * This framework is designed for loading in client data from the database.
  * Login processors have their own queries, which will be put into one async batch and
  * executed at the same time, to reduce the time it takes for a client to login.
  * Login processors can also be given priorities to have things fire in specific orders
  * EG: Load their preferences before their job bans, etc etc
  *
  * When creating these, please name the files with the priority at the start, and the typepath after
  * EG: 10-load_preferences.dm
  * This makes it easier to track stuff down -AA07
  *
  * Also if you have used other languages before with "interface" types (Java, C# (Microsoft Java), etc),
  * treat this class as one of those. [/datum/client_login_processor/proc/get_query] and
  * [/datum/client_login_processor/proc/process_result] MUST be overriden.
  */
/datum/client_login_processor
	/// The login priority. A lower priority will fire first
	var/priority = 0

/**
  * Query Getter
  *
  * Gets the DB query for this login processor
  *
  * Takes the client as an arg instead of just the ckey incase we need more data (IP, CID, etc).
  * Returns a DB query datum.
  *
  * Arguments:
  * * C - The client to use to generate the query
  */
/datum/client_login_processor/proc/get_query(client/C)
	RETURN_TYPE(/datum/db_query)
	CRASH("get_query() not overridden for [type]!")



/**
  * Result Processor
  *
  * Takes the (now executed) query and the client and parses the required data out
  * Note: This can be a no-op if you want to just update the DB, just return on the override
  *
  * Arguments:
  * * Q - The DB query to process data from
  * * C - The client to store stuff on
  */
/datum/client_login_processor/proc/process_result(datum/db_query/Q, client/C)
	CRASH("process_result() not overridden for [type]!")
