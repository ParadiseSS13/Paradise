/datum/song/ui_data(mob/user)
	var/list/data = list()

	// General
	data["playing"] = playing
	data["repeat"] = repeat
	data["maxRepeats"] = max_repeats
	data["editing"] = editing
	data["lines"] = lines
	data["tempo"] = tempo
	data["minTempo"] = world.tick_lag
	data["maxTempo"] = 5 SECONDS
	data["tickLag"] = world.tick_lag
	data["help"] = help

	// Status
	var/list/allowed_instrument_names = list()
	for(var/i in allowed_instrument_ids)
		var/datum/instrument/I = SSinstruments.get_instrument(i)
		if(I)
			allowed_instrument_names += I.name
	data["allowedInstrumentNames"] = allowed_instrument_names
	data["instrumentLoaded"] = !isnull(using_instrument)
	if(using_instrument)
		data["instrument"] = using_instrument.name
	data["canNoteShift"] = can_noteshift
	if(can_noteshift)
		data["noteShift"] = note_shift
		data["noteShiftMin"] = note_shift_min
		data["noteShiftMax"] = note_shift_max
	data["sustainMode"] = sustain_mode
	switch(sustain_mode)
		if(SUSTAIN_LINEAR)
			data["sustainLinearDuration"] = sustain_linear_duration
		if(SUSTAIN_EXPONENTIAL)
			data["sustainExponentialDropoff"] = sustain_exponential_dropoff
	data["ready"] = using_instrument?.is_ready()
	data["legacy"] = legacy
	data["volume"] = volume
	data["minVolume"] = min_volume
	data["maxVolume"] = max_volume
	data["sustainDropoffVolume"] = sustain_dropoff_volume
	data["sustainHeldNote"] = full_sustain_held_note

	return data

/datum/song/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, parent, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, parent, ui_key, "Instrument", parent?.name || "Instrument", 700, 500)
		ui.open()
		ui.set_autoupdate(FALSE) // NO!!! Don't auto-update this!!

/datum/song/ui_act(action, params)
	. = TRUE
	switch(action)
		if("newsong")
			lines = new()
			tempo = sanitize_tempo(5) // default 120 BPM
			name = ""
		if("import")
			var/t = ""
			do
				t = html_encode(input(usr, "Please paste the entire song, formatted:", "[name]", t)  as message)
				if(!in_range(parent, usr))
					return

				if(length_char(t) >= MUSIC_MAXLINES * MUSIC_MAXLINECHARS)
					var/cont = input(usr, "Your message is too long! Would you like to continue editing it?", "", "yes") in list("yes", "no")
					if(cont == "no")
						break
			while(length_char(t) > MUSIC_MAXLINES * MUSIC_MAXLINECHARS)
			parse_song(t)
			return FALSE
		if("help")
			help = !help
		if("edit")
			editing = !editing
		if("repeat") //Changing this from a toggle to a number of repeats to avoid infinite loops.
			if(playing)
				return //So that people cant keep adding to repeat. If the do it intentionally, it could result in the server crashing.
			repeat = clamp(round(text2num(params["new"])), 0, max_repeats)
		if("tempo")
			tempo = sanitize_tempo(text2num(params["new"]))
		if("play")
			INVOKE_ASYNC(src, PROC_REF(start_playing), usr)
		if("newline")
			var/newline = html_encode(input("Enter your line: ", parent.name) as text|null)
			if(!newline || !in_range(parent, usr))
				return
			if(length(lines) > MUSIC_MAXLINES)
				return
			if(length(newline) > MUSIC_MAXLINECHARS)
				newline = copytext(newline, 1, MUSIC_MAXLINECHARS)
			lines.Add(newline)
		if("deleteline")
			var/num = round(text2num(params["line"]))
			if(num > length(lines) || num < 1)
				return
			lines.Cut(num, num + 1)
		if("modifyline")
			var/num = round(text2num(params["line"]))
			var/content = stripped_input(usr, "Enter your line: ", parent.name, lines[num], MUSIC_MAXLINECHARS)
			if(!content || !in_range(parent, usr))
				return
			if(num > length(lines) || num < 1)
				return
			lines[num] = content
		if("stop")
			stop_playing()
		if("setlinearfalloff")
			set_linear_falloff_duration(round(text2num(params["new"]) * 10, world.tick_lag), TRUE)
		if("setexpfalloff")
			set_exponential_drop_rate(round(text2num(params["new"]), 0.00001), TRUE)
		if("setvolume")
			set_volume(round(text2num(params["new"]), 1))
		if("setdropoffvolume")
			set_dropoff_volume(round(text2num(params["new"]), 0.01), TRUE)
		if("switchinstrument")
			if(!length(allowed_instrument_ids))
				return
			else if(length(allowed_instrument_ids) == 1)
				set_instrument(allowed_instrument_ids[1])
				return
			var/choice = params["name"]
			for(var/i in allowed_instrument_ids)
				var/datum/instrument/I = SSinstruments.get_instrument(i)
				if(I && I.name == choice)
					set_instrument(I)
		if("setnoteshift")
			note_shift = clamp(round(text2num(params["new"])), note_shift_min, note_shift_max)
		if("setsustainmode")
			var/static/list/sustain_modes
			if(!length(sustain_modes))
				sustain_modes = list("Linear" = SUSTAIN_LINEAR, "Exponential" = SUSTAIN_EXPONENTIAL)
			var/choice = params["new"]
			sustain_mode = sustain_modes[choice] || sustain_mode
		if("togglesustainhold")
			full_sustain_held_note = !full_sustain_held_note
		if("reset")
			var/default_instrument = allowed_instrument_ids[1]
			if(using_instrument != SSinstruments.instrument_data[default_instrument])
				set_instrument(default_instrument)
			note_shift = initial(note_shift)
			sustain_mode = initial(sustain_mode)
			set_linear_falloff_duration(initial(sustain_linear_duration), TRUE)
			set_exponential_drop_rate(initial(sustain_exponential_dropoff), TRUE)
			set_dropoff_volume(initial(sustain_dropoff_volume), TRUE)
		else
			return FALSE
	parent.add_fingerprint(usr)

/**
  * Parses a song the user has input into lines and stores them.
  */
/datum/song/proc/parse_song(text)
	set waitfor = FALSE
	//split into lines
	stop_playing()
	lines = splittext(text, "\n")
	if(length(lines))
		var/bpm_string = "BPM: "
		if(findtext(lines[1], bpm_string, 1, length(bpm_string) + 1))
			var/divisor = text2num(copytext(lines[1], length(bpm_string) + 1)) || 120 // default
			tempo = sanitize_tempo(600 / round(divisor, 1))
			lines.Cut(1, 2)
		else
			tempo = sanitize_tempo(5) // default 120 BPM
		if(length(lines) > MUSIC_MAXLINES)
			to_chat(usr, "Too many lines!")
			lines.Cut(MUSIC_MAXLINES + 1)
		var/linenum = 1
		for(var/l in lines)
			if(length_char(l) > MUSIC_MAXLINECHARS)
				to_chat(usr, "Line [linenum] too long!")
				lines.Remove(l)
			else
				linenum++
		SStgui.update_uis(parent)
