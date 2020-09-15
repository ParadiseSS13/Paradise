/**
  * Compiles our lines into "chords" with filenames for legacy playback. This makes there have to be a bit of lag at the beginning of the song, but repeats will not have to parse it again, and overall playback won't be impacted by as much lag.
  */
/datum/song/proc/compile_legacy()
	if(!length(src.lines))
		return
	var/list/lines = src.lines		//cache for hyepr speed!
	compiled_chords = list()
	var/list/octaves = list(3, 3, 3, 3, 3, 3, 3)
	var/list/accents = list("n", "n", "n", "n", "n", "n", "n")
	for(var/line in lines)
		var/list/chords = splittext(lowertext(line), ",")
		for(var/chord in chords)
			var/list/compiled_chord = list()
			var/tempodiv = 1
			var/list/notes_tempodiv = splittext(chord, "/")
			var/len = length(notes_tempodiv)
			if(len >= 2)
				tempodiv = text2num(notes_tempodiv[2])
			if(len)			//some dunkass is going to do ,,,, to make 3 rests instead of ,/1 because there's no standardization so let's be prepared for that.
				var/list/notes = splittext(notes_tempodiv[1], "-")
				for(var/note in notes)
					if(length(note) == 0)
						continue
					// 1-7, A-G
					var/key = text2ascii(note) - 96
					if((key < 1) || (key > 7))
						continue
					for(var/i in 2 to length(note))
						var/oct_acc = copytext(note, i, i + 1)
						var/num = text2num(oct_acc)
						if(!num)		//it's an accidental
							accents[key] = oct_acc		//if they misspelled it/fucked up that's on them lmao, no safety checks.
						else	//octave
							octaves[key] = clamp(num, octave_min, octave_max)
					compiled_chord[++compiled_chord.len] = list(key, accents[key], octaves[key])
			compiled_chord += tempodiv		//this goes last
			if(length(compiled_chord))
				compiled_chords[++compiled_chords.len] = compiled_chord

/**
  * Proc to play a legacy note. Just plays the sound to hearing mobs (and does hearcheck if necessary), no fancy channel/sustain/management.
  *
  * Arguments:
  * * note - number from 1-7 for A-G
  * * acc - either "b", "n", or "#"
  * * oct - 1-8 (or 9 for C)
  */
/datum/song/proc/playkey_legacy(note, acc as text, oct, mob/user)
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
	var/filename = "sound/instruments/[cached_legacy_dir]/[ascii2text(note + 64)][acc][oct].[cached_legacy_ext]"
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
	var/turf/source = get_turf(parent)
	if((world.time - MUSICIAN_HEARCHECK_MINDELAY) > last_hearcheck)
		do_hearcheck()
	var/sound/music_played = sound(soundfile)
	for(var/i in hearing_mobs)
		var/mob/M = i
		if(!(M.client?.prefs?.sound & SOUND_INSTRUMENTS))
			continue
		M.playsound_local(source, null, volume * using_instrument.volume_multiplier, falloff = 5, S = music_played)
		// Could do environment and echo later but not for now
