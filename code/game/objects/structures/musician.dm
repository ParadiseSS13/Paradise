#define SONG_HEAR_DISTANCE 15
#define SONG_FALLOFF 5
#define SONG_MAX_TEMPO 10
#define SONG_MAX_LENGTH 60
#define SONG_MAX_LINE_LENGTH 200

/datum/song
	var/name = "Untitled"
	var/list/lines
	var/tempo = 5			// delay between notes

	var/playing = FALSE		// if we're playing
	var/help = FALSE		// if help is open
	var/repeat = 1			// number of times remaining to repeat
	var/max_repeat = 10		// maximum times we can repeat

	var/instrument_folder = "piano"		// the folder with the sounds
	var/instrument_extension = "ogg"		// the file extension
	var/obj/instrument_obj = null	// the associated obj playing the sound

	var/static/list/valid_files[0] // Cache to avoid running fexists() every time

/datum/song/New(dir, obj, ext = "ogg")
	lines = new()
	tempo = sanitize_tempo(tempo)
	instrument_folder = dir
	instrument_obj = obj
	instrument_extension = ext

/datum/song/Destroy()
	instrument_obj = null
	return ..()

/**
  * Plays a note with the given accent and octave
  *
  * Longer detailed paragraph about the proc
  * including any relevant detail
  * Arguments:
  * * note - Number from 1 to 7 for A to G
  * * acc - Either "b", "n" or "#"
  * * oct - Number between 1 to 8 (or 9 for C)
  */
/datum/song/proc/play_note(note, acc, oct)
	// handle accidental -> B<>C of E<>F
	if(acc == "b" && (note == 3 || note == 6)) // C or F
		if(note == 3)
			oct--
		note--
		acc = "n"
	else if(acc == "#" && (note == 2 || note == 5)) // B or E
		if(note == 2)
			oct++
		note++
		acc = "n"
	else if(acc == "#" && (note == 7)) //G#
		note = 1
		acc = "b"
	else if(acc == "#") // mass convert all sharps to flats, octave jump already handled
		acc = "b"
		note++

	// check octave, C is allowed to go to 9
	if(oct < 1 || (note == 3 ? oct > 9 : oct > 8))
		return

	// now generate name
	var/filename = "sound/instruments/[instrument_folder]/[ascii2text(note+64)][acc][oct].[instrument_extension]"
	var/soundfile = file(filename)
	// make sure the note exists
	var/cached_fexists = valid_files[filename]
	if(!isnull(cached_fexists))
		if(!cached_fexists)
			return
	else if(!fexists(soundfile))
		valid_files[filename] = FALSE
		return
	else
		valid_files[filename] = TRUE
	// and play
	var/turf/source = get_turf(instrument_obj)
	var/sound/music_played = sound(soundfile)
	for(var/A in GLOB.player_list)
		if(get_dist(A, source) > SONG_HEAR_DISTANCE)
			continue
		var/mob/M = A
		if(!(M.client.prefs.sound & SOUND_INSTRUMENTS))
			continue
		M.playsound_local(source, null, 100, falloff = SONG_FALLOFF, S = music_played)

/**
  * Returns whether the instrument should play or not
  *
  * Arguments:
  * * user - The current user
  */
/datum/song/proc/should_stop_playing(mob/user)
	if(instrument_obj)
		//if(!user.canUseTopic(instrument_obj))
			//return 1
		return !instrument_obj.anchored		// add special cases to stop in subclasses
	return TRUE

/**
  * Plays the song, duh.
  *
  * Arguments:
  * * user - The current user
  */
