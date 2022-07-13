/datum/proc/key_down(key, client/C)
	return

/datum/proc/key_up(key, client/C)
	return

/datum/proc/key_loop(client/C)
	return

/client/key_loop()
	mob.input_focus?.key_loop(src)

/client
	var/list/macro_sets

/client/proc/set_macros()
	set waitfor = FALSE
	var/static/list/default_macro_sets

	if(!default_macro_sets)
		default_macro_sets = list(
			"default" = list(
				"Any" = "\"KeyDown \[\[*\]\]\"",
				"Any+UP" = "\"KeyUp \[\[*\]\]\"",
				"Tab" = "\".winset \\\"input.focus=true?map.focus=true input.background-color=[COLOR_INPUT_DISABLED]:input.focus=true input.background-color=[COLOR_INPUT_ENABLED]\\\"\"",
				"Back" = "\".winset \\\"input.focus=true ? input.text=\\\"\"" // This makes it so backspace can remove default inputs
			),
			"secondary_default" = list(
				"Tab" = "\".winset \\\"mainwindow.macro=tertiary_default map.focus=true input.background-color=[COLOR_INPUT_DISABLED]\\\"\"",
				"Back" = "\".winset \\\"input.focus=true ? input.text=\\\"\"" // This makes it so backspace can remove default inputs
			),
			"tertiary_default" = list(
				"Any" = "\"KeyDown \[\[*\]\]\"",
				"Any+UP" = "\"KeyUp \[\[*\]\]\"",
				"Tab" = "\".winset \\\"mainwindow.macro=secondary_default input.focus=true input.background-color=[COLOR_INPUT_ENABLED]\\\"\"",
				"Back" = "\".winset \\\"input.focus=true ? input.text=\\\"\"" // This makes it so backspace can remove default inputs
			),
		)

		// Because i'm lazy and don't want to type all these out twice
		var/list/old_default = default_macro_sets["old_default"]

		var/list/static/oldmode_keys = list(
			"North", "East", "South", "West",
			"Northeast", "Southeast", "Northwest", "Southwest",
			"Insert", "Delete", "Ctrl", "Alt",
			"F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8", "F9", "F10", "F11", "F12",
			)

		for(var/i in 1 to length(oldmode_keys))
			var/key = oldmode_keys[i]
			old_default[key] = "\"KeyDown [key]\""
			old_default["[key]+UP"] = "\"KeyUp [key]\""

		var/list/static/oldmode_ctrl_override_keys = list(
			"W" = "W", "A" = "A", "S" = "S", "D" = "D", // movement
			"1" = "1", "2" = "2", "3" = "3", "4" = "4", // intent
			"B" = "B", // resist
			"E" = "E", // quick equip
			"F" = "F", // intent left
			"G" = "G", // intent right
			"H" = "H", // stop pulling
			"Q" = "Q", // drop
			"R" = "R", // throw
			"X" = "X", // switch hands
			"Y" = "Y", // activate item
			"Z" = "Z", // activate item
			)

		for(var/i in 1 to length(oldmode_ctrl_override_keys))
			var/key = oldmode_ctrl_override_keys[i]
			var/override = oldmode_ctrl_override_keys[key]
			old_default["Ctrl+[key]"] = "\"KeyDown [override]\""
			old_default["Ctrl+[key]+UP"] = "\"KeyUp [override]\""

	erase_all_macros()
	macro_sets = default_macro_sets

	for(var/i in 1 to length(macro_sets))
		var/setname = macro_sets[i]
		if(setname != "default")
			winclone(src, "default", setname)
		var/list/macro_set = macro_sets[setname]
		for(var/k in 1 to length(macro_set))
			var/key = macro_set[k]
			var/command = macro_set[key]
			winset(src, "[setname]-[key]", "parent=[setname];name=[key];command=[command]")
	winset(src, null, "input.focus=true input.background-color=[COLOR_INPUT_ENABLED] mainwindow.macro=secondary_default")

/client/proc/erase_all_macros()
	var/list/macro_sets = params2list(winget(src, null, "macros"))
	var/erase_output = ""
	for(var/i in 1 to length(macro_sets))
		var/setname = macro_sets[i]
		var/list/macro_set = params2list(winget(src, "[setname].*", "command")) // The third arg doesnt matter here as we're just removing them all
		for(var/k in 1 to length(macro_set))
			var/list/split_name = splittext(macro_set[k], ".")
			var/macro_name = "[split_name[1]].[split_name[2]]" // [3] is "command"
			erase_output = "[erase_output];[macro_name].parent=null"
	winset(src, null, erase_output)

