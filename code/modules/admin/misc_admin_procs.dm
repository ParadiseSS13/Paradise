/// Is admin BSA (damage a user) currently on cooldown?
GLOBAL_VAR_INIT(BSACooldown, FALSE)
/// Are we in a no-log event (EORG, highlander, etc)?
GLOBAL_VAR_INIT(nologevent, FALSE)
/// Are explosions currently disabled for EORG?
GLOBAL_VAR_INIT(disable_explosions, FALSE)

////////////////////////////////
/proc/message_admins(msg)
	msg = SPAN_ADMIN(SPAN_PREFIX("ADMIN LOG:</span> <span class='message'>[msg]") )
	for(var/client/C in GLOB.admins)
		if(R_ADMIN & C.holder.rights)
			if(C.prefs && !(C.prefs.toggles & PREFTOGGLE_CHAT_NO_ADMINLOGS))
				to_chat(C, msg, MESSAGE_TYPE_ADMINLOG, confidential = TRUE)

/proc/msg_admin_attack(text, loglevel)
	if(!GLOB.nologevent)
		var/rendered = SPAN_ADMIN(SPAN_PREFIX("ATTACK:</span> <span class='message'>[text]") )
		for(var/client/C in GLOB.admins)
			if((C.holder.rights & R_ADMIN) && (C.prefs?.atklog <= loglevel))
				to_chat(C, rendered, MESSAGE_TYPE_ATTACKLOG, confidential = TRUE)

/**
 * Sends a message to the staff able to see admin tickets
 * Arguments:
 * msg - The message being send
 * important - If the message is important. If TRUE it will ignore the CHAT_NO_TICKETLOGS preferences,
 *             send a sound and flash the window. Defaults to FALSE
 */
/proc/message_adminTicket(msg, important = FALSE)
	for(var/client/C in GLOB.admins)
		if(R_ADMIN & C.holder.rights)
			if(important || (C.prefs && !(C.prefs.toggles & PREFTOGGLE_CHAT_NO_TICKETLOGS)))
				to_chat(C, msg, MESSAGE_TYPE_ADMINCHAT, confidential = TRUE)
			if(important)
				if(C.prefs?.sound & SOUND_ADMINHELP)
					SEND_SOUND(C, sound('sound/effects/adminhelp.ogg'))
				window_flash(C)

/**
 * Sends a message to the staff able to see mentor tickets
 * Arguments:
 * msg - The message being send
 * important - If the message is important. If TRUE it will ignore the CHAT_NO_TICKETLOGS preferences,
 *             send a sound and flash the window. Defaults to FALSE
 */
/proc/message_mentorTicket(msg, important = FALSE)
	for(var/client/C in GLOB.admins)
		if(check_rights(R_ADMIN | R_MENTOR | R_MOD, 0, C.mob))
			if(important || (C.prefs && !(C.prefs.toggles & PREFTOGGLE_CHAT_NO_TICKETLOGS)))
				to_chat(C, msg, MESSAGE_TYPE_MENTORPM, confidential = TRUE)
			if(important)
				if(C.prefs?.sound & SOUND_MENTORHELP)
					SEND_SOUND(C, sound('sound/machines/notif1.ogg'))
				window_flash(C)

/proc/admin_ban_mobsearch(mob/M, ckey_to_find, mob/admin_to_notify)
	if(!M || !M.ckey)
		if(ckey_to_find)
			for(var/mob/O in GLOB.mob_list)
				if(O.ckey && O.ckey == ckey_to_find)
					if(admin_to_notify)
						to_chat(admin_to_notify, SPAN_WARNING("admin_ban_mobsearch: Player [ckey_to_find] is now in mob [O]. Pulling data from new mob."), MESSAGE_TYPE_ADMINLOG, confidential = TRUE)
						return O
			if(admin_to_notify)
				to_chat(admin_to_notify, SPAN_WARNING("admin_ban_mobsearch: Player [ckey_to_find] does not seem to have any mob, anywhere. This is probably an error."), MESSAGE_TYPE_ADMINLOG, confidential = TRUE)
		else if(admin_to_notify)
			to_chat(admin_to_notify, SPAN_WARNING("admin_ban_mobsearch: No mob or ckey detected."), MESSAGE_TYPE_ADMINLOG, confidential = TRUE)
	return M

///////////////////////////////////////////////////////////////////////////////////////////////Panels

#define PLAYER_NOTES_ENTRIES_PER_PAGE 50

