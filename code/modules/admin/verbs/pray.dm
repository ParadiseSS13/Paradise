/mob/living/verb/pray(msg as text)
	set category = "IC"
	set name = "Pray"

	msg = sanitize(copytext(msg, 1, MAX_MESSAGE_LEN))
	if(!msg)	return

	if(usr.client)
		if(usr.client.prefs.muted & MUTE_PRAY)
			usr << "\red You cannot pray (muted)."
			return
		if(src.client.handle_spam_prevention(msg,MUTE_PRAY))
			return

	var/image/cross = image('icons/obj/storage.dmi',"bible")
	msg = "\blue \icon[cross] <b><font color=purple>PRAY: </font>[key_name(src, 1)] (<A HREF='?_src_=holder;adminmoreinfo=\ref[src]'>?</A>) (<A HREF='?_src_=holder;adminplayeropts=\ref[src]'>PP</A>) (<A HREF='?_src_=vars;Vars=\ref[src]'>VV</A>) (<A HREF='?_src_=holder;subtlemessage=\ref[src]'>SM</A>) ([admin_jump_link(src, "holder")]) (<A HREF='?_src_=holder;secretsadmin=check_antagonist'>CA</A>) (<A HREF='?_src_=holder;adminspawncookie=\ref[src]'>SC</a>):</b> [msg]"

	for(var/client/X in admins)
		if(check_rights(R_EVENT,0,X.mob))
			X << msg

	usr << "Your prayers have been received by the gods."

	feedback_add_details("admin_verb","PR") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	//log_admin("HELP: [key_name(src)]: [msg]")

/proc/Centcomm_announce(var/text , var/mob/Sender)
	var/msg = sanitize(copytext(text, 1, MAX_MESSAGE_LEN))
	msg = "\blue <b><font color=orange>CENTCOMM: </font>[key_name(Sender, 1)] (<A HREF='?_src_=holder;adminplayeropts=\ref[Sender]'>PP</A>) (<A HREF='?_src_=vars;Vars=\ref[Sender]'>VV</A>) (<A HREF='?_src_=holder;subtlemessage=\ref[Sender]'>SM</A>) ([admin_jump_link(Sender, "holder")]) (<A HREF='?_src_=holder;secretsadmin=check_antagonist'>CA</A>) (<A HREF='?_src_=holder;BlueSpaceArtillery=\ref[Sender]'>BSA</A>) (<A HREF='?_src_=holder;CentcommReply=\ref[Sender]'>RPLY</A>):</b> [msg]"

	for(var/client/X in admins)
		if(R_EVENT & X.holder.rights)
			X << msg

/proc/Syndicate_announce(var/text , var/mob/Sender)
	var/msg = sanitize(copytext(text, 1, MAX_MESSAGE_LEN))
	msg = "\blue <b><font color='#DC143C'>SYNDICATE: </font>[key_name(Sender, 1)] (<A HREF='?_src_=holder;adminplayeropts=\ref[Sender]'>PP</A>) (<A HREF='?_src_=vars;Vars=\ref[Sender]'>VV</A>) (<A HREF='?_src_=holder;subtlemessage=\ref[Sender]'>SM</A>) ([admin_jump_link(Sender, "holder")]) (<A HREF='?_src_=holder;secretsadmin=check_antagonist'>CA</A>) (<A HREF='?_src_=holder;BlueSpaceArtillery=\ref[Sender]'>BSA</A>) (<A HREF='?_src_=holder;SyndicateReply=\ref[Sender]'>REPLY</A>):</b> [msg]"

	for(var/client/X in admins)
		if(check_rights(R_EVENT,0,X.mob))
			X << msg

/proc/HONK_announce(var/text , var/mob/Sender)
	var/msg = sanitize(copytext(text, 1, MAX_MESSAGE_LEN))
	msg = "\blue <b><font color=pink>HONK: </font>[key_name(Sender, 1)] (<A HREF='?_src_=holder;adminplayeropts=\ref[Sender]'>PP</A>) (<A HREF='?_src_=vars;Vars=\ref[Sender]'>VV</A>) (<A HREF='?_src_=holder;subtlemessage=\ref[Sender]'>SM</A>) ([admin_jump_link(Sender, "holder")]) (<A HREF='?_src_=holder;secretsadmin=check_antagonist'>CA</A>) (<A HREF='?_src_=holder;BlueSpaceArtillery=\ref[Sender]'>BSA</A>) (<A HREF='?_src_=holder;HONKReply=\ref[Sender]'>RPLY</A>):</b> [msg]"

	for(var/client/X in admins)
		if(R_EVENT & X.holder.rights)
			X << msg

/proc/ERT_Announce(var/text , var/mob/Sender)
	var/msg = sanitize(copytext(text, 1, MAX_MESSAGE_LEN))
	msg = "\blue <b><font color=orange>ERT REQUEST: </font>[key_name(Sender, 1)] (<A HREF='?_src_=holder;adminplayeropts=\ref[Sender]'>PP</A>) (<A HREF='?_src_=vars;Vars=\ref[Sender]'>VV</A>) (<A HREF='?_src_=holder;subtlemessage=\ref[Sender]'>SM</A>) ([admin_jump_link(Sender, "holder")]) (<A HREF='?_src_=holder;secretsadmin=check_antagonist'>CA</A>) (<A HREF='?_src_=holder;BlueSpaceArtillery=\ref[Sender]'>BSA</A>) (<A HREF='?_src_=holder;ErtReply=\ref[Sender]'>REPLY</A>):</b> [msg]"

	for(var/client/X in admins)
		if(check_rights(R_EVENT,0,X.mob))
			X << msg
			
/proc/Nuke_request(text , mob/Sender)
	var/nuke_code = get_nuke_code()
	var/msg = sanitize(copytext(text, 1, MAX_MESSAGE_LEN))
	msg = "<span class='adminnotice'><b><font color=orange>NUKE CODE REQUEST: </font>[key_name(Sender)] (<A HREF='?_src_=holder;adminplayeropts=\ref[Sender]'>PP</A>) (<A HREF='?_src_=vars;Vars=\ref[Sender]'>VV</A>) (<A HREF='?_src_=holder;subtlemessage=\ref[Sender]'>SM</A>) ([admin_jump_link(Sender, "holder")]) (<A HREF='?_src_=holder;secretsadmin=check_antagonist'>CA</A>) (<A HREF='?_src_=holder;BlueSpaceArtillery=\ref[Sender]'>BSA</A>) (<A HREF='?_src_=holder;CentcommReply=\ref[Sender]'>RPLY</A>):</b> [msg]</span>"
	
	for(var/client/X in admins)
		if(check_rights(R_EVENT,0,X.mob))
			X << msg	
			X << "<span class='adminnotice'><b>The nuke code is [nuke_code].</b></span>"
	