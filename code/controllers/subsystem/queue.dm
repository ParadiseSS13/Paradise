SUBSYSTEM_DEF(queue)
	name = "QueueWebhook"
	flags = SS_NO_FIRE
	/// Is the SS enabled
	var/enabled = FALSE
	var/max_slots = 100
	var/occupied_slots = 0

/datum/controller/subsystem/queue/Initialize(start_timeofday)
	if(config.queue_engine_enabled)
		enabled = TRUE
		send_status(TRUE)

	return ..()

// This is designed for ease of simplicity for sending quick messages from parts of the code
/datum/controller/subsystem/queue/proc/send_status(force = FALSE)
	if(!enabled || (!force && !(Master?.current_runlevel & (RUNLEVEL_LOBBY | RUNLEVEL_SETUP | RUNLEVEL_GAME))))
		return

	var/staff = 0
	var/regular_players = 0
	for(var/client/C in GLOB.clients)
		if(check_rights(R_ADMIN|R_MOD|R_MENTOR, 0, C.mob) || C.ckey in GLOB.deadmins)
			staff++
		else
			regular_players++

	occupied_slots = regular_players

	var/list/status = list()
	status["max_slots"] += max_slots
	status["occupied_slots"] += occupied_slots
	status["staff"] += staff

	SShttp.create_async_request(RUSTG_HTTP_METHOD_POST, config.queue_engine_webhook, json_encode(status), list("content-type" = "application/json"))

