/obj/machinery/hispaniabox
	name = "Hispaniabox"
	desc = "Music for the bar."
	icon = 'icons/hispania/obj/hispaniabox.dmi'
	icon_state = "jukebox"
	anchored = FALSE
	atom_say_verb = "states"
	density = TRUE
	light_color = "#FFD100"
	max_integrity = 250
	interact_offline = 1
	integrity_failure = 80
	var/light_range_on = 3
	var/light_power_on = 1
	var/active = FALSE
	var/list/rangers = list()
	var/stop = 0
	var/list/spotlights = list()
	var/list/sparkles = list()
	var/static/list/songs = list(
		"Play/Pause", // POR NADA DEL MUNDO QUITAR A ESTE
		"Lo-Fi Chill || Fly me to the moon - Frank Sinatra"    = new /datum/track('sound/hispania/hispaniabox/Fly_Me_To_The_Moon.ogg',	1340,	5,	"moon", "Fly me to the moon - Frank Sinatra"),
		"Lo-Fi Chill • Interstellar Main Theme - Hans Zimmer"  = new /datum/track('sound/music/title11.ogg',		2540,	5,	"zimmer", "Interstellar Main Theme - Hans Zimmer"),
		"Jazz • Porco Rosso Main Theme"  					   = new /datum/track('sound/hispania/hispaniabox/PorcoRosso.ogg',		5000,	5,	"porco", "Porco Rosso Main Theme"),
		"Eurodance Trance • Better Off Alone - SALEM Remix"    = new /datum/track('sound/music/title12.ogg',					1750,	5,	"euro", "Better Off Alone - SALEM Remix"),
		"Cyberpunk • Dance With The Dead - Andromeda"  		   = new /datum/track('sound/music/title1.ogg',					3010,	5,	"withdead", "Dance With The Dead - Andromeda"),
		"Pop-Rock • Space Oddity - David Bowie"  			   = new /datum/track('sound/music/title4.ogg',					3300,	5,	"oddity", "Space Oddity - David Bowie"  ),
		"Pop • Space Jam"  									   = new /datum/track('sound/music/title3.ogg',					1930,	5,	"jam", "Space Jam"),
		"Pop • Europa VII - La Oreja de Van Gogh"  			   = new /datum/track('sound/music/title10.ogg',					2390,	5,	"europa", "Europa VII - La Oreja de Van Gogh"),
		"Pop • Los Marcianos Llegaron Ya - Tito Rodriguez"     = new /datum/track('sound/music/title5.ogg',					1740,	5,	"marcianos", "Los Marcianos Llegaron Ya - Tito Rodriguez"),
		"Pop • Never Gonna Give You Up - Rick Astley"		   = new /datum/track('sound/hispania/hispaniabox/Give_You_Up.ogg',		2120,	5,	"giveyouup", "Never Gonna Give You Up - Rick Astley"),
		"Pop • Cacho Castaña - Si te agarro con otro te mato"  = new /datum/track('sound/hispania/hispaniabox/cacho.ogg',		2000,	5,	"cacho", "Cacho Castaña - Si te agarro con otro te mato"),
		"Pop • Children Of The Sun - Billy Thorpe"			   = new /datum/track('sound/music/title8.ogg',		3470,	5,	"sun", "Children Of The Sun - Billy Thorpe"),
		"Pop • Star Wars Cantina - Meco"  					   = new /datum/track('sound/hispania/hispaniabox/star_wars_cantina.ogg',			2532,	5,	"cantina", "Star Wars Cantina - Meco"),
		"Electro • Spoiler - DJ Hyper"						   = new /datum/track('sound/music/title9.ogg',		3500,	5,	"hyper", "Spoiler - DJ Hyper"),
		"Electro • Cheeki Breeki - Anthem"					   = new /datum/track('sound/hispania/hispaniabox/russian.ogg',	1930,	5,	"cheeki", "Cheeki Breeki - Anthem"),
		"Electro • Daft Punk - Veridis Quo"			   		   = new /datum/track('sound/hispania/hispaniabox/daft.ogg',		5570,	5,	"daft", "Daft Punk - Veridis Quo"),
		"Electro • Paradise Theme - Nanostrasen"			   = new /datum/track('sound/music/title2.ogg',		2080,	5,	"paradise", "Paradise Theme - Nanostrasen"),
		"Ambiente • Thunderdome Song - Nanostrasen"			   = new /datum/track('sound/music/thunderdome.ogg',	2020,	5,	"thunderdome", "Thunderdome Song - Nanostrasen"),
		"Ambiente • Tension Music - Nanostrasen"			   = new /datum/track('sound/music/traitor.ogg',		3500,	5,	"tension", "Tension Music - Nanostrasen"),
		"Ambiente • Space Ambient Song - Nanostrasen" 		   = new /datum/track('sound/music/space.ogg',		2130,	5,	"space", "Space Ambient Song - Nanostrasen"),
		"Cumbia • La Vida Es Un Carnaval - Celia Cruz"		   = new /datum/track('sound/hispania/hispaniabox/cumbion.ogg',	2770,	5,	"carnaval", "La Vida Es Un Carnaval - Celia Cruz"),
		"Rock • Yes - Roundabout"							   = new /datum/track('sound/hispania/hispaniabox/yes.ogg',	2600,	5,	"roundabout", "Yes - Roundabout"),
		"Rock Latino • Noviembre Sin Ti - Reik"				   = new /datum/track('sound/hispania/hispaniabox/reik.ogg',	1990,	5,	"noviembre", "Noviembre Sin Ti - Reik"),
		"For Science • Still Alive - GLaDOS"				   = new /datum/track('sound/music/title7.ogg',		1840,	5,	"GLaDOS", "Still Alive - GLaDOS"),
		)
	var/datum/track/selection
	var/track = ""

