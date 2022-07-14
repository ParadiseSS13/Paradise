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

	return active_keybindings
