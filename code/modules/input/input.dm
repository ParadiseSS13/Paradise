/datum/proc/key_down(key, client/C)
	return

/datum/proc/key_up(key, client/C)
	return

/datum/proc/key_loop(client/C)
	// Sleeps in input handling are bad, because they can stall the entire subsystem indefinitely, breaking most movement. The subsystem sets waitfor=FALSE, which works around this, but we'd rather avoid the sleeps in the first place.
	SHOULD_NOT_SLEEP(TRUE)
	return

/client/key_loop()
	mob.input_focus?.key_loop(src)

/// This proc sets the built in BYOND macros for keypresses to pass inputs on to the rebindable input system or the legacy system
/// If you plan on ripping out the legacy system, see the set_macros() proc at the following commit: https://github.com/S34NW/Paradise/commit/83a0a0b0c633807cc5a88a630f623cec24e16027
/client/proc/set_macros()
	set waitfor = FALSE
	var/static/list/default_macro_sets

	if(!default_macro_sets) //If you ever remove legacy input mode, you can simplify this a lot
		default_macro_sets = list(
			"default" = list(
				"Any" = "\"Key_Down \[\[*\]\]\"", // Passes any key down to the rebindable input system
				"Any+UP" = "\"Key_Up \[\[*\]\]\"", // Passes any key up to the rebindable input system
				"Tab" = "\".winset \\\"mainwindow.macro=legacy input.focus=true input.border=sunken\\\"\"", // Swaps us to legacy mode, forces input to the input bar, sets the input bar colour to salmon pink
				"Back" = "\".winset \\\"input.focus=true ? input.text=\\\"\"" // This makes it so backspace can remove default inputs
			),
			"legacy" = list(
				"Tab" = "\".winset \\\"mainwindow.macro=default map.focus=true input.border=line\\\"\"", // Swaps us to rebind mode, moves input away from input bar, sets input bar to white
				"Back" = "\".winset \\\"input.focus=true ? input.text=\\\"\"" // This makes it so backspace can remove default inputs
			),
		)

		var/list/legacy_default = default_macro_sets["legacy"]

		/// This list defines the keys in legacy mode that get passed on to the rebindable input system
		/// It cannot be bigger since, while typing, the keys would be passed to whatever they are set in the rebind input system
		var/list/static/legacy_keys = list(
			"North", "East", "South", "West",
			"Northeast", "Southeast", "Northwest", "Southwest",
			"Insert", "Delete",
			"F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8", "F9", "F10", "F11", "F12",
			)

		// We use the static list to make only the keys in it passed to legacy mode
		for(var/i in 1 to length(legacy_keys))
			var/key = legacy_keys[i]
			legacy_default[key] = "\"Key_Down [key]\""
			legacy_default["[key]+UP"] = "\"Key_Up [key]\""

	macro_sets = default_macro_sets

	//This next bit is black magic, if we only had one input system it could be much shorter
	for(var/i in 1 to length(macro_sets))
		var/setname = macro_sets[i]
		if(setname != "default")
			winclone(src, "default", setname)
		var/list/macro_set = macro_sets[setname]
		for(var/k in 1 to length(macro_set))
			var/key = macro_set[k]
			var/command = macro_set[key]
			winset(src, "[setname]-[key]", "parent=[setname];name=[key];command=[command]")

	winset(src, null, "input.border=line") //screw you, we start in hotkey mode now

	macro_sets = null //not needed anymore, bye have a great time

/client/verb/Key_Down(_key as text)
	set name = "Key_Down"
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

/client/verb/Key_Up(_key as text)
	set name = "Key_Up"
	set instant = TRUE
	set hidden = TRUE

	var/datum/input_data/ID = input_data
	var/key_combo = ID.key_combos_held[_key]
	if(key_combo)
		ID.key_combos_held -= _key
		Key_Up(key_combo)

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
