/client/proc/update_active_keybindings()
	active_keybindings = list()
	movement_kb_dirs = list()

	for(var/key in prefs?.keybindings)
		for(var/kb in prefs.keybindings[key])
			var/datum/keybinding/KB = kb
			if(!KB.can_use(src, mob))
				continue
			if(istype(KB, /datum/keybinding/movement))
				var/datum/keybinding/movement/KBM = KB
				movement_kb_dirs[key] = KBM.move_dir
			else
				active_keybindings[key] += list(KB)
	if(!mob) // Clients can join before world/new is setup, so we gotta mob check em
		return active_keybindings
	for(var/datum/action/action as anything in mob.actions)
		if(action.button?.linked_keybind?.binded_to)
			var/datum/keybinding/mob/trigger_action_button/linked_bind = action.button.linked_keybind
			active_keybindings[linked_bind.binded_to] += list(linked_bind)

	return active_keybindings

/**
 * Updates the keybinds for special keys, do not call this by itself as it will clear user hotkeys, call via update_all_keybinds()
 *
 * Handles adding macros for the keys that need it
 * At the time of writing this, communication(OOC, Say, IC, LOOC, ASAY, MSAY) require macros
 */
/client/proc/update_special_keybinds()
	if(!length(prefs?.keybindings) || !mob)
		return
	for(var/key in prefs.keybindings)
		for(var/datum/keybinding/client/communication/kb in prefs.keybindings[key])
			switch(kb.name)
				if(SAY_CHANNEL)
					var/say = tgui_say_create_open_command(SAY_CHANNEL)
					winset(src, "default-[key]", "parent=default;name=[key];command=[say]")
				if(RADIO_CHANNEL)
					var/radio = tgui_say_create_open_command(RADIO_CHANNEL)
					winset(src, "default-[key]", "parent=default;name=[key];command=[radio]")
				if(ME_CHANNEL)
					var/me = tgui_say_create_open_command(ME_CHANNEL)
					winset(src, "default-[key]", "parent=default;name=[key];command=[me]")
				if(OOC_CHANNEL)
					var/ooc = tgui_say_create_open_command(OOC_CHANNEL)
					winset(src, "default-[key]", "parent=default;name=[key];command=[ooc]")
				if(LOOC_CHANNEL)
					var/looc = tgui_say_create_open_command(LOOC_CHANNEL)
					winset(src, "default-[key]", "parent=default;name=[key];command=[looc]")
				if(ADMIN_CHANNEL)
					if(check_rights(R_ADMIN, FALSE))
						var/asay = tgui_say_create_open_command(ADMIN_CHANNEL)
						winset(src, "default-[key]", "parent=default;name=[key];command=[asay]")
					else
						winset(src, "default-[key]", "parent=default;name=[key];command=")
				if(DSAY_CHANNEL)
					if(check_rights(R_ADMIN, FALSE))
						var/dsay = tgui_say_create_open_command(DSAY_CHANNEL)
						winset(src, "default-[key]", "parent=default;name=[key];command=[dsay]")
					else
						winset(src, "default-[key]", "parent=default;name=[key];command=")
				if(MENTOR_CHANNEL)
					if(check_rights(R_MENTOR | R_ADMIN, FALSE))
						var/msay = tgui_say_create_open_command(MENTOR_CHANNEL)
						winset(src, "default-[key]", "parent=default;name=[key];command=[msay]")
					else
						winset(src, "default-[key]", "parent=default;name=[key];command=")


/**
 * Updates the keybinds for special and regular keys
 * Used when you want to call update_special_keybinds() as that clears default macro sets
 */
/client/proc/update_all_keybinds()
	update_special_keybinds()
	update_active_keybindings()