/datum/admins/proc/Game()
	if(!check_rights(R_ADMIN))
		return

	var/list/dat = list()
	var/cached_UID = UID()
	dat += "<center>"
	dat += "<p><a href='byond://?src=[cached_UID];c_mode=1'>Change Game Mode</a><br></p>"
	if(GLOB.master_mode == "secret")
		dat += "<p><a href='byond://?src=[cached_UID];f_secret=1'>(Force Secret Mode)</a><br></p>"
	if(GLOB.master_mode == "dynamic" || (GLOB.master_mode == "secret" && GLOB.secret_force_mode == "dynamic"))
		dat += "<p><a href='byond://?src=[cached_UID];f_dynamic=1'>(Force Dynamic Rulesets)</a><br></p>"
	dat += "<hr><br>"
	dat += "<p><a href='byond://?src=[cached_UID];create_object=1'>Create Object</a><br></p>"
	dat += "<p><a href='byond://?src=[cached_UID];quick_create_object=1'>Quick Create Object</a><br></p>"
	dat += "<p><a href='byond://?src=[cached_UID];create_turf=1'>Create Turf</a><br></p>"
	dat += "<p><a href='byond://?src=[cached_UID];create_mob=1'>Create Mob</a></p>"

	var/datum/browser/popup = new(usr, "game_panel", "<div align='center'>Game Panel</div>", 210, 280)
	popup.set_content(dat.Join(""))
	popup.set_window_options("can_close=1;can_minimize=0;can_maximize=0;can_resize=0;titlebar=1;")
	popup.open()
	onclose(usr, "game_panel")
	return

////////////////////////////////////////////////////////////////////////////////////////////////ADMIN HELPER PROCS

/**
  * A proc that return whether the mob is a "Special Character" aka Antagonist
  *
  * Arguments:
  * * M - the mob you're checking
  */
/proc/is_special_character(mob/M)
	if(!SSticker.mode)
		return FALSE
	if(!istype(M))
		return FALSE
	if(isrobot(M))
		var/mob/living/silicon/robot/R = M
		if(R.emagged)
			return TRUE
	if(M.mind?.special_role)//If they have a mind and special role, they are some type of traitor or antagonist.
		return TRUE
	return FALSE

/**
  * A proc that return an array of capitalized strings containing name of the antag types they are
  *
  * Arguments:
  * * M - the mob you're checking
  */
/proc/get_antag_type_strings_list(mob/M) // return an array of all the antag types they are with name
	var/list/antag_list = list()

	if(!SSticker.mode || !istype(M) || !M.mind)
		return FALSE

	if(M.mind.has_antag_datum(/datum/antagonist/rev/head))
		antag_list += "Head Rev"
	if(M.mind.has_antag_datum(/datum/antagonist/rev, FALSE))
		antag_list += "Revolutionary"
	if(IS_CULTIST(M))
		antag_list += "Cultist"
	if(M.mind in SSticker.mode.syndicates)
		antag_list += "Nuclear Operative"
	if(iswizard(M))
		antag_list += "Wizard"
	if(IS_CHANGELING(M))
		antag_list += "Changeling"
	if(M.mind.has_antag_datum(/datum/antagonist/abductor))
		antag_list += "Abductor"
	if(M.mind.has_antag_datum(/datum/antagonist/vampire))
		antag_list += "Vampire"
	if(M.mind.has_antag_datum(/datum/antagonist/mindslave/thrall))
		antag_list += "Vampire Thrall"
	if(M.mind.has_antag_datum(/datum/antagonist/traitor))
		antag_list += "Traitor"
	if(IS_MINDSLAVE(M))
		antag_list += "Mindslave"
	if(isrobot(M))
		var/mob/living/silicon/robot/R = M
		if(R.emagged)
			antag_list += "Emagged Borg"
	if(!length(antag_list) && M.mind.special_role) // Snowflake check. If none of the above but still special, then other antag. Technically not accurate.
		antag_list += "Other Antag(s)"
	return antag_list

/**
  * A proc that return a string containing all the singled out antags . Empty string if not antag
  *
  * Usually, you'd return a FALSE, but since this is consumed by javascript you're in
  * for a world of hurt if you pass a byond FALSE which get converted into a fucking string anyway and pass for TRUE in check. Fuck.
  * It always append "(May be other antag)"
  * Arguments:
  * * M - the mob you're checking
  * *
  */
/proc/get_antag_type_truncated_plaintext_string(mob/M as mob)
	var/list/antag_list = get_antag_type_strings_list(M)

	if(length(antag_list))
		return antag_list.Join(" &amp; ") + " " + "(May be other antag)"

	return ""

