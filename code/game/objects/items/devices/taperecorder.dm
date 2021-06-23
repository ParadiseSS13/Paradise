/obj/item/taperecorder
	name = "universal recorder"
	desc = "A device that can record to cassette tapes, and play them. It automatically translates the content in playback."
	icon = 'icons/obj/device.dmi'
	icon_state = "taperecorder_empty"
	item_state = "analyzer"
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = SLOT_BELT
	materials = list(MAT_METAL=60, MAT_GLASS=30)
	force = 2
	throwforce = 0
	drop_sound = 'sound/items/handling/taperecorder_drop.ogg'
	pickup_sound = 'sound/items/handling/taperecorder_pickup.ogg'
	var/recording = 0
	var/playing = 0
	var/playsleepseconds = 0
	var/obj/item/tape/mytape
	var/open_panel = 0
	var/canprint = 1
	var/starts_with_tape = TRUE
	///Sound loop that plays when recording or playing back.
	var/datum/looping_sound/tape_recorder_hiss/soundloop


/obj/item/taperecorder/New()
	..()
	if(starts_with_tape)
		mytape = new /obj/item/tape/random(src)
		update_icon()
	soundloop = new(list(src))

/obj/item/taperecorder/Destroy()
	QDEL_NULL(mytape)
	QDEL_NULL(soundloop)
	return ..()

/obj/item/taperecorder/examine(mob/user)
	. = ..()
	if(in_range(user, src))
		. += "The wire panel is [open_panel ? "opened" : "closed"]."


/obj/item/taperecorder/proc/update_sound()
	if(!playing && !recording)
		soundloop.stop()
	else
		soundloop.start()

/obj/item/taperecorder/attackby(obj/item/I, mob/user)
	if(!mytape && istype(I, /obj/item/tape))
		if(user.drop_item())
			I.forceMove(src)
			mytape = I
			to_chat(user, "<span class='notice'>You insert [I] into [src].</span>")
			playsound(src, 'sound/items/taperecorder/taperecorder_close.ogg', 50, FALSE)
			update_icon()

/obj/item/taperecorder/proc/eject(mob/user)
	if(mytape)
		playsound(src, 'sound/items/taperecorder/taperecorder_open.ogg', 50, FALSE)
		to_chat(user, "<span class='notice'>You remove [mytape] from [src].</span>")
		stop()
		user.put_in_hands(mytape)
		mytape = null
		update_icon()


/obj/item/taperecorder/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume, global_overlay = TRUE)
	mytape?.ruin() //Fires destroy the tape
	return ..()

/obj/item/taperecorder/attack_hand(mob/user)
	if(loc == user)
		if(mytape)
			if(user.l_hand != src && user.r_hand != src)
				..()
				return
			eject(user)
			return
	..()


/obj/item/taperecorder/verb/ejectverb()
	set name = "Eject Tape"
	set category = "Object"

	if(usr.incapacitated())
		return
	if(!mytape)
		return

	eject(usr)


/obj/item/taperecorder/update_icon()
	if(!mytape)
		icon_state = "taperecorder_empty"
	else if(recording)
		icon_state = "taperecorder_recording"
	else if(playing)
		icon_state = "taperecorder_playing"
	else
		icon_state = "taperecorder_idle"


/obj/item/taperecorder/hear_talk(mob/living/M as mob, list/message_pieces)
	var/msg = multilingual_to_message(message_pieces)
	if(mytape && recording)
		var/ending = copytext(msg, length(msg))
		mytape.timestamp += mytape.used_capacity
		if(M.stuttering)
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

/obj/item/taperecorder/verb/record()
	set name = "Start Recording"
	set category = "Object"

	if(usr.incapacitated())
		return
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
		update_icon()
		mytape.timestamp += mytape.used_capacity
		mytape.storedinfo += "\[[time2text(mytape.used_capacity * 10,"mm:ss")]\] Recording started."
		var/used = mytape.used_capacity	//to stop runtimes when you eject the tape
		var/max = mytape.max_capacity
		for(used, used < max)
			if(recording == 0)
				break
			mytape.used_capacity++
			used++
			sleep(10)
		stop()
	else
		atom_say("The tape is full!")
		playsound(src, 'sound/items/taperecorder/taperecorder_stop.ogg', 50, FALSE)


/obj/item/taperecorder/verb/stop()
	set name = "Stop"
	set category = "Object"

	if(usr.incapacitated())
		return

	if(recording)
		mytape.timestamp += mytape.used_capacity
		mytape.storedinfo += "\[[time2text(mytape.used_capacity * 10,"mm:ss")]\] Recording stopped."
		playsound(src, 'sound/items/taperecorder/taperecorder_stop.ogg', 50, FALSE)
		atom_say("Recording stopped.")
		recording = FALSE
	else if(playing)
		playsound(src, 'sound/items/taperecorder/taperecorder_stop.ogg', 50, FALSE)
		atom_say("Playback stopped.")
		playing = FALSE
	update_icon()
	update_sound()


