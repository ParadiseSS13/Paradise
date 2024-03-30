/**
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

SUBSYSTEM_DEF(chat)
	name = "Chat"
	flags = SS_TICKER|SS_NO_INIT
	wait = 1
	priority = FIRE_PRIORITY_CHAT
	init_order = INIT_ORDER_CHAT
	offline_implications = "Chat will no longer function correctly. Immediate server restart recommended."

	/// Associates a ckey with a list of messages to send to them.
	var/list/list/datum/chat_payload/client_to_payloads = list()

	/// Associates a ckey with an associative list of their last CHAT_RELIABILITY_HISTORY_SIZE messages.
	var/list/list/datum/chat_payload/client_to_reliability_history = list()

	/// Associates a ckey with their next sequence number.
	var/list/client_to_sequence_number = list()
	var/misdeliver_count = 0

/datum/controller/subsystem/chat/proc/generate_payload(client/target, message_data, mob_target, list/targets)
	var/sequence = client_to_sequence_number[target.ckey]
	client_to_sequence_number[target.ckey] += 1

	var/datum/chat_payload/payload = new
	payload.sequence = sequence
	payload.content = message_data
	payload.target = mob_target
	payload.targets = targets

	if(!(target.ckey in client_to_reliability_history))
		client_to_reliability_history[target.ckey] = list()
	var/list/client_history = client_to_reliability_history[target.ckey]
	client_history["[sequence]"] = payload

	if(length(client_history) > CHAT_RELIABILITY_HISTORY_SIZE)
		var/oldest = text2num(client_history[1])
		for(var/index in 2 to length(client_history))
			var/test = text2num(client_history[index])
			if(test < oldest)
				oldest = test
		client_history -= "[oldest]"
	return payload

/datum/controller/subsystem/chat/proc/send_payload_to_client(client/target, datum/chat_payload/payload)
	payload.delivery_attempt++
	target.tgui_panel.window.send_message("chat/message", payload.into_message())
	SEND_TEXT(target, payload.get_content_as_html())
	if(!payload.target)
		return
	var/client/original_client = CLIENT_FROM_VAR(payload.target)
	if(target == original_client)
		return

	// GOT YOU!
	misdeliver_count++
	if(misdeliver_count > 5)
		return

	log_debug("Misdelivered chat payload found, please send this to FunnyMan in Discord!")
	log_debug("Payload sent to mob [target.mob], ckey [target.ckey] on delivery attempt [payload.delivery_attempt]")
	log_debug("Originally set to mob [payload.target], ckey [original_client?.ckey]")
	log_debug("[length(payload.targets)] initial targets")

/datum/controller/subsystem/chat/fire()
	for(var/ckey in client_to_payloads)
		var/client/target = GLOB.directory[ckey]
		if(isnull(target)) // verify client still exists
			LAZYREMOVE(client_to_payloads, ckey)
			continue

		for(var/datum/chat_payload/payload as anything in client_to_payloads[ckey])
			send_payload_to_client(target, payload)
		LAZYREMOVE(client_to_payloads, ckey)

		if(MC_TICK_CHECK)
			return

/datum/controller/subsystem/chat/proc/queue(queue_target, list/message_data)
	var/list/targets = islist(queue_target) ? queue_target : list(queue_target)
	for(var/target in targets)
		var/client/client = CLIENT_FROM_VAR(target)
		if(isnull(client))
			continue
		LAZYADDASSOC(client_to_payloads, client.ckey, generate_payload(client, message_data, target, targets))

/datum/controller/subsystem/chat/proc/send_immediate(send_target, list/message_data)
	var/list/targets = islist(send_target) ? send_target : list(send_target)
	for(var/target in targets)
		var/client/client = CLIENT_FROM_VAR(target)
		if(isnull(client))
			continue
		send_payload_to_client(client, generate_payload(client, message_data, target, targets))

/datum/controller/subsystem/chat/proc/handle_resend(client/client, sequence)
	var/list/client_history = client_to_reliability_history[client.ckey]
	sequence = "[sequence]"
	if(isnull(client_history) || !(sequence in client_history))
		return

	var/datum/chat_payload/payload = client_history[sequence]
	if(payload.resends > CHAT_RELIABILITY_MAX_RESENDS)
		return // we tried but byond said no

	payload.resends += 1
	send_payload_to_client(client, client_history[sequence])
	SSblackbox.record_feedback(
		"nested tally",
		"chat_resend_byond_version",
		1,
		list(
			"[client.byond_version]",
			"[client.byond_build]",
		),
	)
