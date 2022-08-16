GLOBAL_DATUM_INIT(requests, /datum/request_manager, new)

/**
 * # Request Manager
 *
 * Handles all player requests (prayers, centcom requests, syndicate requests)
 * that occur in the duration of a round.
 */
/datum/request_manager
	/// Associative list of ckey -> list of requests
	var/list/requests = list()
	/// List where requests can be accessed by ID
	var/list/requests_by_id = list()

/datum/request_manager/Destroy(force, ...)
	QDEL_LIST(requests)
	return ..()

/datum/request_manager/proc/client_login(client/C)
	if (!requests[C.ckey])
		return
	for (var/datum/request/request as anything in requests[C.ckey])
		request.owner = C

/datum/request_manager/proc/pray(client/C, message, is_chaplain)
	request_for_client(C, REQUEST_PRAYER, message)

/datum/request_manager/proc/message_centcom(client/C, message)
	request_for_client(C, REQUEST_CENTCOM, message)

/datum/request_manager/proc/message_syndicate(client/C, message)
	request_for_client(C, REQUEST_SYNDICATE, message)

/datum/request_manager/proc/request_ert(client/C, message)
	request_for_client(C, REQUEST_ERT, message)

/datum/request_manager/proc/message_honk(client/C, message)
	request_for_client(C, REQUEST_HONK, message)

/datum/request_manager/proc/nuke_request(client/C, message)
	request_for_client(C, REQUEST_NUKE, message)

/**
 * Creates a request and registers the request with all necessary internal tracking lists
 *
 * Arguments:
 * * C - The client who is sending the request
 * * type - The type of request, see defines
 * * message - The message
 */
/datum/request_manager/proc/request_for_client(client/C, type, message)
	var/datum/request/request = new(C, type, message)
	if (!requests[C.ckey])
		requests[C.ckey] = list()
	requests[C.ckey] += request
	requests_by_id.len++
	requests_by_id[request.id] = request

/datum/request_manager/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.admin_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "RequestManager", "Requests", 575, 600, master_ui, state)
		ui.autoupdate = TRUE
		ui.open()

/datum/request_manager/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if (..())
		return

	// Only admins should be sending actions
	if (!check_rights(R_ADMIN))
		to_chat(usr, "You do not have permission to do this, you require +ADMIN")
		return

	// Get the request this relates to
	var/id = params["id"] != null ? text2num(params["id"]) : null
	if (!id)
		to_chat(usr, "Failed to find a request ID in your action, please report this")
		CRASH("Received an action without a request ID, this shouldn't happen!")
	var/datum/request/request = !id ? null : requests_by_id[id]

	switch(action)
		if ("pp")
			var/mob/M = request.owner?.mob
			usr.client.holder.show_player_panel(M)
			return TRUE
		if ("vv")
			var/mob/M = request.owner?.mob
			usr.client.debug_variables(M)
			return TRUE
		if ("sm")
			var/mob/M = request.owner?.mob
			usr.client.cmd_admin_subtle_message(M)
			return TRUE
		if ("tp")
			if(!SSticker.HasRoundStarted())
				alert(usr,"The game hasn't started yet!")
				return TRUE
			var/mob/M = request.owner?.mob
			usr.client.holder.show_traitor_panel(M)
			return TRUE
		if ("logs")
			var/mob/M = request.owner?.mob
			if(!ismob(M))
				to_chat(usr, "This can only be used on instances of type /mob.")
				return TRUE
			usr.client.open_logging_view(list(M), TRUE)
			return TRUE
		if ("bless")
			if(!check_rights(R_EVENT))
				to_chat(usr, "Insufficient permissions to bless, you require +EVENT")
				return TRUE
			var/mob/living/M = request.owner?.mob
			usr.client.bless(M)
			return TRUE
		if ("smite")
			if(!check_rights(R_EVENT))
				to_chat(usr, "Insufficient permissions to smite, you require +EVENT")
				return TRUE
			var/mob/living/M = request.owner?.mob
			usr.client.smite(M)
			return TRUE
		if ("rply")
			if (request.req_type == REQUEST_PRAYER)
				to_chat(usr, "Cannot reply to a prayer")
				return TRUE
			var/mob/M = request.owner?.mob
			usr.client.admin_headset_message(M, request.req_type == REQUEST_SYNDICATE ? "Syndicate" : "Centcomm")
			return TRUE
		if ("ertreply")
			if (request.req_type != REQUEST_ERT)
				to_chat(usr, "You cannot respond with ert for a non-ert-request request!")
				return TRUE
			if(alert(usr, "Accept or Deny ERT request?", "CentComm Response", "Accept", "Deny") == "Deny")
				var/mob/living/carbon/human/H = request.owner?.mob
				if(!istype(H))
					to_chat(usr, "<span class='warning'>This can only be used on instances of type /mob/living/carbon/human</span>")
					return
				if(H.stat != 0)
					to_chat(usr, "<span class='warning'>The person you are trying to contact is not conscious.</span>")
					return
				if(!istype(H.l_ear, /obj/item/radio/headset) && !istype(H.r_ear, /obj/item/radio/headset))
					to_chat(usr, "<span class='warning'>The person you are trying to contact is not wearing a headset</span>")
					return

				var/input = input(usr, "Please enter a reason for denying [key_name(H)]'s ERT request.","Outgoing message from CentComm", "")
				if(!input)	return
				GLOB.ert_request_answered = TRUE
				to_chat(usr, "You sent [input] to [H] via a secure channel.")
				log_admin("[usr] denied [key_name(H)]'s ERT request with the message [input].")
				to_chat(H, "<span class='specialnoticebold'>Incoming priority transmission from Central Command. Message as follows,</span><span class='specialnotice'> Your ERT request has been denied for the following reasons: [input].</span>")
			else
				usr.client.response_team()
		if ("getcode")
			if(request.req_type != REQUEST_NUKE)
				to_chat(usr, "<span class='warning'>Warning! That this is a non-nuke-code-request request!</span>")
			to_chat(usr, "<b>The nuke code is: [get_nuke_code()]!</b>")
			return TRUE

/datum/request_manager/ui_data(mob/user)
	. = list(
		"requests" = list()
	)
	for (var/ckey in requests)
		for (var/datum/request/request as anything in requests[ckey])
			var/list/data = list(
				"id" = request.id,
				"req_type" = request.req_type,
				"owner" = request.owner,
				"owner_ckey" = request.owner_ckey,
				"owner_name" = request.owner_name,
				"message" = request.message,
				"timestamp" = request.timestamp,
				"timestamp_str" = gameTimestamp(wtime = request.timestamp)
			)
			.["requests"] += list(data)

