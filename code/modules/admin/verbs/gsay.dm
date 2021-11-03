// GSAY
// Like asay but global between instances!
// *Insert changeling hivemind :g joke here*

/client/proc/gsay(msg as text)
	set name = "gsay"
	set hidden = TRUE
	if(!check_rights(R_ADMIN))
		return

	if(!msg)
		return
	msg = sanitize(copytext(msg, 1, MAX_MESSAGE_LEN))

	// To whoever says "Why dont you just topic the full message with formatting"
	// This lets us use this in other apps, like a discord bot, without HTML parsing
	// It also removes a way to put whatever HTML we want in the chat window
	var/built_topic = "gsay&msg=[url_encode(msg)]&usr=[url_encode(usr.ckey)]&src=[url_encode(GLOB.configuration.system.instance_id)]"

	// Send to peers
	SSinstancing.topic_all_peers(built_topic)
	// Send to online admins
	for(var/client/C in GLOB.admins)
		if(R_ADMIN & C.holder.rights)
			to_chat(C, "<span class='admin_channel'>GSAY: [usr.ckey]@[GLOB.configuration.system.instance_id]: [msg]</span>")

	SSblackbox.record_feedback("tally", "admin_verb", 1, "gsay") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
