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
		if(button.linked_keybind?.binded_to)
			var/datum/keybinding/mob/trigger_action_button/linked_bind = button.linked_keybind
			active_keybindings[linked_bind.binded_to] += list(linked_bind)
	for(var/datum/action/actions as anything in mob?.actions)
		var/to_set_to = prefs?.keybindings_overrides?[istype(actions, /datum/action/spell_action) ? initial(actions.target.name) : initial(actions.name)]
		if(to_set_to)
			for(var/datum/hud/hud in actions.viewers)
				var/atom/movable/screen/movable/action_button/button = actions.viewers[hud]
				INVOKE_ASYNC(button, TYPE_PROC_REF(/atom/movable/screen/movable/action_button, set_to_keybind), mob, to_set_to)

	return active_keybindings
