/client/proc/cmd_admin_say(msg as text)
	set category = "Special Verbs"
	set name = "Asay" //Gave this shit a shorter name so you only have to time out "asay" rather than "admin say" to use it --NeoFite
	set hidden = 1
	if(!check_rights(R_ADMIN))	return

	msg = sanitize(copytext(msg, 1, MAX_MESSAGE_LEN))
	if(!msg)	return

	log_admin("[key_name(src)] : [msg]")

	if(check_rights(R_ADMIN,0))
		for(var/client/C in admins)
			if(R_ADMIN & C.holder.rights)
				C << "<span class='admin_channel'>ADMIN: <span class='name'>[key_name(usr, 1)]</span> ([admin_jump_link(mob, "holder")]): <span class='message'>[msg]</span></span>"

	feedback_add_details("admin_verb","M") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_mod_say(msg as text)
	set category = "Special Verbs"
	set name = "Msay"
	set hidden = 1

	if(!check_rights(R_ADMIN|R_MOD))	return

	msg = sanitize(copytext(msg, 1, MAX_MESSAGE_LEN))
	log_admin("MOD: [key_name(src)] : [msg]")

	if (!msg)
		return

	var/spanclass = "mod_channel"
	if(check_rights(R_ADMIN, 0))
		spanclass = "mod_channel_admin"
	for(var/client/C in admins)
		if(R_MOD & C.holder.rights)
			C << "<span class='[spanclass]'>MOD: <span class='name'>[key_name(usr, 1)]</span> ([admin_jump_link(mob, C.holder)]): <span class='message'>[msg]</span></span>"

	feedback_add_details("admin_verb","MS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!