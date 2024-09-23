#define QUEUE_DATA_FILE "data/queue_data.json"
// These are defines for the sake of making sure we get the right keys
#define QUEUE_DATA_FILE_THRESHOLD_KEY "threshold"
#define QUEUE_DATA_FILE_ENABLED_KEY "enabled"
#define QUEUE_DATA_FILE_PERSISTENT_KEY "persistent"

SUBSYSTEM_DEF(queue)
	name = "Server Queue"
	init_order = INIT_ORDER_QUEUE // 100
	flags = SS_NO_FIRE
	/// Threshold of players to queue new people
	var/queue_threshold = 0
	/// Whether the queue is enabled or not
	var/queue_enabled = FALSE
	/// Whether to persist these settings over multiple rounds
	var/persist_queue = FALSE
	/// List of ckeys allowed to bypass queue this round
	var/list/queue_bypass_list = list()
	/// Last world.time we let a ckey in. 3 second delay between each letin to avoid a mass bubble
	var/last_letin_time = 0

/datum/controller/subsystem/queue/Initialize()
	if(fexists(QUEUE_DATA_FILE))
		try
			var/F = file2text(QUEUE_DATA_FILE)
			var/list/data = json_decode(F)
			queue_threshold = data[QUEUE_DATA_FILE_THRESHOLD_KEY]
			queue_enabled = data[QUEUE_DATA_FILE_ENABLED_KEY]
			persist_queue = data[QUEUE_DATA_FILE_PERSISTENT_KEY]
		catch
			stack_trace("Failed to load [QUEUE_DATA_FILE] from disk due to malformed JSON. You may need to setup the queue again.")


/datum/controller/subsystem/queue/Shutdown()
	// Save if persistent
	if(persist_queue)
		if(fexists(QUEUE_DATA_FILE))
			fdel(QUEUE_DATA_FILE)
		var/data = list()
		data[QUEUE_DATA_FILE_THRESHOLD_KEY] = queue_threshold
		data[QUEUE_DATA_FILE_ENABLED_KEY] = queue_enabled
		data[QUEUE_DATA_FILE_PERSISTENT_KEY] = persist_queue
		var/json_data = json_encode(data)
		text2file(json_data, QUEUE_DATA_FILE)

#undef QUEUE_DATA_FILE
#undef QUEUE_DATA_FILE_THRESHOLD_KEY
#undef QUEUE_DATA_FILE_ENABLED_KEY
#undef QUEUE_DATA_FILE_PERSISTENT_KEY
