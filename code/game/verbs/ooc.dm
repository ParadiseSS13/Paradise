var/global/normal_ooc_colour = "#002eb8"
var/global/member_ooc_colour = "#035417"
var/global/mentor_ooc_colour = "#0099cc"
var/global/moderator_ooc_colour = "#184880"
var/global/admin_ooc_colour = "#b82e00"

/client/verb/ooc(msg as text)
	set name = "OOC" //Gave this shit a shorter name so you only have to time out "ooc" rather than "ooc message" to use it --NeoFite
	set category = "OOC"

	if(!mob)	return
	if(IsGuestKey(key))
		src << "Guests may not use OOC."
		return

	msg = trim(sanitize(copytext(msg, 1, MAX_MESSAGE_LEN)))
	if(!msg)	return

	if(!(prefs.toggles & CHAT_OOC))
		src << "\red You have OOC muted."
		return

	if(!check_rights(R_MOD,0))
		if(!ooc_allowed)
			src << "\red OOC is globally muted"
			return
		if(!dooc_allowed && (mob.stat == DEAD))
			usr << "\red OOC for dead mobs has been turned off."
			return
		if(prefs.muted & MUTE_OOC)
			src << "\red You cannot use OOC (muted)."
			return
		if(handle_spam_prevention(msg,MUTE_OOC))
			return
		if(findtext(msg, "byond://"))
			src << "<B>Advertising other servers is not allowed.</B>"
			log_admin("[key_name(src)] has attempted to advertise in OOC: [msg]")
			message_admins("[key_name_admin(src)] has attempted to advertise in OOC: [msg]")
			return

	log_ooc("[mob.name]/[key] : [msg]")
	
	var/display_colour = normal_ooc_colour
	if(holder && !holder.fakekey)
		display_colour = mentor_ooc_colour
		if(check_rights(R_MOD,0) && !check_rights(R_ADMIN,0))
			display_colour = moderator_ooc_colour
		else if(check_rights(R_ADMIN,0))
			if(config.allow_admin_ooccolor)
				display_colour = src.prefs.ooccolor
			else
				display_colour = admin_ooc_colour
	
	if(prefs.unlock_content)
		if(display_colour == normal_ooc_colour)
			if((prefs.toggles & MEMBER_PUBLIC))
				display_colour = member_ooc_colour
	
	for(var/client/C in clients)
		if(C.prefs.toggles & CHAT_OOC)
			var/display_name = src.key
			if(prefs.unlock_content)
				if(prefs.toggles & MEMBER_PUBLIC)
					display_name = "<img style='width:9px;height:9px;' class=icon src=\ref['icons/member_content.dmi'] iconstate=blag>[display_name]"
			if(holder)
				if(holder.fakekey)
					if(C.holder)
						display_name = "[holder.fakekey]/([src.key])"
					else
						display_name = holder.fakekey
			C << "<font color='[display_colour]'><span class='ooc'><span class='prefix'>OOC:</span> <EM>[display_name]:</EM> <span class='message'>[msg]</span></span></font>"

/proc/toggle_ooc()
	ooc_allowed = !( ooc_allowed )
	if (ooc_allowed)
		world << "<B>The OOC channel has been globally enabled!</B>"
	else
		world << "<B>The OOC channel has been globally disabled!</B>"

/proc/auto_toggle_ooc(var/on)
	if(config.auto_toggle_ooc_during_round && ooc_allowed != on)
		toggle_ooc()

/client/proc/set_ooc(newColor as color)
	set name = "Set Player OOC Colour"
	set desc = "Modifies the default player OOC color."
	set category = "Server"
	
	if(!check_rights(R_SERVER))	return
	
	normal_ooc_colour = newColor
	message_admins("[key_name_admin(usr)] has set the default player OOC color to [newColor]")
	log_admin("[key_name(usr)] has set the default player OOC color to [newColor]")


	feedback_add_details("admin_verb","SOOC")
	
