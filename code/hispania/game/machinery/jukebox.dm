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
		new /datum/track("Pop",		"Los Marcianos Llegaron Ya - Tito Rodriguez",	'sound/music/title5.ogg',					1740,	5),
		new /datum/track("Eurodance Trance",		"Better Off Alone - SALEM Remix",				'sound/music/title12.ogg',					1750,	5),
		new /datum/track("Cyberpunk",	"Dance With The Dead - Andromeda",				'sound/music/title1.ogg',					3010,	5),
		new /datum/track("Lo-Fi Chill",	"Fly me to the moon - Frank Sinatra",	        'sound/hispania/hispaniabox/Fly_Me_To_The_Moon.ogg',	1340,	5),
		new /datum/track("Pop",			"Space Jam",									'sound/music/title3.ogg',					1930,	5),
		new /datum/track("Pop",			"Europa VII - La Oreja de Van Gogh",			'sound/music/title10.ogg',					2390,	5),
		new /datum/track("Pop-Rock",	"Space Oddity - David Bowie",					'sound/music/title4.ogg',					3300,	5),
		new /datum/track("Pop",	    "Star Wars Cantina - Meco",				        'sound/hispania/hispaniabox/star_wars_cantina.ogg',		2532,	5),
		new /datum/track("Pop",	        "Never Gonna Give You Up - Rick Astley",	    'sound/hispania/hispaniabox/Give_You_Up.ogg',		2120,	5),
		new /datum/track("Pop",	    "Cacho Castaña - Si te agarro con otro te mato",	'sound/hispania/hispaniabox/cacho.ogg',		2000,	5),
		new /datum/track("Ambient",		"Space Ambient Song - Nanostrasen",			'sound/music/space.ogg',		2130,	5),
		new /datum/track("Lo-Fi Chill",	"Interstellar Main Theme - Hans Zimmer",		'sound/music/title11.ogg',		2540,	5),
		new /datum/track("Electro",		"Paradise Theme - Nanostrasen",        			'sound/music/title2.ogg',		2080,	5),
		new /datum/track("For Science",	"Still Alive - GLaDOS",        					'sound/music/title7.ogg',		1840,	5),
		new /datum/track("Pop",			"Children Of The Sun - Billy Thorpe",        	'sound/music/title8.ogg',		3470,	5),
		new /datum/track("Electro",		"Spoiler - DJ Hyper",        					'sound/music/title9.ogg',		3500,	5),
		new /datum/track("Ambient",		"Tension Music - Nanostrasen",        			'sound/music/traitor.ogg',		3500,	5),
		new /datum/track("Ambient",		"Thunderdome Song - Nanostrasen",        		'sound/music/thunderdome.ogg',	2020,	5),
		new /datum/track("Electro",		"Cheeki Breeki - Anthem",        		'sound/hispania/hispaniabox/russian.ogg',	1930,	5),
		new /datum/track("Rock Latino",		"Noviembre Sin Ti - Reik",        		'sound/hispania/hispaniabox/reik.ogg',	1990,	5),
		new /datum/track("Cumbia",		"La Vida Es Un Carnaval - Celia Cruz",        		'sound/hispania/hispaniabox/cumbion.ogg',	2770,	5),
		new /datum/track("Rock",		"Yes - Roundabout",        		'sound/hispania/hispaniabox/yes.ogg',	2600,	5),
		)
	var/datum/track/selection
	var/track = ""

/datum/track
	var/song_genre = "Generic"
	song_name = "Undefined"
	song_path = null
	song_length = 0
	song_beat = 0
	GBP_required = 0

/datum/track/New(genre, name, path, length, beat)
	song_genre = genre
	song_name = name
	song_path = path
	song_length = length
	song_beat = beat


/obj/machinery/hispaniabox/power_change()
	..()
	light()

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
				light()
			else if(anchored)
				to_chat(user,"<span class='notice'>You unsecure and disconnect [src].</span>")
				anchored = FALSE
				set_light(0)
			playsound(src, O.usesound, 50, 1)
			return
	return ..()

/obj/machinery/hispaniabox/update_icon()
	icon_state = (active ? "jukebox-running" : "jukebox")
	..()

/obj/machinery/hispaniabox/attack_hand(mob/user)
	if(..())
		return

	if(!anchored)
		to_chat(user,"<span class='warning'>This device must be anchored by a wrench!</span>")
		return

	if(!Adjacent(user) && !isAI(user))
		return

	add_fingerprint(user)
	ui_interact(user)

/obj/machinery/hispaniabox/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "hispaniabox.tmpl", name,  640, 350)
		ui.open()

/obj/machinery/hispaniabox/ui_data(mob/user, ui_key = "main",  datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	var/data[0]
	var/index = 0
	data["song_name"] = ((track == "") ? "" : songs[track]["song_name"])
	data["active"] = active

	for(var/datum/track/S in songs)
		index++
		data["songs"] += list(list("ref" = "\ref[S]", "id" = index, "genre" = S.song_genre, "name" = S.song_name, "length" = length2time(S.song_length)))

	return data

/obj/machinery/hispaniabox/Topic(href, href_list)
	if(..())
		return TRUE

	switch(href_list["action"])
		if("on_click")
			if(isnull(selection))
				return TRUE
			if(QDELETED(src))
				return TRUE
			if(!active)
				if(stop > world.time)
					to_chat(usr, "<span class='warning'>[bicon(src)] The device is still resetting from the last activation, it will be ready again in [DisplayTimeText(stop-world.time)].</span>")
					playsound(src, 'sound/misc/compiler-failure.ogg', 50, 1)
					return TRUE
				active = TRUE
				update_icon()
				dance_setup()
				playsound(src,'sound/hispania/machines/dvd_working.ogg',50,1)
				START_PROCESSING(SSobj, src)
				updateUsrDialog()
			else if(active)
				stop = 0
				return TRUE
			else
				to_chat(usr, "<span class='warning'>[bicon(src)] You cannot stop the song until the current one is over.</span>")
				return TRUE

			updateUsrDialog()

	if(href_list["a_sound"])
		//var/datum/track/S = locate(href_list["a_sound"])
		if(!active)
			track = text2num(href_list["a_id"])
			selection = songs[track]
		else
			to_chat(usr, "<span class='warning'>[bicon(src)] You cannot change the song until the current one is over.</span>")

	return TRUE

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

/obj/machinery/hispaniabox/proc/light()
	if(!(stat & (BROKEN|NOPOWER)))
		return set_light(light_range_on, light_power_on)
	else
		return set_light(0)

/obj/machinery/hispaniabox/proc/length2time(var/length)
	var/time = length * 0.1
	var/h = round(time / 3600)
	var/m = round(time % 3600 / 60)
	var/s = round(time % 3600 % 60)

	var/hDisplay = (h > 0) ? "[h]:" : ""
	var/mDisplay = (m > 0) ? "[m]:" : ""
	var/sDisplay = (s > 0) ? (s >= 10 ? "[s]s" : "0[s]s") : ""

	return hDisplay + mDisplay + sDisplay

/obj/machinery/hispaniabox/proc/dance_setup()
	stop = world.time + selection["song_length"]

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
		var/sound/song_played = sound(selection["song_path"])

		for(var/mob/M in range(10,src))
			if(!(M in rangers))
				rangers[M] = TRUE

				if(!M.client || !(M.client.prefs.sound & SOUND_INSTRUMENTS))
					continue
				M.playsound_local(src, null, 100, channel = CHANNEL_JUKEBOX, S = song_played)
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
