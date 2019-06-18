/obj/machinery/hispaniabox
	name = "Hispaniabox"
	desc = "Music for the bar."
	icon = 'icons/hispania/obj/hispaniabox.dmi'
	icon_state = "jukebox"
	anchored = FALSE
	atom_say_verb = "states"
	density = TRUE
	light_color = "#ff7b00"
	var/light_range_on = 2
	var/light_power_on = 1
	var/active = FALSE
	var/list/rangers = list()
	var/charge = 35
	var/stop = 0
	var/list/spotlights = list()
	var/list/sparkles = list()
	var/static/list/songs = list(
		new /datum/track("|Generic| Fighter - Jack Strauber", 					'sound/hispaniabox/Fighter.ogg', 	2450, 	5),
		new /datum/track("|Generic| Piano Man - Billy Joel", 					'sound/hispaniabox/Fighter.ogg', 	3450, 	5),
		new /datum/track("|Generic| Los Marcianos Llegaron Ya - Tito Rodriguez", 					'sound/music/title5.ogg', 	1740, 	5),
		new /datum/track("|Generic| Better Off Alone - SALEM Remix", 					'sound/music/title12.ogg', 	1750, 	5),
		new /datum/track("|Cyberpunk| Road - Niki Nine", 					'sound/hispaniabox/road.ogg', 	1690, 	5),
		new /datum/track("|Cyberpunk| Thriller - Scandroid", 					'sound/hispaniabox/thriller.ogg', 	1830, 	5),
		new /datum/track("|Cyberpunk| Binary Star - Shikimo", 					'sound/hispaniabox/binary.ogg', 	1750, 	5),
		new /datum/track("|Cyberpunk| Dance With The Dead - Andromeda", 					'sound/music/title1.ogg', 	3010, 	5),
		new /datum/track("|Lo-Fi Chill| Long Day - Guru Griff", 					'sound/hispaniabox/longday.ogg', 	104, 	5),
		new /datum/track("|Lo-Fi Chill| Sweetly - Kael", 					'sound/hispaniabox/sweetly.ogg', 	1360, 	5),
		new /datum/track("|Lo-Fi Chill| Space - Reflection", 					'sound/hispaniabox/spaceref.ogg', 	1270, 	5),
		new /datum/track("|Pop| Space Jam - ", 					'sound/music/title3.ogg', 	1930, 	5),
		new /datum/track("|Pop| Europa VII - La Oreja de Van Gogh", 					'sound/music/title10.ogg', 	2390, 	5),
		new /datum/track("|Pop-Rock| Space Oddity - David Bowie", 					'sound/music/title4.ogg', 	3310, 	5),



		)
	var/datum/track/selection = null

/datum/track
	song_name = "generic"
	song_path = null
	song_length = 0
	song_beat = 0
	GBP_required = 0

/datum/track/New(name, path, length, beat)
	song_name = name
	song_path = path
	song_length = length
	song_beat = beat

/obj/machinery/hispaniabox/proc/add_track(file, name, length, beat)
	var/sound/S = file
	if(!istype(S))
		return
	if(!name)
		name = "[file]"
	if(!beat)
		beat = 5
	if(!length)
		length = 2400 //Unless there's a way to discern via BYOND.
	var/datum/track/T = new /datum/track(name, file, length, beat)
	songs += T

/obj/machinery/hispaniabox/New()
	. = ..()
	selection = songs[1]


/obj/machinery/hispaniabox/Destroy()
	dance_over()
	selection = null
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/machinery/hispaniabox/attackby(obj/item/O, mob/user, params)
	if(!active)
		if(iswrench(O))
			if(!anchored && !isinspace())
				to_chat(user,"<span class='notice'>You secure [src] to the floor.</span>")
				anchored = TRUE
				set_light(light_range_on, light_power_on)
			else if(anchored)
				to_chat(user,"<span class='notice'>You unsecure and disconnect [src].</span>")
				anchored = FALSE
				set_light(0)
			playsound(src, 'sound/items/deconstruct.ogg', 50, 1)
			return
	return ..()

/obj/machinery/hispaniabox/update_icon()
	if(active)
		icon_state = "jukebox-running"
	else
		icon_state = "jukebox"
	..()


/obj/machinery/hispaniabox/attack_hand(mob/user)
	if(..())
		return

	interact(user)

/obj/machinery/hispaniabox/interact(mob/user)
	if(!anchored)
		to_chat(user,"<span class='warning'>This device must be anchored by a wrench!</span>")
		return
	if(!Adjacent(user) && !isAI(user))
		return
	user.set_machine(src)
	var/list/dat = list()
	dat +="<div class='statusDisplay' style='text-align:center'>"
	dat += "<b><A href='?src=[UID()];action=toggle'>[!active ? "PLAY MUSIC" : "STOP MUSIC"]<b></A><br>"
	dat += "</div><br>"
	dat += "<A href='?src=[UID()];action=select'> Select Track</A><br>"
	dat += "Track Selected: [selection.song_name]<br>"
	dat += "Track Length: [DisplayTimeText(selection.song_length)]<br><br>"
	var/datum/browser/popup = new(user, "vending", "Hispaniabox", 400, 350)
	popup.set_content(dat.Join())
	popup.open()


/obj/machinery/hispaniabox/Topic(href, href_list)
	if(..())
		return
	add_fingerprint(usr)
	switch(href_list["action"])
		if("toggle")
			if(QDELETED(src))
				return
			if(!active)
				if(stop > world.time)
					to_chat(usr, "<span class='warning'>Error: The device is still resetting from the last activation, it will be ready again in [DisplayTimeText(stop-world.time)].</span>")
					playsound(src, 'sound/misc/compiler-failure.ogg', 50, 1)
					return
				active = TRUE
				update_icon()
				dance_setup()
				START_PROCESSING(SSobj, src)

				updateUsrDialog()
			else if(active)
				stop = 0
				updateUsrDialog()
		if("select")
			if(active)
				to_chat(usr, "<span class='warning'>Error: You cannot change the song until the current one is over.</span>")
				return

			var/list/available = list()
			for(var/datum/track/S in songs)
				available[S.song_name] = S
			var/selected = input(usr, "Choose your song", "Track:") as null|anything in available
			if(QDELETED(src) || !selected || !istype(available[selected], /datum/track))
				return
			selection = available[selected]
			updateUsrDialog()


/obj/machinery/hispaniabox/proc/dance_setup()
	stop = world.time + selection.song_length


/obj/machinery/hispaniabox/proc/dance_over()
	QDEL_LIST(spotlights)
	QDEL_LIST(sparkles)
	for(var/mob/living/L in rangers)
		if(!L || !L.client)
			continue
		L.stop_sound_channel(CHANNEL_JUKEBOX)
	rangers = list()



/obj/machinery/hispaniabox/process()
	if(charge < 35)
		charge += 1
	if(world.time < stop && active)
		var/sound/song_played = sound(selection.song_path)

		for(var/mob/M in range(10,src))
			if(!(M in rangers))
				rangers[M] = TRUE
				M.playsound_local(get_turf(M), null, 100, channel = CHANNEL_JUKEBOX, S = song_played)
		for(var/mob/L in rangers)
			if(get_dist(src, L) > 10)
				rangers -= L
				if(!L || !L.client)
					continue
				L.stop_sound_channel(CHANNEL_JUKEBOX)
	else if(active)
		active = FALSE
		STOP_PROCESSING(SSobj, src)
		dance_over()
		playsound(src,'sound/machines/terminal_off.ogg',50,1)
		icon_state = "jukebox"
		stop = world.time + 100
