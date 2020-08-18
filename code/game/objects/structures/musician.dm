

/datum/song
	var/name = "Untitled"
	var/list/lines = new()
	var/tempo = 5			// delay between notes

	var/playing = 0			// if we're playing
	var/help = 0			// if help is open
	var/repeat = 0			// number of times remaining to repeat
	var/max_repeat = 10		// maximum times we can repeat

	var/instrumentDir = "piano"		// the folder with the sounds
	var/instrumentExt = "ogg"		// the file extension
	var/obj/instrumentObj = null	// the associated obj playing the sound

/datum/song/New(dir, obj, ext = "ogg")
	tempo = sanitize_tempo(tempo)
	instrumentDir = dir
	instrumentObj = obj
	instrumentExt = ext

/datum/song/Destroy()
	instrumentObj = null
	return ..()

// note is a number from 1-7 for A-G
// acc is either "b", "n", or "#"
// oct is 1-8 (or 9 for C)
/datum/song/proc/playnote(note, acc as text, oct)
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
	var/soundfile = "sound/instruments/[instrumentDir]/[ascii2text(note+64)][acc][oct].[instrumentExt]"
	soundfile = file(soundfile)
	// make sure the note exists
	if(!fexists(soundfile))
		return
	// and play
	var/turf/source = get_turf(instrumentObj)
	var/sound/music_played = sound(soundfile)
	for(var/A in hearers(15, source))
		var/mob/M = A
		if(!M.client || !(M.client.prefs.sound & SOUND_INSTRUMENTS))
			continue
		M.playsound_local(source, null, 100, falloff = 5, S = music_played)

/datum/song/proc/shouldStopPlaying(mob/user)
	if(instrumentObj)
		//if(!user.canUseTopic(instrumentObj))
			//return 1
		return !instrumentObj.anchored		// add special cases to stop in subclasses
	else
		return 1

/datum/song/proc/playsong(mob/user)
	while(repeat >= 0)
		var/cur_oct[7]
		var/cur_acc[7]
		for(var/i = 1 to 7)
			cur_oct[i] = 3
			cur_acc[i] = "n"

		for(var/line in lines)
			for(var/beat in splittext(lowertext(line), ","))
				var/list/notes = splittext(beat, "/")
				for(var/note in splittext(notes[1], "-"))
					if(!playing || shouldStopPlaying(user)) //If the instrument is playing, or special case
						playing = 0
						return
					if(length(note) == 0)
						continue
					var/cur_note = text2ascii(note) - 96
					if(cur_note < 1 || cur_note > 7)
						continue
					for(var/i=2 to length(note))
						var/ni = copytext(note,i,i+1)
						if(!text2num(ni))
							if(ni == "#" || ni == "b" || ni == "n")
								cur_acc[cur_note] = ni
							else if(ni == "s")
								cur_acc[cur_note] = "#" // so shift is never required
						else
							cur_oct[cur_note] = text2num(ni)
					playnote(cur_note, cur_acc[cur_note], cur_oct[cur_note])
				if(notes.len >= 2 && text2num(notes[2]))
					sleep(sanitize_tempo(tempo / text2num(notes[2])))
				else
					sleep(tempo)
		repeat--
	playing = 0
	repeat = 0

/datum/song/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	if(!instrumentObj)
		return

	ui = SSnanoui.try_update_ui(user, instrumentObj, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, instrumentObj, ui_key, "song.tmpl", instrumentObj.name, 700, 500)
		ui.open()
		ui.set_auto_update(1)

/datum/song/ui_data(mob/user, ui_key = "main", datum/topic_state/state = GLOB.default_state)
	var/data[0]

	data["lines"] = lines
	data["tempo"] = tempo

	data["playing"] = playing
	data["help"] = help
	data["repeat"] = repeat
	data["maxRepeat"] = max_repeat
	data["minTempo"] = world.tick_lag
	data["maxTempo"] = 600

	return data

