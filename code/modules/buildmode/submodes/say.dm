/datum/buildmode_mode/say
	key = "say"

/datum/buildmode_mode/say/show_help(mob/user)
	to_chat(user, "<span class='notice'>***********************************************************</span>")
	to_chat(user, "<span class='notice'>Left Mouse Button        = Say</span>")
	to_chat(user, "<span class='notice'>Right Mouse Button       = Emote</span>")
	to_chat(user, "<span class='notice'>***********************************************************</span>")

/datum/buildmode_mode/say/handle_click(mob/user, params, atom/object)
	if(ismob(object))
		var/mob/target = object
		if(!isnull(target.ckey))
			tgui_alert(user, "This cannot be used on mobs with a ckey. Use Forcesay in player panel instead.")
			return

	var/list/pa = params2list(params)
	var/left_click = pa.Find("left")
	var/right_click = pa.Find("right")

	if(left_click)
		var/say = tgui_input_text(user, "What should [object] say?", "Say what?")
		if(isnull(say))
			return
		log_admin("Build Mode: [key_name(user)] made [object] at ([object.x],[object.y],[object.z] say [say].")
		message_admins("<span class='notice'>Build Mode: [key_name(user)] made [object] at [ADMIN_VERBOSEJMP(object)] say \"[say]\".</span>")
		user.create_log(MISC_LOG, "Made [object] at ([object.x],[object.y],[object.z] say [say].")
		object.atom_say(say)
	else if(right_click)
		var/emote = tgui_input_text(user, "What should [object] do?", "Emote what?")
		if(isnull(emote))
			return
		log_admin("Build Mode: [key_name(user)] made [object] at ([object.x],[object.y],[object.z] emote *[emote].")
		message_admins("<span class='notice'>Build Mode: [key_name(user)] made [object] at [ADMIN_VERBOSEJMP(object)] emote \"*[emote]\".</span>")
		user.create_log(MISC_LOG, "Made [object] at ([object.x],[object.y],[object.z] emote *[emote].")
		object.atom_emote(emote)
