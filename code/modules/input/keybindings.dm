/client/proc/update_active_keybindings()
	. = list()
	for(var/key in prefs?.keybindings)
		for(var/kb in prefs.keybindings[key])
			var/datum/keybinding/KB = kb
			if(!KB.can_use(src, mob))
				continue
			.[key] += list(KB)
	active_keybindings = .