/datum/track
	song_name = "???"
	song_path = null
	song_length = 0
	song_beat = 0
	var/song_icon
	GBP_required = 0

/datum/track/New(path, length, beat, icon, name)
	song_path = path
	song_length = length
	song_beat = beat
	song_icon = icon
	song_name = name

/obj/machinery/hispaniabox/power_change()
	..()
	light()

/obj/machinery/hispaniabox/emp_act()
	. = ..()
	dance_over()
	stop = 0
	active = FALSE
	selection = null
	STOP_PROCESSING(SSobj, src)
	playsound(src.loc, 'sound/effects/sparks4.ogg', 50, TRUE)
	do_sparks(3, 1, src)
	if(obj_integrity < 90)
		obj_integrity = 1
		do_sparks(3, 1, src)
		update_icon()
		return
	obj_integrity -= 90 // OUCH daño a la jukebox, 2 EMP TUMBAN LA JUKEBOX
	update_icon()

/obj/machinery/hispaniabox/Destroy()
	dance_over()
	selection = null
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/machinery/hispaniabox/obj_break(damage_flag)
	..()
	dance_over()
	selection = null
	STOP_PROCESSING(SSobj, src)
	update_icon()

/obj/machinery/hispaniabox/attackby(obj/item/O, mob/user, params)
	if(!active)
		if(iswrench(O))
			if(isinspace())
				to_chat(user,"<span class='notice'>You can't secure the [src] in the space...</span>")
				return
			if(!anchored)
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

/obj/machinery/hispaniabox/emag_act(mob/user)
	if(!emagged)
		emagged = TRUE
		if(user)
			user.visible_message("<span class='warning'>Sparks fly out of the [src]!</span>", "<span class='notice'>You emag the [src], new features unlocked.</span>")
		playsound(src.loc, 'sound/effects/sparks4.ogg', 50, TRUE)
		do_sparks(3, 1, src)
		songs["Final_Gear.EXECUTE"] = new /datum/track('sound/hispania/hispaniabox/emmaged/RapdelasOpciones.ogg',	1570,	5,	"gear", "CHOCUJUEGO • El rap de las opciones")
		songs["Last Order Of Pizza"] = new /datum/track('sound/hispania/hispaniabox/emmaged/pizza.ogg',	1270,	5,	"pizza", "Spider-Man 2 • The Game Pizza Theme")
		return

/obj/machinery/hispaniabox/examine(mob/living/M)
	. = ..()
	if (active && selection)
		var/image = image('icons/hispania/obj/hispaniabox.dmi', icon_state = selection.song_icon)
		. += "<span class='notice'>[bicon(src)] Estas escuchando \"[selection.song_name]\" [bicon(image)]</span>"

/obj/machinery/hispaniabox/proc/double_jukebox()
	for(var/obj/machinery/hispaniabox/B in range(20,src))
		if (B != src && B.active)
			return TRUE
	return FALSE

/obj/machinery/hispaniabox/attack_hand(mob/user)
	if(..())
		return

	if(stat & BROKEN)
		return

	if(!anchored)
		to_chat(user,"<span class='warning'>This device must be anchored by a wrench!</span>")
		return

	if(!Adjacent(user) && !isAI(user))
		return

	add_fingerprint(user)

	var/list/skins = list()
	for(var/I in songs)
		if (I == "Play/Pause")
			var/image/image = image('icons/hispania/obj/hispaniabox.dmi', icon_state = "Play/Pause")
			skins[I] = image
		else
			var/datum/track/S = songs[I] // Get the accociated list
			var/icon = S.song_icon
			var/image/image = image('icons/hispania/obj/hispaniabox.dmi', icon_state = icon)
			skins[I] = image

	var/choice = show_radial_menu(user, src, skins, null, 40, CALLBACK(src, .proc/radial_check, user), TRUE)
	if(!choice || !radial_check(user))
		return
	if (choice == "Play/Pause")
		if(double_jukebox())
			to_chat(user,"<span class='warning'>[bicon(src)] Can you have some manners? There's already music playing.</span>")
			return
		if(isnull(selection))
			return
		if(QDELETED(src))
			return
		if(!active)
			if(stop > world.time)
				to_chat(usr, "<span class='warning'>[bicon(src)] The device is still resetting from the last activation, it will be ready again in [DisplayTimeText(stop-world.time)].</span>")
				playsound(src, 'sound/misc/compiler-failure.ogg', 50, 1)
				return
			active = TRUE
			update_icon()
			dance_setup()
			playsound(src,'sound/hispania/machines/dvd_working.ogg',50,1)
			START_PROCESSING(SSobj, src)
			return
		else if(active)
			stop = 0
			return
		else
			to_chat(usr, "<span class='warning'>[bicon(src)] You cannot stop the song until the current one is over.</span>")
			return
	var/datum/track/S = songs[choice]
	if(!active)
		selection = S
		playsound(src,'sound/misc/ping.ogg',50,1)
	else
		to_chat(usr, "<span class='warning'>[bicon(src)] You cannot change the song until the current one is over.</span>")

/obj/machinery/hispaniabox/proc/radial_check(mob/living/carbon/human/H)
	if(!src || !Adjacent(H) || H.incapacitated())
		return FALSE
	return TRUE

/obj/machinery/hispaniabox/proc/light()
	if(!(stat & BROKEN))
		return set_light(light_range_on, light_power_on)
	else
		return set_light(0)

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

/obj/machinery/hispaniabox/update_icon()
	if(stat & BROKEN)
		icon_state = "jukebox-broken"
	else if (active)
		icon_state = "jukebox-running"
	else
		icon_state = "jukebox"
