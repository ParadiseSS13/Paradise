// GSAY
// Like asay but global between instances!
// *Insert changeling hivemind :g joke here*

// TODO - May as well fold this into regular asay. We already have it global enough with the discord integration.
// Same with msay
/client/proc/gsay(msg as text)
	set name = "gsay"
	set hidden = TRUE
	if(!check_rights(R_ADMIN))
		return

	if(!msg)
		return

	// Sanitize it all
	msg = sanitize(copytext(msg, 1, MAX_MESSAGE_LEN))

	var/datum/server_command/gsay/GS = SSinstancing.registered_commands["gsay"]
	GS.custom_dispatch(usr.ckey, msg)

	// Send to online admins
	for(var/client/C in GLOB.admins)
		if(C.holder.rights & R_ADMIN)
			to_chat(C, "<span class='admin_channel'>GSAY: [usr.ckey]@[GLOB.configuration.system.instance_id]: [msg]</span>")

	SSblackbox.record_feedback("tally", "admin_verb", 1, "gsay") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