/datum/admins/proc/output_ai_laws()
	var/ai_number = 0
	var/list/messages = list()
	for(var/mob/living/silicon/S in GLOB.mob_list)
		if(istype(S, /mob/living/silicon/decoy) && !S.client)
			continue
		ai_number++
		if(is_ai(S))
			messages += "<b>AI [key_name(S, TRUE)]'s laws:</b>"
		else if(isrobot(S))
			var/mob/living/silicon/robot/R = S
			messages += "<b>CYBORG [key_name(S, TRUE)]'s [R.connected_ai?"(Slaved to: [R.connected_ai])":"(Independent)"] laws:</b>"
		else if(ispAI(S))
			var/mob/living/silicon/pai/P = S
			messages += "<b>pAI [key_name(S, TRUE)]'s laws:</b>"
			messages += "[P.pai_law0]"
			if(P.pai_laws)
				messages += "[P.pai_laws]"
			continue // Skip showing normal silicon laws for pAIs - they don't have any
		else
			messages += "<b>SILICON [key_name(S, TRUE)]'s laws:</b>"

		if(S.laws == null)
			messages += "[key_name(S, TRUE)]'s laws are null. Contact a coder."
		else
			messages += S.laws.return_laws_text()
	if(!ai_number)
		messages += "<b>No AI's located.</b>" //Just so you know the thing is actually working and not just ignoring you.

	to_chat(usr, chat_box_examine(messages.Join("<br>")))

	log_admin("[key_name(usr)] checked the AI laws")
	message_admins("[key_name_admin(usr)] checked the AI laws")

USER_CONTEXT_MENU(update_mob_sprite, R_ADMIN, "\[Admin\] Update Mob Sprite", mob/living/carbon/human/H as mob)
	if(istype(H))
		H.regenerate_icons()

//
//
//ALL DONE
//*********************************************************************************************************

/proc/move_gamma_ship()
	if(!SSshuttle.gamma_armory)
		log_debug("move_gamma_ship(): There is no Gamma Armory shuttle, but the Gamma Armory shuttle was called. Loading a default Gamma Armory shuttle.")
		SSshuttle.load_initial_gamma_armory_shuttle(SSmapping.gamma_armory_shuttle_id)

	if(SSshuttle.gamma_armory.mode != (SHUTTLE_IDLE || SHUTTLE_DOCKED))
		to_chat(usr, "The Gamma Armory shuttle is currently in transit. Please try again in a few moments.")
		return

	if(SSshuttle.gamma_armory.loc.z == level_name_to_num(CENTCOMM))
		SSshuttle.moveShuttle("gamma_armory", "gamma_home", TRUE, usr)
		for(var/obj/machinery/door/poddoor/impassable/gamma/H in GLOB.airlocks)
			H.open()
		GLOB.major_announcement.Announce("Central Command has deployed the Gamma Armory shuttle.", new_sound = 'sound/AI/gamma_deploy.ogg')
	else
		SSshuttle.moveShuttle("gamma_armory", "gamma_away", TRUE, usr)
		for(var/obj/machinery/door/poddoor/impassable/gamma/H in GLOB.airlocks)
			H.close() //DOOR STUCK
		GLOB.major_announcement.Announce("Central Command has recalled the Gamma Armory shuttle.", new_sound = 'sound/AI/gamma_recall.ogg')

/proc/formatJumpTo(location, where="")
	var/turf/loc
	if(isturf(location))
		loc = location
	else
		loc = get_turf(location)
	if(where=="")
		where=formatLocation(loc)
	return "<A href='byond://?_src_=holder;adminplayerobservecoodjump=1;X=[loc.x];Y=[loc.y];Z=[loc.z]'>[where]</a>"

/proc/formatLocation(location)
	var/turf/loc
	if(isturf(location))
		loc = location
	else
		loc = get_turf(location)
	var/area/A = get_area(location)
	return "[A.name] - [loc.x],[loc.y],[loc.z]"

/proc/formatPlayerPanel(mob/U, text="PP")
	return "[ADMIN_PP(U,"[text]")]"

//Kicks all the clients currently in the lobby. The second parameter (kick_only_afk) determins if an is_afk() check is ran, or if all clients are kicked
//defaults to kicking everyone (afk + non afk clients in the lobby)
//returns a list of ckeys of the kicked clients
/proc/kick_clients_in_lobby(message, kick_only_afk = 0)
	var/list/kicked_client_names = list()
	for(var/client/C in GLOB.clients)
		if(isnewplayer(C.mob))
			if(kick_only_afk && !C.is_afk())	//Ignore clients who are not afk
				continue
			if(message)
				to_chat(C, message)
			kicked_client_names.Add("[C.ckey]")
			qdel(C)
	return kicked_client_names

