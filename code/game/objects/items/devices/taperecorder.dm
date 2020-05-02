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
	var/recording = 0
	var/playing = 0
	var/playsleepseconds = 0
	var/obj/item/tape/mytape
	var/open_panel = 0
	var/canprint = 1
	var/starts_with_tape = TRUE


/obj/item/taperecorder/New()
	..()
	if(starts_with_tape)
		mytape = new /obj/item/tape/random(src)
		update_icon()

/obj/item/taperecorder/Destroy()
	QDEL_NULL(mytape)
	return ..()

/obj/item/taperecorder/examine(mob/user)
	. = ..()
	if(in_range(user, src))
		. += "The wire panel is [open_panel ? "opened" : "closed"]."


/obj/item/taperecorder/attackby(obj/item/I, mob/user)
	if(!mytape && istype(I, /obj/item/tape))
		user.drop_item()
		I.loc = src
		mytape = I
		to_chat(user, "<span class='notice'>You insert [I] into [src].</span>")
		update_icon()

/obj/item/taperecorder/proc/eject(mob/user)
	if(mytape)
		to_chat(user, "<span class='notice'>You remove [mytape] from [src].</span>")
		stop()
		user.put_in_hands(mytape)
		mytape = null
		update_icon()


/obj/item/taperecorder/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume, global_overlay = TRUE)
	mytape.ruin() //Fires destroy the tape
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

	if(usr.stat)
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

	if(usr.stat)
		return
	if(!mytape || mytape.ruined)
		return
	if(recording)
		return
	if(playing)
		return

	if(mytape.used_capacity < mytape.max_capacity)
		to_chat(usr, "<span class='notice'>Recording started.</span>")
		recording = 1
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
		recording = 0
		update_icon()
	else
		to_chat(usr, "<span class='notice'>The tape is full.</span>")


/obj/item/taperecorder/verb/stop()
	set name = "Stop"
	set category = "Object"

	if(usr.stat)
		return

	if(recording)
		recording = 0
		mytape.timestamp += mytape.used_capacity
		mytape.storedinfo += "\[[time2text(mytape.used_capacity * 10,"mm:ss")]\] Recording stopped."
		to_chat(usr, "<span class='notice'>Recording stopped.</span>")
		return
	else if(playing)
		playing = 0
		atom_say("Playback stopped.")
	update_icon()


/obj/item/taperecorder/verb/play()
	set name = "Play Tape"
	set category = "Object"

	if(usr.stat)
		return
	if(!mytape || mytape.ruined)
		return
	if(recording)
		return
	if(playing)
		return

	playing = 1
	update_icon()
	to_chat(usr, "<span class='notice'>Playing started.</span>")
	var/used = mytape.used_capacity	//to stop runtimes when you eject the tape
	var/max = mytape.max_capacity
	for(var/i = 1, used < max, sleep(10 * playsleepseconds))
		if(!mytape)
			break
		if(playing == 0)
			break
		if(mytape.storedinfo.len < i)
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

	playing = 0
	update_icon()


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

	if(usr.stat)
		return
	if(!mytape)
		return
	if(!canprint)
		to_chat(usr, "<span class='notice'>The recorder can't print that fast!</span>")
		return
	if(recording || playing)
		return

	to_chat(usr, "<span class='notice'>Transcript printed.</span>")
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

	to_chat(usr, "You erase the data from the [src]")
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
		var/title = stripped_input(usr,"What do you want to name the tape?", "Tape Renaming", name, MAX_NAME_LEN)
		if(!title || !length(title))
			name = initial(name)
			return
		name = "tape - [title]"


//Random colour tapes
/obj/item/tape/random/New()
	..()
	icon_state = "tape_[pick("white", "blue", "red", "yellow", "purple")]"