/obj/item/taperecorder/verb/play()
	set name = "Play Tape"
	set category = "Object"

	if(usr.incapacitated())
		return
	if(!mytape || mytape.ruined)
		return
	if(recording)
		return
	if(playing)
		return

	playing = TRUE
	update_icon()
	update_sound()
	atom_say("Playback started.")
	playsound(src, 'sound/items/taperecorder/taperecorder_play.ogg', 50, FALSE)
	var/used = mytape.used_capacity	//to stop runtimes when you eject the tape
	var/max = mytape.max_capacity
	for(var/i = 1, used < max, sleep(10 * playsleepseconds))
		if(!mytape)
			break
		if(playing == 0)
			break
		if(mytape.storedinfo.len < i)
			atom_say("End of recording.")
			break
		atom_say("[mytape.storedinfo[i]]")
		if(mytape.storedinfo.len < i + 1)
			playsleepseconds = 1
			sleep(10)
			atom_say("End of recording.")
		else
			playsleepseconds = mytape.timestamp[i + 1] - mytape.timestamp[i]
		if(playsleepseconds > 14)
			sleep(10)
			atom_say("Skipping [playsleepseconds] seconds of silence.")
			playsleepseconds = 1
		i++

	stop()


/obj/item/taperecorder/attack_self(mob/user)
	if(!mytape || mytape.ruined)
		return
	if(recording)
		stop()
	else
		record()


/obj/item/taperecorder/verb/print_transcript()
	set name = "Print Transcript"
	set category = "Object"

	if(usr.incapacitated())
		return
	if(!mytape)
		return
	if(!canprint)
		to_chat(usr, "<span class='notice'>The recorder can't print that fast!</span>")
		return
	if(recording || playing)
		return

	atom_say("Transcript printed.")
	playsound(loc, 'sound/goonstation/machines/printer_thermal.ogg', 50, 1)
	var/obj/item/paper/P = new /obj/item/paper(get_turf(src))
	var/t1 = "<B>Transcript:</B><BR><BR>"
	for(var/i = 1, mytape.storedinfo.len >= i, i++)
		t1 += "[mytape.storedinfo[i]]<BR>"
	P.info = t1
	P.name = "paper- 'Transcript'"
	usr.put_in_hands(P)
	canprint = 0
	sleep(300)
	canprint = 1

//empty tape recorders
/obj/item/taperecorder/empty
	starts_with_tape = FALSE


/obj/item/tape
	name = "tape"
	desc = "A magnetic tape that can hold up to ten minutes of content."
	icon = 'icons/obj/device.dmi'
	icon_state = "tape_white"
	item_state = "analyzer"
	w_class = WEIGHT_CLASS_TINY
	materials = list(MAT_METAL=20, MAT_GLASS=5)
	force = 1
	throwforce = 0
	drop_sound = 'sound/items/handling/tape_drop.ogg'
	pickup_sound = 'sound/items/handling/tape_pickup.ogg'
	var/max_capacity = 600
	var/used_capacity = 0
	var/list/storedinfo = list()
	var/list/timestamp = list()
	var/ruined = 0

/obj/item/tape/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume, global_overlay = TRUE)
	..()
	ruin()

/obj/item/tape/attack_self(mob/user)
	if(!ruined)
		to_chat(user, "<span class='notice'>You pull out all the tape!</span>")
		ruin()

/obj/item/tape/verb/wipe()
	set name = "Wipe Tape"
	set category = "Object"

	if(usr.stat)
		return
	if(ruined)
		return

	to_chat(usr, "<span class='notice'>You erase the data from [src].</span>")
	clear()

/obj/item/tape/proc/clear()
	used_capacity = 0
	storedinfo.Cut()
	timestamp.Cut()

/obj/item/tape/proc/ruin()
	if(!ruined)
		overlays += "ribbonoverlay"
	ruined = 1



/obj/item/tape/proc/fix()
	overlays -= "ribbonoverlay"
	ruined = 0


/obj/item/tape/attackby(obj/item/I, mob/user)
	if(ruined && istype(I, /obj/item/screwdriver))
		to_chat(user, "<span class='notice'>You start winding the tape back in.</span>")
		if(do_after(user, 120 * I.toolspeed, target = src))
			to_chat(user, "<span class='notice'>You wound the tape back in!</span>")
			fix()
	else if(istype(I, /obj/item/pen))
		rename_interactive(user, I)

//Random colour tapes
/obj/item/tape/random/New()
	..()
	icon_state = "tape_[pick("white", "blue", "red", "yellow", "purple")]"
