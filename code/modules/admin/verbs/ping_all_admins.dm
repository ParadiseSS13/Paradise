USER_VERB(ping_all_admins, R_ADMIN, "Ping all admins", "Ping all admins", VERB_CATEGORY_ADMIN)
	var/msg = input(client, "What message do you want the ping to show?", "Ping all admins") as text|null
	msg = sanitize(copytext_char(msg, 1, MAX_MESSAGE_LEN))

	if(!msg)
		return

	var/list/admins_to_ping = list()

	for(var/client/C in GLOB.admins)
		if(R_ADMIN & C.holder.rights)
			admins_to_ping += C

	var/de_admin_also = alert(client, "Do you want to ping admins that have used de-admin?","Ping all admins", "Yes", "No")
	if(de_admin_also == "Yes")
		for(var/key in GLOB.de_admins)
			var/client/C = GLOB.directory[client.ckey]
			if(!C)
				continue
			admins_to_ping += C

	if(length(admins_to_ping) < 2) // All by yourself?
		to_chat(client, "<span class='boldannounceooc'>No other admins online to ping[de_admin_also == "Yes" ? ", including those that have used de-admin" : ""]!</span>")
		return

	var/datum/say/asay = new(client.ckey, client.holder.rank, msg, world.timeofday)
	GLOB.asays += asay
	log_ping_all_admins("[length(admins_to_ping)] clients pinged: [msg]", client)

	for(var/client/C in admins_to_ping)
		SEND_SOUND(C, sound('sound/misc/ping.ogg'))
		to_chat(C, "<span class='all_admin_ping'>ALL ADMIN PING: <span class='name'>[key_name(client, TRUE)]</span> ([admin_jump_link(client.mob)]): <span class='emoji_enabled'>[msg]</span></span>")
	to_chat(client, "[length(admins_to_ping)] clients pinged.")