/datum/song/proc/play_song(mob/user)
	while(repeat)
		var/cur_oct[7]
		var/cur_acc[7]
		for(var/i in 1 to 7)
			cur_oct[i] = 3
			cur_acc[i] = "n"

		for(var/line in lines)
			for(var/beat in splittext(lowertext(line), ","))
				var/list/notes = splittext(beat, "/")
				for(var/note in splittext(notes[1], "-"))
					if(!playing || should_stop_playing(user)) //If the instrument is playing, or special case
						playing = FALSE
						return
					if(!length(note))
						continue
					var/cur_note = text2ascii(note) - 96
					if(cur_note < 1 || cur_note > 7)
						continue
					for(var/i in 2 to length(note))
						var/ni = copytext(note, i, i + 1)
						if(!text2num(ni))
							if(ni == "#" || ni == "b" || ni == "n")
								cur_acc[cur_note] = ni
							else if(ni == "s")
								cur_acc[cur_note] = "#" // so shift is never required
						else
							cur_oct[cur_note] = text2num(ni)
					play_note(cur_note, cur_acc[cur_note], cur_oct[cur_note])
				if(length(notes) >= 2 && text2num(notes[2]))
					sleep(sanitize_tempo(tempo / text2num(notes[2])))
				else
					sleep(tempo)
		repeat--
	playing = FALSE
	repeat = 0

/datum/song/tgui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/tgui_state/state = GLOB.tgui_default_state)
	if(!instrument_obj)
		return

	ui = SStgui.try_update_ui(user, instrument_obj, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, instrument_obj, ui_key, "Song", instrument_obj.name, 700, 500)
		ui.open()
		ui.set_autoupdate(FALSE) // NO!!! Don't auto-update this!!

/datum/song/tgui_data(mob/user)
	var/data[0]

	data["lines"] = lines
	data["tempo"] = tempo

	data["playing"] = playing
	data["help"] = help
	data["repeat"] = repeat
	data["maxRepeat"] = max_repeat
	data["minTempo"] = world.tick_lag
	data["maxTempo"] = SONG_MAX_TEMPO
	data["tickLag"] = world.tick_lag

	return data

/datum/song/tgui_act(action, params)
	// We can't check ..() here because src isn't an actual object
	if(!in_range(instrument_obj, usr) || (issilicon(usr) && instrument_obj.loc != usr) || !isliving(usr) || usr.incapacitated())
		return

	. = TRUE
	switch(action)
		if("newsong")
			playing = FALSE
			lines = new()
			tempo = sanitize_tempo(5) // default 120 BPM
			name = ""
		if("import")
			playing = FALSE
			var/t = ""
			do
				t = html_encode(input(usr, "Please paste the entire song, formatted:", text("[]", name), t) as message)
				if(!in_range(instrument_obj, usr))
					return

				if(length(t) >= SONG_MAX_LENGTH * SONG_MAX_LINE_LENGTH)
					var/cont = input(usr, "Your message is too long! Would you like to continue editing it?", "", "yes") in list("yes", "no")
					if(cont == "no")
						break
			while(length(t) > SONG_MAX_LENGTH * SONG_MAX_LINE_LENGTH)

			INVOKE_ASYNC(src, .proc/process_import, t)
		if("help")
			help = !help
		if("repeat") //Changing this from a toggle to a number of repeats to avoid infinite loops.
			if(playing)
				return //So that people cant keep adding to repeat. If the do it intentionally, it could result in the server crashing.
			repeat = clamp(repeat + round(text2num(params["num"])), 0, max_repeat)
		if("tempo")
			var/new_tempo = text2num(params["new"])
			if(new_tempo <= 0)
				return
			tempo = sanitize_tempo(new_tempo)
		if("play")
			if(playing)
				return
			playing = TRUE
			INVOKE_ASYNC(src, .proc/play_song, usr)
		if("insertline")
			var/num = round(text2num(params["line"]))
			if(num <= 0)
				return
			if(length(lines) > SONG_MAX_LINE_LENGTH)
				return
			var/newline = html_encode(input("Enter your line: ", instrument_obj.name) as text|null)
			if(!newline || !in_range(instrument_obj, usr))
				return
			if(length(newline) > SONG_MAX_LINE_LENGTH)
				newline = copytext(newline, 1, SONG_MAX_LINE_LENGTH)
			lines.Insert(num, newline)
		if("deleteline")
			var/num = round(text2num(params["line"]))
			if(num <= 0 || num > length(lines))
				return
			lines.Cut(num, num + 1)
		if("modifyline")
			var/num = round(text2num(params["line"]))
			var/content = html_encode(input("Enter your line: ", instrument_obj.name, lines[num]) as text|null)
			if(!content || !in_range(instrument_obj, usr))
				return
			if(num <= 0 || num > length(lines))
				return
			if(length(content) > SONG_MAX_LINE_LENGTH)
				content = copytext(content, 1, SONG_MAX_LINE_LENGTH)
			lines[num] = content
		if("stop")
			playing = FALSE
		else
			return FALSE
	instrument_obj.add_fingerprint(usr)

