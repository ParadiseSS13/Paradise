/obj/item/taperecorder
	name = "universal recorder"
	desc = "A device that can record to cassette tapes, and play them. It automatically translates the content in playback."
	icon = 'icons/obj/device.dmi'
	icon_state = "taperecorder_empty"
	inhand_icon_state = "analyzer"
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_BELT
	materials = list(MAT_METAL = 180, MAT_GLASS = 90)
	force = 2
	drop_sound = 'sound/items/handling/taperecorder_drop.ogg'
	pickup_sound = 'sound/items/handling/taperecorder_pickup.ogg'
	/// If its currently recording
	var/recording
	/// If its playing back auto via atom_say
	var/playing
	/// The amount of time between something said during playback
	var/playsleepseconds = 0
	/// The tape we are recording to
	var/obj/item/tape/mytape
	/// The next worldtime we'll be able to print
	var/cooldown = 0
	var/starts_with_tape = TRUE
	/// Sound loop that plays when recording or playing back.
	var/datum/looping_sound/tape_recorder_hiss/soundloop
	new_attack_chain = TRUE

/obj/item/taperecorder/examine(mob/user)
	. = ..()
	if(in_range(user, src) && mytape)
		if(mytape.ruined)
			. += SPAN_NOTICE("[mytape]'s internals are unwound.'.")
		if(mytape.max_capacity <= mytape.used_capacity)
			. += SPAN_NOTICE("[mytape] is full.")
		else if((mytape.remaining_capacity % 60) == 0) // if there is no seconds (modulo = 0), then only show minutes
			. += SPAN_NOTICE("[mytape] has [mytape.remaining_capacity / 60] minutes remaining.")
		else
			if(mytape.used_capacity >= mytape.max_capacity - 60)
				. += SPAN_NOTICE("[mytape] has [mytape.remaining_capacity] seconds remaining.") // to avoid having 0 minutes
			else
				. += SPAN_NOTICE("[mytape] has [seconds_to_time(mytape.remaining_capacity)] remaining.")
		. += SPAN_NOTICE("Alt-Click to access the tape.")

/obj/item/taperecorder/Initialize(mapload)
	. = ..()
	if(starts_with_tape)
		mytape = new /obj/item/tape/random(src)
		update_icon(UPDATE_ICON_STATE)
	soundloop = new(list(src))

/obj/item/taperecorder/Destroy()
	QDEL_NULL(mytape)
	QDEL_NULL(soundloop)
	return ..()

/obj/item/taperecorder/proc/update_sound()
	if(!playing && !recording)
		soundloop.stop()
	else
		soundloop.start()

/obj/item/taperecorder/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(!mytape && istype(used, /obj/item/tape))
		if(user.drop_item())
			used.forceMove(src)
			mytape = used
			to_chat(user, SPAN_NOTICE("You insert [used] into [src]."))
			playsound(src, 'sound/items/taperecorder/taperecorder_close.ogg', 50, FALSE)
			update_icon(UPDATE_ICON_STATE)
			return ITEM_INTERACT_COMPLETE

/obj/item/taperecorder/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume, global_overlay = TRUE)
	mytape?.ruin() //Fires destroy the tape
	return ..()

/obj/item/taperecorder/attack_hand(mob/user)
	if(loc == user)
		if(mytape)
			if(!user.is_holding(src))
				..()
				return
			eject(user)
			return
	..()

/obj/item/taperecorder/hear_talk(mob/living/M, list/message_pieces) // Currently can't tell if you're whispering, but can hear it if nearby
	var/msg = multilingual_to_message(message_pieces)
	if(mytape && recording)
		var/ending = copytext(msg, length(msg))
		mytape.timestamp += mytape.used_capacity
		if(M.AmountStuttering())
			mytape.storedinfo += "\[[time2text(mytape.used_capacity * 10,"mm:ss")]\] [M.name] stammers, \"[msg]\""
			return
		if(M.getBrainLoss() >= 60)
			mytape.storedinfo += "\[[time2text(mytape.used_capacity * 10,"mm:ss")]\] [M.name] gibbers, \"[msg]\""
			return
		if(ending == "?")
			mytape.storedinfo += "\[[time2text(mytape.used_capacity * 10,"mm:ss")]\] [M.name] asks, \"[msg]\""
			return
		else if(ending == "!")
			mytape.storedinfo += "\[[time2text(mytape.used_capacity * 10,"mm:ss")]\] [M.name] exclaims, \"[msg]\""
			return
		mytape.storedinfo += "\[[time2text(mytape.used_capacity * 10,"mm:ss")]\] [M.name] says, \"[msg]\""

/obj/item/taperecorder/hear_message(mob/living/M as mob, msg)
	if(mytape && recording)
		mytape.timestamp += mytape.used_capacity
		mytape.storedinfo += "\[[time2text(mytape.used_capacity * 10,"mm:ss")]\] [M.name] [msg]"

