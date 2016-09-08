/mob/living/verb/pray(msg as text)
	set category = "IC"
	set name = "Pray"

	msg = sanitize(copytext(msg, 1, MAX_MESSAGE_LEN))
	if(!msg)	return

	if(usr.client)
		if(usr.client.prefs.muted & MUTE_PRAY)
			to_chat(usr, "\red You cannot pray (muted).")
			return
		if(src.client.handle_spam_prevention(msg,MUTE_PRAY))
			return

	var/image/cross = image('icons/obj/storage.dmi',"bible")
	msg = "\blue [bicon(cross)] <b><font color=purple>PRAY: </font>[key_name(src, 1)] (<A HREF='?_src_=holder;adminmoreinfo=\ref[src]'>?</A>) (<A HREF='?_src_=holder;adminplayeropts=\ref[src]'>PP</A>) (<A HREF='?_src_=vars;Vars=[UID()]'>VV</A>) (<A HREF='?_src_=holder;subtlemessage=\ref[src]'>SM</A>) ([admin_jump_link(src)]) (<A HREF='?_src_=holder;secretsadmin=check_antagonist'>CA</A>) (<A HREF='?_src_=holder;adminspawncookie=\ref[src]'>SC</a>):</b> [msg]"

	for(var/client/X in admins)
		if(check_rights(R_EVENT,0,X.mob))
			to_chat(X, msg)
	to_chat(usr, "Your prayers have been received by the gods.")

	feedback_add_details("admin_verb","PR") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	//log_admin("HELP: [key_name(src)]: [msg]")

/proc/Centcomm_announce(var/text , var/mob/Sender)
	var/msg = sanitize(copytext(text, 1, MAX_MESSAGE_LEN))
	msg = "<span class='boldnotice'><font color=orange>CENTCOMM: </font>[key_name(Sender, 1)] (<A HREF='?_src_=holder;adminplayeropts=\ref[Sender]'>PP</A>) (<A HREF='?_src_=vars;Vars=[Sender.UID()]'>VV</A>) (<A HREF='?_src_=holder;subtlemessage=\ref[Sender]'>SM</A>) ([admin_jump_link(Sender)]) (<A HREF='?_src_=holder;secretsadmin=check_antagonist'>CA</A>) (<A HREF='?_src_=holder;BlueSpaceArtillery=\ref[Sender]'>BSA</A>) (<A HREF='?_src_=holder;CentcommReply=\ref[Sender]'>RPLY</A>):</span> [msg]"
	for(var/client/X in admins)
		if(R_EVENT & X.holder.rights)
			to_chat(X, msg)
			if(X.prefs.sound & SOUND_ADMINHELP)
				X << 'sound/effects/adminhelp.ogg'

/proc/Syndicate_announce(var/text , var/mob/Sender)
	var/msg = sanitize(copytext(text, 1, MAX_MESSAGE_LEN))
	msg = "<span class='boldnotice'><font color='#DC143C'>SYNDICATE: </font>[key_name(Sender, 1)] (<A HREF='?_src_=holder;adminplayeropts=\ref[Sender]'>PP</A>) (<A HREF='?_src_=vars;Vars=[Sender.UID()]'>VV</A>) (<A HREF='?_src_=holder;subtlemessage=\ref[Sender]'>SM</A>) ([admin_jump_link(Sender)]) (<A HREF='?_src_=holder;secretsadmin=check_antagonist'>CA</A>) (<A HREF='?_src_=holder;BlueSpaceArtillery=\ref[Sender]'>BSA</A>) (<A HREF='?_src_=holder;SyndicateReply=\ref[Sender]'>REPLY</A>):</span> [msg]"
	for(var/client/X in admins)
		if(check_rights(R_EVENT,0,X.mob))
			to_chat(X, msg)
			if(X.prefs.sound & SOUND_ADMINHELP)
				X << 'sound/effects/adminhelp.ogg'

/proc/HONK_announce(var/text , var/mob/Sender)
	var/msg = sanitize(copytext(text, 1, MAX_MESSAGE_LEN))
	msg = "<span class='boldnotice'><font color=pink>HONK: </font>[key_name(Sender, 1)] (<A HREF='?_src_=holder;adminplayeropts=\ref[Sender]'>PP</A>) (<A HREF='?_src_=vars;Vars=[Sender.UID()]'>VV</A>) (<A HREF='?_src_=holder;subtlemessage=\ref[Sender]'>SM</A>) ([admin_jump_link(Sender)]) (<A HREF='?_src_=holder;secretsadmin=check_antagonist'>CA</A>) (<A HREF='?_src_=holder;BlueSpaceArtillery=\ref[Sender]'>BSA</A>) (<A HREF='?_src_=holder;HONKReply=\ref[Sender]'>RPLY</A>):</span> [msg]"
	for(var/client/X in admins)
		if(R_EVENT & X.holder.rights)
			to_chat(X, msg)
			if(X.prefs.sound & SOUND_ADMINHELP)
				X << 'sound/effects/adminhelp.ogg'

/proc/ERT_Announce(var/text , var/mob/Sender, var/repeat_warning)
	var/msg = sanitize(copytext(text, 1, MAX_MESSAGE_LEN))
	msg = "<span class='adminnotice'><b><font color=orange>ERT REQUEST: </font>[key_name(Sender, 1)] (<A HREF='?_src_=holder;adminplayeropts=\ref[Sender]'>PP</A>) (<A HREF='?_src_=vars;Vars=[Sender.UID()]'>VV</A>) (<A HREF='?_src_=holder;subtlemessage=\ref[Sender]'>SM</A>) ([admin_jump_link(Sender)]) (<A HREF='?_src_=holder;secretsadmin=check_antagonist'>CA</A>) (<A HREF='?_src_=holder;BlueSpaceArtillery=\ref[Sender]'>BSA</A>) (<A HREF='?_src_=holder;ErtReply=\ref[Sender]'>RESPOND</A>):</b> [msg]</span>"
	if(repeat_warning)
		msg += "<BR><span class='adminnotice'><b>WARNING: ERT request has gone 5 minutes with no reply!</b></span>"
	for(var/client/X in admins)
		if(check_rights(R_EVENT,0,X.mob))
			to_chat(X, msg)
			if(X.prefs.sound & SOUND_ADMINHELP)
				X << 'sound/effects/adminhelp.ogg'

/proc/Nuke_request(text , mob/Sender)
	var/nuke_code = get_nuke_code()
	var/msg = sanitize(copytext(text, 1, MAX_MESSAGE_LEN))
	msg = "<span class='adminnotice'><b><font color=orange>NUKE CODE REQUEST: </font>[key_name(Sender)] (<A HREF='?_src_=holder;adminplayeropts=\ref[Sender]'>PP</A>) (<A HREF='?_src_=vars;Vars=[Sender.UID()]'>VV</A>) (<A HREF='?_src_=holder;subtlemessage=\ref[Sender]'>SM</A>) ([admin_jump_link(Sender)]) (<A HREF='?_src_=holder;secretsadmin=check_antagonist'>CA</A>) (<A HREF='?_src_=holder;BlueSpaceArtillery=\ref[Sender]'>BSA</A>) (<A HREF='?_src_=holder;CentcommReply=\ref[Sender]'>RPLY</A>):</b> [msg]</span>"
	for(var/client/X in admins)
		if(check_rights(R_EVENT,0,X.mob))
			to_chat(X, msg)
			to_chat(X, "<span class='adminnotice'><b>The nuke code is [nuke_code].</b></span>")
			if(X.prefs.sound & SOUND_ADMINHELP)
				X << 'sound/effects/adminhelp.ogg'