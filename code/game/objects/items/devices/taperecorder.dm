/obj/item/device/taperecorder
	name = "universal recorder"
	desc = "A device that can record to cassette tapes, and play them. It automatically translates the content in playback."
	icon_state = "taperecorder_empty"
	item_state = "analyzer"
	w_class = 2
	slot_flags = SLOT_BELT
	materials = list(MAT_METAL=60, MAT_GLASS=30)
	force = 2
	throwforce = 0
	var/recording = 0
	var/playing = 0
	var/playsleepseconds = 0
	var/obj/item/device/tape/mytape
	var/open_panel = 0
	var/canprint = 1


/obj/item/device/taperecorder/New()
	mytape = new /obj/item/device/tape/random(src)
	update_icon()

/obj/item/device/taperecorder/examine(mob/user)
	if(..(user, 1))
		user << "The wire panel is [open_panel ? "opened" : "closed"]."


/obj/item/device/taperecorder/attackby(obj/item/I, mob/user)
	if(!mytape && istype(I, /obj/item/device/tape))
		user.drop_item()
		I.loc = src
		mytape = I
		user << "<span class='notice'>You insert [I] into [src].</span>"
		update_icon()

/obj/item/device/taperecorder/proc/eject(mob/user)
	if(mytape)
		user << "<span class='notice'>You remove [mytape] from [src].</span>"
		stop()
		user.put_in_hands(mytape)
		mytape = null
		update_icon()


/obj/item/device/taperecorder/attack_hand(mob/user)
	if(loc == user)
		if(mytape)
			if(user.l_hand != src && user.r_hand != src)
				..()
				return
			eject(user)
			return
	..()


/obj/item/device/taperecorder/verb/ejectverb()
	set name = "Eject Tape"
	set category = "Object"

	if(usr.stat)
		return
	if(!mytape)
		return

	eject(usr)


/obj/item/device/taperecorder/update_icon()
	if(!mytape)
		icon_state = "taperecorder_empty"
	else if(recording)
		icon_state = "taperecorder_recording"
	else if(playing)
		icon_state = "taperecorder_playing"
	else
		icon_state = "taperecorder_idle"


/obj/item/device/taperecorder/hear_talk(mob/living/M as mob, msg)
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
		
/obj/item/device/taperecorder/hear_message(mob/living/M as mob, msg)
	if(mytape && recording)
		mytape.timestamp += mytape.used_capacity
		mytape.storedinfo += "\[[time2text(mytape.used_capacity * 10,"mm:ss")]\] [M.name] [msg]"

/obj/item/device/taperecorder/verb/record()
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
		usr << "<span class='notice'>Recording started.</span>"
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
		usr << "<span class='notice'>The tape is full.</span>"


/obj/item/device/taperecorder/verb/stop()
	set name = "Stop"
	set category = "Object"

	if(usr.stat)
		return

	if(recording)
		recording = 0
		mytape.timestamp += mytape.used_capacity
		mytape.storedinfo += "\[[time2text(mytape.used_capacity * 10,"mm:ss")]\] Recording stopped."
		usr << "<span class='notice'>Recording stopped.</span>"
		return
	else if(playing)
		playing = 0
		var/turf/T = get_turf(src)
		T.visible_message("<font color=Maroon><B>Tape Recorder</B>: Playback stopped.</font>")
	update_icon()


/obj/item/device/taperecorder/verb/play()
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
	usr << "<span class='notice'>Playing started.</span>"
	var/used = mytape.used_capacity	//to stop runtimes when you eject the tape
	var/max = mytape.max_capacity
	for(var/i = 1, used < max, sleep(10 * playsleepseconds))
		if(!mytape)
			break
		if(playing == 0)
			break
		if(mytape.storedinfo.len < i)
			break
		var/turf/T = get_turf(src)
		T.visible_message("<font color=Maroon><B>Tape Recorder</B>: [mytape.storedinfo[i]]</font>")
		if(mytape.storedinfo.len < i + 1)
			playsleepseconds = 1
			sleep(10)
			T = get_turf(src)
			T.visible_message("<font color=Maroon><B>Tape Recorder</B>: End of recording.</font>")
		else
			playsleepseconds = mytape.timestamp[i + 1] - mytape.timestamp[i]
		if(playsleepseconds > 14)
			sleep(10)
			T = get_turf(src)
			T.visible_message("<font color=Maroon><B>Tape Recorder</B>: Skipping [playsleepseconds] seconds of silence</font>")
			playsleepseconds = 1
		i++

	playing = 0
	update_icon()


/obj/item/device/taperecorder/attack_self(mob/user)
	if(!mytape || mytape.ruined)
		return
	if(recording)
		stop()
	else
		record()


/obj/item/device/taperecorder/verb/print_transcript()
	set name = "Print Transcript"
	set category = "Object"

	if(usr.stat)
		return
	if(!mytape)
		return
	if(!canprint)
		usr << "<span class='notice'>The recorder can't print that fast!</span>"
		return
	if(recording || playing)
		return

	usr << "<span class='notice'>Transcript printed.</span>"
	var/obj/item/weapon/paper/P = new /obj/item/weapon/paper(get_turf(src))
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
/obj/item/device/taperecorder/empty/New()
	return


/obj/item/device/tape
	name = "tape"
	desc = "A magnetic tape that can hold up to ten minutes of content."
	icon_state = "tape_white"
	item_state = "analyzer"
	w_class = 1
	materials = list(MAT_METAL=20, MAT_GLASS=5)
	force = 1
	throwforce = 0
	var/max_capacity = 600
	var/used_capacity = 0
	var/list/storedinfo = list()
	var/list/timestamp = list()
	var/ruined = 0


/obj/item/device/tape/attack_self(mob/user)
	if(!ruined)
		user << "<span class='notice'>You pull out all the tape!</span>"
		ruin()


/obj/item/device/tape/proc/ruin()
	overlays += "ribbonoverlay"
	ruined = 1


/obj/item/device/tape/proc/fix()
	overlays -= "ribbonoverlay"
	ruined = 0


/obj/item/device/tape/attackby(obj/item/I, mob/user)
	if(ruined && istype(I, /obj/item/weapon/screwdriver))
		user << "<span class='notice'>You start winding the tape back in.</span>"
		if(do_after(user, 120, target = src))
			user << "<span class='notice'>You wound the tape back in!</span>"
			fix()


//Random colour tapes
/obj/item/device/tape/random/New()
	icon_state = "tape_[pick("white", "blue", "red", "yellow", "purple")]"