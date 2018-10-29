var/global/normal_ooc_colour = "#002eb8"
var/global/member_ooc_colour = "#035417"
var/global/mentor_ooc_colour = "#0099cc"
var/global/moderator_ooc_colour = "#184880"
var/global/admin_ooc_colour = "#b82e00"

/client/verb/ooc(msg as text)
	set name = "OOC"
	set category = "OOC"

	if(!mob)
		return
	if(IsGuestKey(key))
		to_chat(src, "<span class='danger'>Guests may not use OOC.</span>")
		return

	msg = trim(sanitize(copytext(msg, 1, MAX_MESSAGE_LEN)))
	if(!msg)
		return

	if(!(prefs.toggles & CHAT_OOC))
		to_chat(src, "<span class='danger'>You have OOC muted.</span>")
		return

	if(!check_rights(R_ADMIN|R_MOD,0))
		if(!config.ooc_allowed)
			to_chat(src, "<span class='danger'>OOC is globally muted.</span>")
			return
		if(!config.dooc_allowed && (mob.stat == DEAD))
			to_chat(usr, "<span class='danger'>OOC for dead mobs has been turned off.</span>")
			return
		if(prefs.muted & MUTE_OOC)
			to_chat(src, "<span class='danger'>You cannot use OOC (muted).</span>")
			return
		if(handle_spam_prevention(msg, MUTE_OOC, OOC_COOLDOWN))
			return
		if(findtext(msg, "byond://"))
			to_chat(src, "<B>Advertising other servers is not allowed.</B>")
			log_admin("[key_name(src)] has attempted to advertise in OOC: [msg]")
			message_admins("[key_name_admin(src)] has attempted to advertise in OOC: [msg]")
			return

	log_ooc(msg, src)

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

	for(var/client/C in GLOB.clients)
		if(C.prefs.toggles & CHAT_OOC)
			var/display_name = key

			if(prefs.unlock_content)
				if(prefs.toggles & MEMBER_PUBLIC)
					var/icon/byond = icon('icons/member_content.dmi', "blag")
					display_name = "[bicon(byond)][display_name]"

			if(donator_level >= DONATOR_LEVEL_ONE)
				if((prefs.toggles & DONATOR_PUBLIC))
					var/icon/donator = icon('icons/ooc_tag_16x.dmi', "donator")
					display_name = "[bicon(donator)][display_name]"

			if(holder)
				if(holder.fakekey)
					if(C.holder && C.holder.rights & R_ADMIN)
						display_name = "[holder.fakekey]/([key])"
					else
						display_name = holder.fakekey

			if(!config.disable_ooc_emoji)
				msg = "<span class='emoji_enabled'>[msg]</span>"

			to_chat(C, "<font color='[display_colour]'><span class='ooc'><span class='prefix'>OOC:</span> <EM>[display_name]:</EM> <span class='message'>[msg]</span></span></font>")

/proc/toggle_ooc()
	config.ooc_allowed = ( !config.ooc_allowed )
	if(config.ooc_allowed)
		to_chat(world, "<B>The OOC channel has been globally enabled!</B>")
	else
		to_chat(world, "<B>The OOC channel has been globally disabled!</B>")

/proc/auto_toggle_ooc(var/on)
	if(config.auto_toggle_ooc_during_round && config.ooc_allowed != on)
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
		to_chat(usr, "Your OOC color has been set to [new_ooccolor].")

	feedback_add_details("admin_verb","OC") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/resetcolorooc()
	set name = "Reset Your OOC Color"
	set desc = "Returns your OOC color to default."
	set category = "Preferences"

	if(!check_rights(R_ADMIN)) return

	prefs.ooccolor = initial(prefs.ooccolor)
	prefs.save_preferences(src)
	to_chat(usr, "Your OOC color has been reset.")

	feedback_add_details("admin_verb","ROC") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/looc(msg as text)
	set name = "LOOC"
	set desc = "Local OOC, seen only by those in view."
	set category = "OOC"

	if(!mob)
		return
	if(IsGuestKey(key))
		to_chat(src, "<span class='danger'>Guests may not use OOC.</span>")
		return

	msg = trim(sanitize(copytext(msg, 1, MAX_MESSAGE_LEN)))
	if(!msg)
		return

	if(!(prefs.toggles & CHAT_LOOC))
		to_chat(src, "<span class='danger'>You have LOOC muted.</span>")
		return

	if(!check_rights(R_ADMIN|R_MOD,0))
		if(!config.looc_allowed)
			to_chat(src, "<span class='danger'>LOOC is globally muted.</span>")
			return
		if(!config.dooc_allowed && (mob.stat == DEAD))
			to_chat(usr, "<span class='danger'>LOOC for dead mobs has been turned off.</span>")
			return
		if(prefs.muted & MUTE_OOC)
			to_chat(src, "<span class='danger'>You cannot use LOOC (muted).</span>")
			return
		if(handle_spam_prevention(msg, MUTE_OOC, OOC_COOLDOWN))
			return
		if(findtext(msg, "byond://"))
			to_chat(src, "<B>Advertising other servers is not allowed.</B>")
			log_admin("[key_name(src)] has attempted to advertise in LOOC: [msg]")
			message_admins("[key_name_admin(src)] has attempted to advertise in LOOC: [msg]")
			return

	log_looc(msg, src)

	var/mob/source = mob.get_looc_source()
	var/list/heard = get_mobs_in_view(7, source)

	var/display_name = key
	if(holder && holder.fakekey)
		display_name = holder.fakekey
	if(mob.stat != DEAD)
		display_name = mob.name

	for(var/client/target in GLOB.clients)
		if(target.prefs.toggles & CHAT_LOOC)
			var/prefix = ""
			var/admin_stuff = ""
			var/send = 0

			if(target in GLOB.admins)
				if(check_rights(R_ADMIN|R_MOD,0,target.mob))
					admin_stuff += "/([key])"
					if(target != src)
						admin_stuff += " ([admin_jump_link(mob)])"

			if(target.mob in heard)
				send = 1
				if(isAI(target.mob))
					prefix = " (Core)"

			else if(isAI(target.mob)) // Special case
				var/mob/living/silicon/ai/A = target.mob
				if(A.eyeobj in hearers(7, source))
					send = 1
					prefix = " (Eye)"

			if(!send && (target in GLOB.admins))
				if(check_rights(R_ADMIN|R_MOD,0,target.mob))
					send = 1
					prefix = "(R)"

			if(send)
				to_chat(target, "<span class='ooc'><span class='looc'>LOOC<span class='prefix'>[prefix]: </span><EM>[display_name][admin_stuff]:</EM> <span class='message'>[msg]</span></span></span>")

/mob/proc/get_looc_source()
	return src

/mob/living/silicon/ai/get_looc_source()
	if(eyeobj)
		return eyeobj
	return src
