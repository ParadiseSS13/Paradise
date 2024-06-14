/client/proc/ping_all_admins()
	set name = "Ping all admins"
	set category = "Admin"

	if(!check_rights(R_ADMIN, FALSE))
		return

	var/msg = input(src, "What message do you want the ping to show?", "Ping all admins") as text|null
	msg = sanitize(copytext_char(msg, 1, MAX_MESSAGE_LEN))

	if(!msg)
		return

	var/list/admins_to_ping = list()

	for(var/client/C in GLOB.admins)
		if(R_ADMIN & C.holder.rights)
			admins_to_ping += C

	var/de_admin_also = alert(usr, "Do you want to ping admins that have used de-admin?","Ping all admins", "Yes", "No")
	if(de_admin_also == "Yes")
		for(var/key in GLOB.de_admins)
			var/client/C = GLOB.directory[ckey]
			if(!C)
				continue
			admins_to_ping += C

	if(length(admins_to_ping) < 2) // All by yourself?
		to_chat(usr, "<span class='boldannounceooc'>No other admins online to ping[de_admin_also == "Yes" ? ", including those that have used de-admin" : ""]!</span>")
		return

	var/datum/say/asay = new(usr.ckey, usr.client.holder.rank, msg, world.timeofday)
	GLOB.asays += asay
	log_ping_all_admins("[length(admins_to_ping)] clients pinged: [msg]", src)

	for(var/client/C in admins_to_ping)
		SEND_SOUND(C, sound('sound/misc/ping.ogg'))
		to_chat(C, "<span class='all_admin_ping'>ALL ADMIN PING: <span class='name'>[key_name(usr, TRUE)]</span> ([admin_jump_link(mob)]): <span class='emoji_enabled'>[msg]</span></span>")
	to_chat(usr, "[length(admins_to_ping)] clients pinged.")