/obj/item/taperecorder/activate_self(mob/user)
	if(..())
		return

	if(!mytape || mytape.ruined)
		return
	if(recording)
		stop()
	else
		record()

/obj/item/taperecorder/AltClick(mob/user)
	if(in_range(user, src) && mytape && !HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		var/list/options = list(
			"Playback Tape" = image(icon = 'icons/obj/device.dmi', icon_state = "taperecorder_playing"),
			"Print Transcript" = image(icon = 'icons/obj/bureaucracy.dmi', icon_state = "paper_words"),
			"Eject Tape" = image(icon = 'icons/obj/device.dmi', icon_state = "[mytape.icon_state]")
		)
		var/choice = show_radial_menu(user, src, options)
		if(user.incapacitated())
			return
		switch(choice)
			if("Playback Tape")
				play(user)
			if("Print Transcript")
				print_transcript(user)
			if("Eject Tape")
				eject(user)

/obj/item/taperecorder/proc/record(mob/user)
	if(!mytape || mytape.ruined)
		return
	if(recording)
		return
	if(playing)
		return

	playsound(src, 'sound/items/taperecorder/taperecorder_play.ogg', 50, FALSE)

	if(mytape.used_capacity < mytape.max_capacity)
		recording = TRUE
		atom_say("Recording started.")
		update_sound()
		update_icon(UPDATE_ICON_STATE)
		mytape.timestamp += mytape.used_capacity
		mytape.storedinfo += "\[[time2text(mytape.used_capacity * 10,"mm:ss")]\] Recording started."
		var/used = mytape.used_capacity	//to stop runtimes when you eject the tape
		var/max = mytape.max_capacity
		for(used, used < max)
			if(recording == 0)
				break
			mytape.used_capacity++
			used++
			mytape.remaining_capacity = mytape.max_capacity - mytape.used_capacity
			sleep(10)
		stop()
	else
		atom_say("[mytape] is full!")
		playsound(src, 'sound/items/taperecorder/taperecorder_stop.ogg', 50, FALSE)


/obj/item/taperecorder/proc/stop(PlaybackOverride = FALSE)
	if(recording)
		mytape.timestamp += mytape.used_capacity
		mytape.storedinfo += "\[[time2text(mytape.used_capacity * 10,"mm:ss")]\] Recording stopped."
		playsound(src, 'sound/items/taperecorder/taperecorder_stop.ogg', 50, FALSE)
		atom_say("Recording stopped.")
		recording = FALSE
	else if(playing)
		playsound(src, 'sound/items/taperecorder/taperecorder_stop.ogg', 50, FALSE)
		if(!PlaybackOverride)
			atom_say("Playback stopped.")
		playing = FALSE
	update_icon(UPDATE_ICON_STATE)
	update_sound()


/obj/item/taperecorder/proc/play(mob/user)
	if(!mytape || mytape.ruined)
		return
	if(recording)
		return
	if(playing)
		stop()
		return
	if(!length(mytape.storedinfo))
		atom_say("There is no stored data.")
		playsound(src, 'sound/items/taperecorder/taperecorder_play.ogg', 50, FALSE)
		playsound(src, 'sound/items/taperecorder/taperecorder_stop.ogg', 50, FALSE)
		return

	playing = TRUE
	update_icon(UPDATE_ICON_STATE)
	update_sound()
	atom_say("Playback started.")
	playsound(src, 'sound/items/taperecorder/taperecorder_play.ogg', 50, FALSE)
	var/used = mytape.used_capacity	//to stop runtimes when you eject the tape
	var/max = mytape.max_capacity
	for(var/i = 1, used <= max) // <= to let it play if the tape is full
		sleep(playsleepseconds)
		if(!mytape)
			break
		if(playing == 0)
			break
		if(length(mytape.storedinfo) < i)
			atom_say("End of recording.")
			break
		atom_say("[mytape.storedinfo[i]]")
		if(length(mytape.storedinfo) < i + 1 || playsleepseconds > 1.4 SECONDS)
			playsleepseconds = 1 SECONDS
		else
			playsleepseconds = (mytape.timestamp[i + 1] - mytape.timestamp[i]) SECONDS
		i++

	stop(TRUE)

/obj/item/taperecorder/proc/print_transcript(mob/user)
	if(!mytape)
		return
	if(world.time < cooldown)
		to_chat(user, SPAN_NOTICE("The recorder can't print that fast!"))
		return
	if(recording || playing)
		return

	atom_say("Transcript printed.")
	playsound(loc, 'sound/goonstation/machines/printer_thermal.ogg', 50, 1)
	var/obj/item/paper/P = new /obj/item/paper(get_turf(src))
	var/t1 = "<B>Transcript:</B><BR><BR>"
	for(var/i = 1, length(mytape.storedinfo) >= i, i++)
		t1 += "[mytape.storedinfo[i]]<BR>"
	P.info = t1
	P.name = "paper- 'Transcript'"
	user.put_in_hands(P)
	cooldown = world.time + 3 SECONDS

/obj/item/taperecorder/proc/eject(mob/user)
	if(HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return
	if(mytape)
		playsound(src, 'sound/items/taperecorder/taperecorder_open.ogg', 50, FALSE)
		to_chat(user, SPAN_NOTICE("You remove [mytape] from [src]."))
		stop()
		user.put_in_hands(mytape)
		mytape = null
		update_icon(UPDATE_ICON_STATE)

/obj/item/taperecorder/update_icon_state()
	if(!mytape)
		icon_state = "taperecorder_empty"
	else if(recording)
		icon_state = "taperecorder_recording"
	else if(playing)
		icon_state = "taperecorder_playing"
	else
		icon_state = "taperecorder_idle"

//empty tape recorders
/obj/item/taperecorder/empty
	starts_with_tape = FALSE

/obj/item/tape
	name = "tape"
	desc = "A magnetic tape that can hold up to ten minutes of content."
	icon = 'icons/obj/device.dmi'
	icon_state = "tape_white"
	inhand_icon_state = "analyzer"
	w_class = WEIGHT_CLASS_TINY
	materials = list(MAT_METAL = 40, MAT_GLASS = 10)
	force = 1
	drop_sound = 'sound/items/handling/tape_drop.ogg'
	pickup_sound = 'sound/items/handling/tape_pickup.ogg'
	var/max_capacity = 600
	var/used_capacity = 0
	var/remaining_capacity = 600
	var/list/storedinfo = list()
	var/list/timestamp = list()
	var/ruined = FALSE
	new_attack_chain = TRUE

/obj/item/tape/examine(mob/user)
	. = ..()
	if(in_range(user, src))
		if(ruined)
			. += SPAN_NOTICE("It's tape is all pulled out, it looks it could be <b>screwed</b> back into place.")
		else if(max_capacity <= used_capacity)
			. += SPAN_NOTICE("It is full.")
		else if((remaining_capacity % 60) == 0) // if there is no seconds (modulo = 0), then only show minutes
			. += SPAN_NOTICE("It has [remaining_capacity / 60] minutes remaining.")
		else
			if(used_capacity >= (max_capacity - 60))
				. += SPAN_NOTICE("It has [remaining_capacity] seconds remaining.") // to avoid having 0 minutes
			else
				. += SPAN_NOTICE("It has [seconds_to_time(remaining_capacity)] remaining.")
		. += "<span class='notice'>You can <b>Alt-Click</b> [src] to wipe the current tape."

/obj/item/tape/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume, global_overlay = TRUE)
	..()
	ruin()

/obj/item/tape/activate_self(mob/user)
	if(..())
		return

	if(!ruined)
		ruin(user)

/obj/item/tape/AltClick(mob/user)
	if(user.stat || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || !Adjacent(user))
		return
	if(ruined)
		to_chat(user, SPAN_NOTICE("This tape is already ruined!"))
		return
	if(!do_after(user, 3 SECONDS, target = src))
		return

	to_chat(user, SPAN_NOTICE("You erase the data from [src]."))
	used_capacity = 0
	remaining_capacity = max_capacity
	storedinfo.Cut()
	timestamp.Cut()

/obj/item/tape/update_overlays()
	. = ..()
	if(ruined)
		. += "ribbonoverlay"

/obj/item/tape/proc/ruin(mob/user)
	if(user)
		to_chat(user, SPAN_NOTICE("You start pulling the tape out."))
		if(!do_after(user, 1 SECONDS, target = src))
			return
		to_chat(user, SPAN_NOTICE("You pull the tape out of [src]."))
	ruined = TRUE
	update_icon(UPDATE_OVERLAYS)

/obj/item/tape/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(is_pen(used))
		rename_interactive(user, used)
		return ITEM_INTERACT_COMPLETE

/obj/item/tape/screwdriver_act(mob/living/user, obj/item/I)
	. = ..()
	if(ruined)
		if(!I.use_tool(src, user, 0, volume = I.tool_volume))
			return
		to_chat(user, SPAN_NOTICE("You start winding the tape back in."))
		if(do_after(user, 120 * I.toolspeed, target = src))
			to_chat(user, SPAN_NOTICE("You wind the tape back in!"))
			ruined = FALSE
			update_icon(UPDATE_OVERLAYS)

//Random colour tapes
/obj/item/tape/random/Initialize(mapload)
	. = ..()
	icon_state = "tape_[pick("white", "blue", "red", "yellow", "purple")]"