/datum/song/Topic(href, href_list)
	if(!in_range(instrumentObj, usr) || (issilicon(usr) && instrumentObj.loc != usr) || !isliving(usr) || usr.incapacitated())
		usr << browse(null, "window=instrument")
		usr.unset_machine()
		return 1

	instrumentObj.add_fingerprint(usr)

	if(href_list["newsong"])
		playing = 0
		lines = new()
		tempo = sanitize_tempo(5) // default 120 BPM
		name = ""
		SSnanoui.update_uis(src)

	else if(href_list["import"])
		playing = 0
		var/t = ""
		do
			t = html_encode(input(usr, "Please paste the entire song, formatted:", text("[]", name), t) as message)
			if(!in_range(instrumentObj, usr))
				return

			if(length(t) >= 12000)
				var/cont = input(usr, "Your message is too long! Would you like to continue editing it?", "", "yes") in list("yes", "no")
				if(cont == "no")
					break
		while(length(t) > 12000)

		//split into lines
		spawn()
			lines = splittext(t, "\n")
			if(lines.len == 0)
				return 1
			if(copytext(lines[1],1,6) == "BPM: ")
				tempo = sanitize_tempo(600 / text2num(copytext(lines[1],6)))
				lines.Cut(1,2)
			else
				tempo = sanitize_tempo(5) // default 120 BPM
			if(lines.len > 200)
				to_chat(usr, "Too many lines!")
				lines.Cut(201)
			var/linenum = 1
			for(var/l in lines)
				if(length(l) > 200)
					to_chat(usr, "Line [linenum] too long!")
					lines.Remove(l)
				else
					linenum++
		SSnanoui.update_uis(src)

	else if(href_list["help"])
		help = !help
		SSnanoui.update_uis(src)

	if(href_list["repeat"]) //Changing this from a toggle to a number of repeats to avoid infinite loops.
		if(playing)
			return //So that people cant keep adding to repeat. If the do it intentionally, it could result in the server crashing.
		repeat += round(text2num(href_list["repeat"]))
		if(repeat < 0)
			repeat = 0
		if(repeat > max_repeat)
			repeat = max_repeat
		SSnanoui.update_uis(src)

	else if(href_list["tempo"])
		tempo = sanitize_tempo(tempo + text2num(href_list["tempo"]) * world.tick_lag)
		SSnanoui.update_uis(src)

	else if(href_list["play"])
		if(playing)
			return
		playing = 1
		spawn()
			playsong(usr)
		SSnanoui.update_uis(src)

	else if(href_list["insertline"])
		var/num = round(text2num(href_list["insertline"]))
		if(num < 1 || num > lines.len + 1)
			return

		var/newline = html_encode(input("Enter your line: ", instrumentObj.name) as text|null)
		if(!newline || !in_range(instrumentObj, usr))
			return
		if(lines.len > 200)
			return
		if(length(newline) > 200)
			newline = copytext(newline, 1, 200)

		lines.Insert(num, newline)
		SSnanoui.update_uis(src)

	else if(href_list["deleteline"])
		var/num = round(text2num(href_list["deleteline"]))
		if(num > lines.len || num < 1)
			return
		lines.Cut(num, num + 1)
		SSnanoui.update_uis(src)

	else if(href_list["modifyline"])
		var/num = round(text2num(href_list["modifyline"]))
		var/content = html_encode(input("Enter your line: ", instrumentObj.name, lines[num]) as text|null)
		if(!content || !in_range(instrumentObj, usr))
			return
		if(length(content) > 200)
			content = copytext(content, 1, 200)
		if(num > lines.len || num < 1)
			return
		lines[num] = content
		SSnanoui.update_uis(src)

	else if(href_list["stop"])
		playing = 0
		SSnanoui.update_uis(src)

/datum/song/proc/sanitize_tempo(new_tempo)
	new_tempo = abs(new_tempo)
	return max(round(new_tempo, world.tick_lag), world.tick_lag)

// subclass for handheld instruments, like violin
/datum/song/handheld

/datum/song/handheld/shouldStopPlaying()
	if(instrumentObj)
		return !isliving(instrumentObj.loc)
	else
		return 1


//////////////////////////////////////////////////////////////////////////


/obj/structure/piano
	name = "space minimoog"
	icon = 'icons/obj/musician.dmi'
	icon_state = "minimoog"
	anchored = 1
	density = 1
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

/obj/structure/piano/attack_hand(mob/user as mob)
	ui_interact(user)

/obj/structure/piano/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	if(!isliving(user) || user.incapacitated() || !anchored)
		return

	song.ui_interact(user, ui_key, ui, force_open)

/obj/structure/piano/ui_data(mob/user, ui_key = "main", datum/topic_state/state = GLOB.default_state)
	return song.ui_data(user, ui_key, state)

/obj/structure/piano/Topic(href, href_list)
	song.Topic(href, href_list)

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
