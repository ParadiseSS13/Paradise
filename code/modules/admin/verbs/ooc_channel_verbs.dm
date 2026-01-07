USER_VERB(aooc, R_ADMIN, "AOOC", "Antagonist OOC", VERB_CATEGORY_OOC, msg as text)
	msg = sanitize(msg)
	if(!msg)	return

	var/display_name = client.key
	if(client.holder && client.holder.fakekey)
		display_name = client.holder.fakekey

	for(var/mob/M in GLOB.mob_list)
		if((M.mind && M.mind.special_role && M.client) || (M.client && M.client.holder && (M.client.holder.rights & R_ADMIN)))
			to_chat(M, "<font color='#960018'>[SPAN_OOC("[SPAN_PREFIX("AOOC:")] <EM>[display_name]:</EM> [SPAN_MESSAGE("[msg]")]")]</font>")

	log_aooc(msg, client)

USER_VERB(announce, R_ADMIN, "Announce", "Announce your desires to the world", VERB_CATEGORY_ADMIN)
	var/message = input(client, "Global message to send:", "Admin Announce", null) as message|null
	if(message)
		if(!check_rights_client(R_SERVER, 0, client))
			message = adminscrub(message,500)
		message = replacetext(message, "\n", "<br>") // required since we're putting it in a <p> tag
		to_chat(world, chat_box_notice(SPAN_NOTICE("<b>[client.holder.fakekey ? "Administrator" : client.key] Announces:</b><br><br><p>[message]</p>")))
		log_admin("Announce: [key_name(client)] : [message]")
		for(var/client/clients_to_alert in GLOB.clients)
			window_flash(clients_to_alert)
			if(clients_to_alert.prefs?.sound & SOUND_ADMINHELP)
				SEND_SOUND(clients_to_alert, sound('sound/misc/server_alert.ogg'))

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Announce") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

USER_VERB(toggle_ooc, R_ADMIN, "Toggle OOC", "Globally Toggles OOC", VERB_CATEGORY_SERVER)
	toggle_ooc()
	log_and_message_admins("toggled OOC.")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Toggle OOC") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

USER_VERB(toggle_looc, R_ADMIN, "Toggle LOOC", "Globally Toggles LOOC", VERB_CATEGORY_SERVER)
	GLOB.looc_enabled = !(GLOB.looc_enabled)
	if(GLOB.looc_enabled)
		to_chat(world, "<B>The LOOC channel has been globally enabled!</B>")
	else
		to_chat(world, "<B>The LOOC channel has been globally disabled!</B>")
	log_and_message_admins("toggled LOOC.")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Toggle LOOC") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

USER_VERB(toggle_dsay, R_ADMIN, "Toggle DSAY", "Globally Toggles DSAY", VERB_CATEGORY_SERVER)
	GLOB.dsay_enabled = !(GLOB.dsay_enabled)
	if(GLOB.dsay_enabled)
		to_chat(world, "<b>Deadchat has been globally enabled!</b>", MESSAGE_TYPE_DEADCHAT)
	else
		to_chat(world, "<b>Deadchat has been globally disabled!</b>", MESSAGE_TYPE_DEADCHAT)
	log_admin("[key_name(client)] toggled deadchat.")
	message_admins("[key_name_admin(client)] toggled deadchat.", 1)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Toggle Deadchat") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

USER_VERB(toggle_ooc_dead, R_ADMIN, "Toggle Dead OOC", "Toggle Dead OOC.", VERB_CATEGORY_SERVER)
	GLOB.dooc_enabled = !(GLOB.dooc_enabled)
	log_admin("[key_name(client)] toggled Dead OOC.")
	message_admins("[key_name_admin(client)] toggled Dead OOC.", 1)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Toggle Dead OOC") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

USER_VERB(toggle_emoji, R_ADMIN, "Toggle OOC Emoji", "Toggle OOC Emoji", VERB_CATEGORY_SERVER)
	GLOB.configuration.general.enable_ooc_emoji = !(GLOB.configuration.general.enable_ooc_emoji)
	log_admin("[key_name(client)] toggled OOC Emoji.")
	message_admins("[key_name_admin(client)] toggled OOC Emoji.", 1)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Toggle OOC Emoji")