//returns 1 to let the dragdrop code know we are trapping this event
//returns 0 if we don't plan to trap the event
/datum/admins/proc/cmd_ghost_drag(mob/dead/observer/frommob, atom/tothing)
	if(!istype(frommob))
		return //extra sanity check to make sure only observers are shoved into things

	//same as assume-direct-control perm requirements.
	if(!check_rights(R_VAREDIT,0)) //no varedit, check if they have r_admin and r_debug
		if(!check_rights(R_ADMIN|R_DEBUG,0)) //if they don't have r_admin and r_debug, return
			return FALSE //otherwise, if they have no varedit, but do have r_admin and r_debug, execute the rest of the code

	if(!frommob.ckey)
		return FALSE

	if(isitem(tothing))
		var/mob/living/toitem = tothing

		var/ask = alert("Are you sure you want to allow [frommob.name]([frommob.key]) to possess [toitem.name]?", "Place ghost in control of item?", "Yes", "No")
		if(ask != "Yes")
			return TRUE

		if(!frommob || !toitem) //make sure the mobs don't go away while we waited for a response
			return TRUE

		var/mob/living/basic/possessed_object/tomob = new(toitem)

		message_admins(SPAN_ADMINNOTICE("[key_name_admin(usr)] has put [frommob.ckey] in control of [tomob.name]."))
		log_admin("[key_name(usr)] stuffed [frommob.ckey] into [tomob.name].")
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Ghost Drag")

		tomob.ckey = frommob.ckey
		qdel(frommob)


	if(isliving(tothing))
		var/mob/living/tomob = tothing

		var/question = ""
		if(tomob.ckey)
			question = "This mob already has a user ([tomob.key]) in control of it! "
		question += "Are you sure you want to place [frommob.name]([frommob.key]) in control of [tomob.name]?"

		var/ask = alert(question, "Place ghost in control of mob?", "Yes", "No")
		if(ask != "Yes")
			return TRUE

		if(!frommob || !tomob) //make sure the mobs don't go away while we waited for a response
			return TRUE

		if(tomob.client) //no need to ghostize if there is no client
			tomob.ghostize(GHOST_FLAGS_OBSERVE_ONLY)

		message_admins(SPAN_ADMINNOTICE("[key_name_admin(usr)] has put [frommob.ckey] in control of [tomob.name]."))
		log_admin("[key_name(usr)] stuffed [frommob.ckey] into [tomob.name].")
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Ghost Drag")

		tomob.ckey = frommob.ckey
		qdel(frommob)

		return TRUE

	if(istype(tothing, /obj/structure/ai_core/deactivated))

		var/question = "Are you sure you want to place [frommob.name]([frommob.key]) in control of an empty AI core?"

		var/ask = alert(question, "Place ghost in control of an empty AI core?", "Yes", "No")
		if(ask != "Yes")
			return TRUE

		if(QDELETED(frommob) || QDELETED(tothing)) //make sure the mobs don't go away while we waited for a response
			return TRUE

		message_admins(SPAN_ADMINNOTICE("[key_name_admin(usr)] has put [frommob.ckey] in control of an empty AI core."))
		log_admin("[key_name(usr)] stuffed [frommob.ckey] into an empty AI core.")
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Ghost Drag")

		var/transfer_key = frommob.key // frommob is qdel'd in frommob.AIize()
		var/mob/living/silicon/ai/ai_character = frommob.AIize()
		ai_character.key = transfer_key // this wont occur in mind transferring if the mind is not active, which causes some weird stuff. This fixes it.
		GLOB.empty_playable_ai_cores -= tothing

		ai_character.forceMove(get_turf(tothing))
		ai_character.view_core()

		qdel(tothing)

		return TRUE

// Returns a list of the number of admins in various categories
// result[1] is the number of staff that match the rank mask and are active
// result[2] is the number of staff that do not match the rank mask
// result[3] is the number of staff that match the rank mask and are inactive
/proc/staff_countup(rank_mask = R_BAN)
	var/list/result = list(0, 0, 0)
	for(var/client/X in GLOB.admins)
		if(rank_mask && !check_rights_client(rank_mask, FALSE, X))
			result[2]++
			continue
		if(X.holder.fakekey)
			result[2]++
			continue
		if(X.is_afk())
			result[3]++
			continue
		result[1]++
	return result

/**
 * Allows admins to safely pick from SSticker.minds for objectives
 * - caller_mob, mob to ask for results
 * - blacklist, optional list of targets that are not available
 * - default_target, the target to show in the list as default
 */
/proc/get_admin_objective_targets(mob/caller_mob, list/blacklist, mob/default_target)
	if(!islist(blacklist))
		blacklist = list(blacklist)

	var/list/possible_targets = list()
	for(var/datum/mind/possible_target in SSticker.minds)
		if(!(possible_target in blacklist) && ishuman(possible_target.current))
			possible_targets += possible_target.current // Allows for admins to pick off station roles

	if(!length(possible_targets))
		to_chat(caller_mob, SPAN_WARNING("No possible target found."))
		return

	possible_targets = sortAtom(possible_targets)

	var/mob/new_target = input(caller_mob, "Select target:", "Objective target", default_target) as null|anything in possible_targets
	if(!QDELETED(new_target))
		return new_target.mind

#undef PLAYER_NOTES_ENTRIES_PER_PAGE