/client/proc/reset_ooc()
	set name = "Reset Player OOC Color"
	set desc = "Returns the default player OOC color to default."
	set category = "Server"
	
	if(!check_rights(R_SERVER))	return
	
	normal_ooc_colour = initial(normal_ooc_colour)
	message_admins("[key_name_admin(usr)] has reset the default player OOC color")
	log_admin("[key_name(usr)] has reset the default player OOC color")
	
	feedback_add_details("admin_verb","ROOC")
	
/client/proc/colorooc()
	set name = "Set Your OOC Color"
	set desc = "Allows you to pick a custom OOC color."
	set category = "Preferences"

	if(!check_rights(R_ADMIN)) return

	var/new_ooccolor = input(src, "Please select your OOC color.", "OOC color", prefs.ooccolor) as color|null
	if(new_ooccolor)
		prefs.ooccolor = new_ooccolor
		prefs.save_preferences(src)
		usr << "Your OOC color has been set to [new_ooccolor]."
		
	feedback_add_details("admin_verb","OC") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/resetcolorooc()
	set name = "Reset Your OOC Color"
	set desc = "Returns your OOC color to default."
	set category = "Preferences"

	if(!check_rights(R_ADMIN)) return

	prefs.ooccolor = initial(prefs.ooccolor)
	prefs.save_preferences(src)
	usr << "Your OOC color has been reset."
	
	feedback_add_details("admin_verb","ROC") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/looc(msg as text)
	set name = "LOOC" //Gave this shit a shorter name so you only have to time out "ooc" rather than "ooc message" to use it --NeoFite
	set desc = "Local OOC, seen only by those in view."
	set category = "OOC"

	if(!mob)	return
	if(IsGuestKey(key))
		src << "Guests may not use OOC."
		return

	msg = trim(sanitize(copytext(msg, 1, MAX_MESSAGE_LEN)))
	if(!msg)	return

	if(!(prefs.toggles & CHAT_LOOC))
		src << "\red You have LOOC muted."
		return

	if(!check_rights(R_MOD,0))
		if(!ooc_allowed)
			src << "\red LOOC is globally muted"
			return
		if(!dooc_allowed && (mob.stat == DEAD))
			usr << "\red LOOC for dead mobs has been turned off."
			return
		if(prefs.muted & MUTE_OOC)
			src << "\red You cannot use LOOC (muted)."
			return
		if(handle_spam_prevention(msg,MUTE_OOC))
			return
		if(findtext(msg, "byond://"))
			src << "<B>Advertising other servers is not allowed.</B>"
			log_admin("[key_name(src)] has attempted to advertise in LOOC: [msg]")
			message_admins("[key_name_admin(src)] has attempted to advertise in LOOC: [msg]")
			return

	log_ooc("(LOCAL) [mob.name]/[key] : [msg]")
	var/list/heard = get_mobs_in_view(7, src.mob)
	var/mob/S = src.mob

	var/display_name = S.key
	if(S.stat != DEAD)
		display_name = S.name

	// Handle non-admins
	for(var/mob/M in heard)
		if(!M.client)
			continue
		var/client/C = M.client
		if(check_rights(R_MOD,0,M))
			continue //they are handled after that

		if(C.prefs.toggles & CHAT_LOOC)
			if(holder)
				if(holder.fakekey)
					if(C.holder)
						display_name = "[holder.fakekey]/([src.key])"
					else
						display_name = holder.fakekey
			C << "<font color='#6699CC'><span class='ooc'><span class='prefix'>LOOC:</span> <EM>[display_name]:</EM> <span class='message'>[msg]</span></span></font>"

	// Now handle admins
	display_name = S.key
	if(S.stat != DEAD)
		display_name = "[S.name]/([S.key])"

	for(var/client/C in admins)
		if(check_rights(R_MOD,0,C.mob))
			if(C.prefs.toggles & CHAT_LOOC)
				var/prefix = "(R)LOOC"
				if (C.mob in heard)
					prefix = "LOOC"
				C << "<font color='#6699CC'><span class='ooc'><span class='prefix'>[prefix]:</span> <EM>[display_name]:</EM> <span class='message'>[msg]</span></span></font>"
