/client/proc/cmd_admin_say(msg as text)
	set category = "Admin"
	set name = "Asay" //Gave this shit a shorter name so you only have to time out "asay" rather than "admin say" to use it --NeoFite
	set hidden = 1
	if(!check_rights(R_ADMIN))	return

	msg = sanitize(copytext(msg, 1, MAX_MESSAGE_LEN))
	if(!msg)	return

	log_adminsay(msg, src)

	if(check_rights(R_ADMIN,0))
		for(var/client/C in GLOB.admins)
			if(R_ADMIN & C.holder.rights)
				msg = "<span class='emoji_enabled'>[msg]</span>"
				to_chat(C, "<span class='admin_channel'>ADMIN: <span class='name'>[key_name(usr, 1)]</span> ([admin_jump_link(mob)]): <span class='message'>[msg]</span></span>")

	feedback_add_details("admin_verb","M") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_mentor_say(msg as text)
	set category = "Admin"
	set name = "Msay"
	set hidden = 1

	if(!check_rights(R_ADMIN|R_MOD|R_MENTOR))
		return

	msg = sanitize(copytext(msg, 1, MAX_MESSAGE_LEN))
	log_mentorsay(msg, src)

	if(!msg)
		return

	for(var/client/C in GLOB.admins)
		if(check_rights(R_ADMIN|R_MOD|R_MENTOR, 0, C.mob))
			var/display_name = key
			if(holder.fakekey)
				if(C.holder && C.holder.rights & R_ADMIN)
					display_name = "[holder.fakekey]/([key])"
				else
					display_name = holder.fakekey
			msg = "<span class='emoji_enabled'>[msg]</span>"
			to_chat(C, "<span class='[check_rights(R_ADMIN, 0) ? "mentor_channel_admin" : "mentor_channel"]'>MENTOR: <span class='name'>[display_name]</span> ([admin_jump_link(mob)]): <span class='message'>[msg]</span></span>")

	feedback_add_details("admin_verb","MS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/toggle_mentor_chat()
	set category = "Server"
	set name = "Toggle Mentor Chat"
	set desc = "Toggle whether mentors have access to the msay command"

	if(!check_rights(R_ADMIN))
		return

	var/enabling
	var/msay = /client/proc/cmd_mentor_say

	if(msay in admin_verbs_mentor)
		enabling = FALSE
		admin_verbs_mentor -= msay
	else
		enabling = TRUE
		admin_verbs_mentor += msay

	for(var/client/C in GLOB.admins)
		if(check_rights(R_ADMIN|R_MOD, 0, C.mob))
			continue
		if(!check_rights(R_MENTOR, 0, C.mob))
			continue
		if(enabling)
			C.verbs += msay
			to_chat(C, "<b>Mentor chat has been enabled.</b> Use 'msay' to speak in it.")
		else
			C.verbs -= msay
			to_chat(C, "<b>Mentor chat has been disabled.</b>")

	admin_log_and_message_admins("toggled mentor chat [enabling ? "on" : "off"].")
	feedback_add_details("admin_verb", "TMC")
