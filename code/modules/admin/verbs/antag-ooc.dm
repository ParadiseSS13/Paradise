ADMIN_VERB(aooc, R_ADMIN, "AOOC", "Antagonist OOC", VERB_CATEGORY_OOC, msg as text)
	msg = sanitize(msg)
	if(!msg)	return

	var/display_name = user.key
	if(user.holder && user.holder.fakekey)
		display_name = user.holder.fakekey

	for(var/mob/M in GLOB.mob_list)
		if((M.mind && M.mind.special_role && M.client) || (M.client && M.client.holder && (M.client.holder.rights & R_ADMIN)))
			to_chat(M, "<font color='#960018'><span class='ooc'><span class='prefix'>AOOC:</span> <EM>[display_name]:</EM> <span class='message'>[msg]</span></span></font>")

	log_aooc(msg, src)