/client/verb/KeyDown(_key as text)
	set instant = TRUE
	set hidden = TRUE

	var/datum/input_data/ID = input_data
	var/cache = ID.client_keysend_amount++
	if(ID.keysend_tripped && ID.next_keysend_trip_reset <= world.time)
		ID.keysend_tripped = FALSE
	if(ID.next_keysend_reset <= world.time)
		ID.client_keysend_amount = 0
		ID.next_keysend_reset = world.time + (1 SECONDS)

	// The "tripped" system is to confirm that flooding is still happening after one spike
	// not entirely sure how byond commands interact in relation to lag
	// don't want to kick people if a lag spike results in a huge flood of commands being sent
	if(cache >= MAX_KEYPRESS_AUTOKICK)
		if(!ID.keysend_tripped)
			ID.keysend_tripped = TRUE
			ID.next_keysend_trip_reset = world.time + (2 SECONDS)
		else
			log_and_message_admins("was just autokicked for flooding keysends; likely abuse but potentially lagspike, or a controller plugged into their PC.")
			qdel(src)
			return

	// Check if the key is short enough to even be a real key
	if(length(_key) > MAX_KEYPRESS_COMMANDLENGTH)
		to_chat(src, "<span class='userdanger'>Invalid KeyDown detected! You have been disconnected from the server automatically.</span>")
		log_and_message_admins("just attempted to send an invalid keypress. Keymessage was over [MAX_KEYPRESS_COMMANDLENGTH] characters, autokicking due to likely abuse.")
		qdel(src)
		return

	if(length(ID.keys_held) > HELD_KEY_BUFFER_LENGTH)
		return

	// The time a key was pressed isn't actually used anywhere (as of 2019-9-10) but this allows easier access usage/checking
	ID.keys_held[_key] = world.time

	var/move_dir = movement_kb_dirs[_key]
	if(move_dir && !ID.move_lock)
		SSinput.processing[src] = world.time
		ID.desired_move_dir |= move_dir
		if(!(ID.desired_move_dir_sub & move_dir))
			ID.desired_move_dir_add |= move_dir

	var/alt_mod = ID.keys_held["Alt"] ? "Alt" : ""
	var/ctrl_mod = ID.keys_held["Ctrl"] ? "Ctrl" : ""
	var/shift_mod = ID.keys_held["Shift"] ? "Shift" : ""
	var/full_key
	switch(_key)
		if("Alt", "Ctrl", "Shift")
			full_key = "[alt_mod][ctrl_mod][shift_mod]"
		else
			if(alt_mod || ctrl_mod || shift_mod)
				full_key = "[alt_mod][ctrl_mod][shift_mod][_key]"
				ID.key_combos_held[_key] = full_key
			else
				full_key = _key

	var/list/kbs = active_keybindings[full_key]
	if(LAZYLEN(kbs))
		var/keycount = 0
		for(var/kb in kbs)
			var/datum/keybinding/KB = kb
			KB.down(src)
			if(++keycount >= MAX_COMMANDS_PER_KEY)
				break

	mob.input_focus?.key_down(_key, src)

/client/verb/KeyUp(_key as text)
	set instant = TRUE
	set hidden = TRUE

	var/datum/input_data/ID = input_data
	var/key_combo = ID.key_combos_held[_key]
	if(key_combo)
		ID.key_combos_held -= _key
		KeyUp(key_combo)

	ID.keys_held -= _key

	var/move_dir = movement_kb_dirs[_key]
	if(move_dir)
		ID.desired_move_dir &= ~move_dir
		if(!(ID.desired_move_dir_add & move_dir))
			ID.desired_move_dir_sub |= move_dir

	var/list/kbs = active_keybindings[_key]
	if(LAZYLEN(kbs))
		for(var/kb in kbs)
			var/datum/keybinding/KB = kb
			KB.up(src)

	mob.input_focus?.key_up(_key, src)

/client/verb/input_focus_change(state as num)
	set instant = TRUE
	set hidden = TRUE

	winset(src, "input", "background-color=[state ? COLOR_INPUT_ENABLED : COLOR_INPUT_DISABLED]")
