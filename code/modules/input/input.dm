/datum/proc/key_down(key, client/C)
	return

/datum/proc/key_up(key, client/C)
	return

/datum/proc/key_loop(client/C)
	return

/client/key_loop()
	mob.input_focus?.key_loop(src)

/client/proc/set_macros()
	var/static/list/macro_set = list(
		"Tab" = @{".winset \"input.focus=true ? map.focus=true : input.focus=true\""},
		"O" = "ooc",
		"T" = ".say",
		"M" = ".me",
		"Any" = @"KeyDown [[*]]",
		"Any+UP" = @"KeyUp [[*]]",
	)
	for(var/key in macro_set)
		var/command = macro_set[key]
		winset(src, "default-[key]", "parent=default;name=[key];command=\"[command]\"")
	winset(src, null, "map.focus=true;mainwindow.macro=default")
	winset(src, null, "input.on-focus=\"input-focus-change 1\";input.on-blur=\"input-focus-change 0\"")

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
			log_and_message_admins("was just autokicked for flooding keysends; likely abuse but potentially lagspike.")
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
