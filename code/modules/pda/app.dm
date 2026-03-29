// Base class for anything that can show up on home screen
/datum/data/pda
	var/icon = "tasks"		//options comes from http://fontawesome.io/icons/
	var/notify_icon = "exclamation-circle"
	var/hidden = 0				// program not displayed in main menu
	var/category = "General"	// the category to list it in on the main menu
	var/obj/item/pda/pda	// if this is null, and the app is running code, something's gone wrong

/datum/data/pda/Destroy()
	pda = null
	return ..()

/datum/data/pda/proc/start()
	return

/datum/data/pda/proc/stop()
	return

/datum/data/pda/proc/program_process()
	return

/datum/data/pda/proc/program_hit_check()
	return

/datum/data/pda/proc/notify(message, blink = 1, silence_ringtone = FALSE)
	if(message)
		//Search for holder of the PDA.
		var/mob/living/L = null
		if(pda.loc && isliving(pda.loc))
			L = pda.loc
		//Maybe they are a pAI!
		else
			L = get(pda, /mob/living/silicon)

		if(L && L.stat != UNCONSCIOUS) // Awake or dead people can see their messages
			to_chat(L, "[bicon(pda)] [message]")
			SStgui.update_user_uis(L, pda) // Update the receiving user's PDA UI so that they can see the new message

	if(!pda.silent && !silence_ringtone)
		pda.play_ringtone()

	if(blink && !(src in pda.notifying_programs))
		pda.notifying_programs |= src
		pda.update_icon(UPDATE_OVERLAYS)

/datum/data/pda/proc/unnotify()
	if(src in pda.notifying_programs)
		pda.notifying_programs -= src
		if(!length(pda.notifying_programs))
			pda.update_icon(UPDATE_OVERLAYS)

// An app has a button on the home screen and its own UI
/datum/data/pda/app
	name = "App"
	size = 3
	var/title = null	// what is displayed in the title bar when this is the current app
	var/template = ""
	var/update = PDA_APP_UPDATE
	var/has_back = 0

/datum/data/pda/app/New()
	if(!title)
		title = name

/datum/data/pda/app/start()
	if(pda.current_app)
		pda.current_app.stop()
	pda.current_app = src
	if(!pda.silent)
		playsound(pda, 'sound/machines/terminal_select.ogg', 15, TRUE)
	return TRUE

/datum/data/pda/app/proc/update_ui(mob/user, list/data)
	return


// Utilities just have a button on the home screen, but custom code when clicked
/datum/data/pda/utility
	name = "Utility"
	icon = "gear"
	category = "Utilities"

/datum/data/pda/utility/scanmode
	var/base_name
	category = "Scanners"

/datum/data/pda/utility/scanmode/New(obj/item/cartridge/C)
	..(C)
	name = "Enable [base_name]"

/datum/data/pda/utility/scanmode/start()
	if(pda.scanmode)
		pda.scanmode.name = "Enable [pda.scanmode.base_name]"

	if(pda.scanmode == src)
		pda.scanmode = null
	else
		pda.scanmode = src
		name = "Disable [base_name]"

	pda.update_shortcuts()
	if(!pda.silent)
		playsound(pda, 'sound/machines/terminal_select.ogg', 15, TRUE)
	return TRUE

/datum/data/pda/utility/scanmode/proc/scan_mob(mob/living/C, mob/living/user)
	return

/datum/data/pda/utility/scanmode/proc/scan_atom(atom/A, mob/user)
	return