/**
  * Processes a multi-line text into playable lines
  *
  * Arguments:
  * * text - Text to process
  */
/datum/song/proc/process_import(text)
	lines = splittext(text, "\n")
	if(!length(lines))
		return
	if(copytext(lines[1], 1, 6) == "BPM: ")
		tempo = sanitize_tempo(600 / text2num(copytext(lines[1], 6)))
		lines.Cut(1, 2)
	else
		tempo = sanitize_tempo(5) // default 120 BPM
	if(length(lines) > SONG_MAX_LINE_LENGTH)
		to_chat(usr, "Too many lines!")
		lines.Cut(201)
	var/linenum = 1
	for(var/l in lines)
		if(length(l) > SONG_MAX_LINE_LENGTH)
			to_chat(usr, "Line [linenum] too long!")
			lines.Remove(l)
		else
			linenum++
	SStgui.update_uis(instrument_obj)

/**
  * Sanitizes a tempo in accordance with world.tick_lag
  *
  * Arguments:
  * * new_tempo - The tempo to sanitize
  */
/datum/song/proc/sanitize_tempo(new_tempo)
	new_tempo = abs(new_tempo)
	return max(round(new_tempo, world.tick_lag), world.tick_lag)

// subclass for handheld instruments, like violin
/datum/song/handheld

/datum/song/handheld/should_stop_playing()
	if(instrument_obj)
		return !isliving(instrument_obj.loc)
	else
		return TRUE

//////////////////////////////////////////////////////////////////////////

/obj/structure/piano
	name = "space minimoog"
	icon = 'icons/obj/musician.dmi'
	icon_state = "minimoog"
	anchored = TRUE
	density = TRUE
	var/datum/song/song

/obj/structure/piano/New()
	..()
	song = new("piano", src)

	if(prob(50))
		name = "space minimoog"
		desc = "This is a minimoog, like a space piano, but more spacey!"
		icon_state = "minimoog"
	else
		name = "space piano"
		desc = "This is a space piano, like a regular piano, but always in tune! Even if the musician isn't."
		icon_state = "piano"

/obj/structure/piano/Destroy()
	QDEL_NULL(song)
	return ..()

/obj/structure/piano/Initialize()
	if(song)
		song.tempo = song.sanitize_tempo(song.tempo) // tick_lag isn't set when the map is loaded
	..()

/obj/structure/piano/attack_hand(mob/user)
	tgui_interact(user)

/obj/structure/piano/tgui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/tgui_state/state = GLOB.tgui_default_state)
	if(!isliving(user) || user.incapacitated() || !anchored)
		return

	song.tgui_interact(user, ui_key, ui, force_open)

/obj/structure/piano/tgui_data(mob/user)
	return song.tgui_data(user)

/obj/structure/piano/tgui_act(action, params)
	if(..())
		return
	return song.tgui_act(action, params)

/obj/structure/piano/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	if(!anchored && !isinspace())
		WRENCH_ANCHOR_MESSAGE
		if(!I.use_tool(src, user, 20, volume = I.tool_volume))
			return
		user.visible_message( \
			"[user] tightens [src]'s casters.", \
			"<span class='notice'> You have tightened [src]'s casters. Now it can be played again.</span>", \
			"You hear ratchet.")
		anchored = TRUE
	else if(anchored)
		to_chat(user, "<span class='notice'> You begin to loosen [src]'s casters...</span>")
		if(!I.use_tool(src, user, 40, volume = I.tool_volume))
			return
		user.visible_message( \
			"[user] loosens [src]'s casters.", \
			"<span class='notice'> You have loosened [src]. Now it can be pulled somewhere else.</span>", \
			"You hear ratchet.")
		anchored = FALSE
	else
		to_chat(user, "<span class='warning'>[src] needs to be bolted to the floor!</span>")

#undef SONG_HEAR_DISTANCE
#undef SONG_FALLOFF
#undef SONG_MAX_TEMPO
#undef SONG_MAX_LENGTH
#undef SONG_MAX_LINE_LENGTH
