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
	for(var/atom/movable/screen/movable/action_button/button as anything in mob.hud_used.get_all_action_buttons())
		// TODO VERIFY THIS (AND KEYBINDS) WORK PROPERLY
		if(button.linked_keybind?.binded_to)
			var/datum/keybinding/mob/trigger_action_button/linked_bind = button.linked_keybind
			active_keybindings[linked_bind.binded_to] += list(linked_bind)

	return active_keybindings
