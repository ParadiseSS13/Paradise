// Base class for anything that can show up on home screen
/datum/data/pda
	var/icon = "tasks"
	var/notify_icon = "exclamation-circle"
	var/notify_silent = 0
	var/hidden = 0				// program not displayed in main menu
	var/category = "General"	// the category to list it in on the main menu
	var/obj/item/device/pda/pda	// if this is null, and the app is running code, something's gone wrong

/datum/data/pda/Destroy()
	pda = null
	return ..()

/datum/data/pda/proc/start()

/datum/data/pda/proc/notify(message, blink = 1)
	if(message)
		//Search for holder of the PDA.
		var/mob/living/L = null
		if(pda.loc && isliving(pda.loc))
			L = pda.loc
		//Maybe they are a pAI!
		else
			L = get(pda, /mob/living/silicon)

		if(L)
			to_chat(L, "[bicon(pda)] [message]")
			nanomanager.update_user_uis(L, pda) // Update the receiving user's PDA UI so that they can see the new message

	if(!notify_silent)
		pda.play_ringtone()

	if(blink && !(src in pda.notifying_programs))
		pda.overlays.Cut()
		pda.overlays += image('icons/obj/pda.dmi', "pda-r")
		pda.notifying_programs |= src

/datum/data/pda/proc/unnotify()
	if(src in pda.notifying_programs)
		pda.notifying_programs -= src
		if(!pda.notifying_programs.len)
			pda.overlays.Cut()

/datum/data/pda/proc/

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
	pda.current_app = src
	return 1

/datum/data/pda/app/proc/update_ui(mob/user as mob, list/data)


// Utilities just have a button on the home screen, but custom code when clicked
/datum/data/pda/utility
	name = "Utility"
	icon = "gear"
	size = 1
	category = "Utilities"


/datum/data/pda/utility/scanmode
	var/base_name
	category = "Scanners"

/datum/data/pda/utility/scanmode/New(obj/item/weapon/cartridge/C)
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
	return 1

/datum/data/pda/utility/scanmode/proc/scan_mob(mob/living/C as mob, mob/living/user as mob)

/datum/data/pda/utility/scanmode/proc/scan_atom(atom/A as mob|obj|turf|area, mob/user as mob)