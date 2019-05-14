/obj/machinery/disco
	name = "radiant dance machine mark IV"
	desc = "The first three prototypes were discontinued after mass casualty incidents."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "disco0"
	anchored = FALSE
	atom_say_verb = "states"
	density = TRUE
	var/active = FALSE
	var/list/rangers = list()
	var/charge = 35
	var/stop = 0
	var/list/spotlights = list()
	var/list/sparkles = list()
	var/static/list/songs = list(
		new /datum/track("Engineering's Basic Beat", 					'sound/misc/disco.ogg', 	600, 	5),
		new /datum/track("Engineering's Domination Dance", 				'sound/misc/e1m1.ogg', 		950, 	6),
		new /datum/track("Engineering's Superiority Shimmy", 			'sound/misc/paradox.ogg', 	2400, 	4),
		new /datum/track("Engineering's Ultimate High-Energy Hustle",	'sound/misc/boogie2.ogg',	1770, 	5),
		)
	var/datum/track/selection = null

/datum/track
	var/song_name = "generic"
	var/song_path = null
	var/song_length = 0
	var/song_beat = 0
	var/GBP_required = 0

/datum/track/New(name, path, length, beat)
	song_name = name
	song_path = path
	song_length = length
	song_beat = beat

/obj/machinery/disco/proc/add_track(file, name, length, beat)
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

/obj/machinery/disco/New()
	. = ..()
	selection = songs[1]


/obj/machinery/disco/Destroy()
	dance_over()
	selection = null
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/machinery/disco/attackby(obj/item/O, mob/user, params)
	if(!active)
		if(iswrench(O))
			if(!anchored && !isinspace())
				to_chat(user,"<span class='notice'>You secure [src] to the floor.</span>")
				anchored = TRUE
			else if(anchored)
				to_chat(user,"<span class='notice'>You unsecure and disconnect [src].</span>")
				anchored = FALSE
			playsound(src, 'sound/items/deconstruct.ogg', 50, 1)
			return
	return ..()

/obj/machinery/disco/update_icon()
	if(active)
		icon_state = "disco1"
	else
		icon_state = "disco0"
	..()


/obj/machinery/disco/attack_hand(mob/user)
	if(..())
		return

	interact(user)

/obj/machinery/disco/interact(mob/user)
	if(!anchored)
		to_chat(user,"<span class='warning'>This device must be anchored by a wrench!</span>")
		return
	if(!Adjacent(user) && !isAI(user))
		return
	user.set_machine(src)
	var/list/dat = list()
	dat +="<div class='statusDisplay' style='text-align:center'>"
	dat += "<b><A href='?src=[UID()];action=toggle'>[!active ? "BREAK IT DOWN" : "SHUT IT DOWN"]<b></A><br>"
	dat += "</div><br>"
	dat += "<A href='?src=[UID()];action=select'> Select Track</A><br>"
	dat += "Track Selected: [selection.song_name]<br>"
	dat += "Track Length: [DisplayTimeText(selection.song_length)]<br><br>"
	dat += "<br>DJ's Soundboard:<b><br>"
	dat +="<div class='statusDisplay'><div style='text-align:center'>"
	dat += "<A href='?src=[UID()];action=horn'>Air Horn</A>  "
	dat += "<A href='?src=[UID()];action=alert'>Station Alert</A>  "
	dat += "<A href='?src=[UID()];action=siren'>Warning Siren</A>  "
	dat += "<A href='?src=[UID()];action=honk'>Honk</A><br>"
	dat += "<A href='?src=[UID()];action=pump'>Shotgun Pump</A>"
	dat += "<A href='?src=[UID()];action=pop'>Gunshot</A>"
	dat += "<A href='?src=[UID()];action=saber'>Esword</A>"
	dat += "<A href='?src=[UID()];action=harm'>Harm Alarm</A>"
	var/datum/browser/popup = new(user, "vending", "Radiance Dance Machine - Mark IV", 400, 350)
	popup.set_content(dat.Join())
	popup.open()


/obj/machinery/disco/Topic(href, href_list)
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
				lights_spin()
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
		if("horn")
			deejay('sound/items/airhorn2.ogg')
		if("alert")
			deejay('sound/misc/notice1.ogg')
		if("siren")
			deejay('sound/machines/engine_alert1.ogg')
		if("honk")
			deejay('sound/items/bikehorn.ogg')
		if("pump")
			deejay('sound/weapons/gun_interactions/shotgunpump.ogg')
		if("pop")
			deejay('sound/weapons/gunshots/gunshot3.ogg')
		if("saber")
			deejay('sound/weapons/saberon.ogg')
		if("harm")
			deejay('sound/AI/harmalarm.ogg')

/obj/machinery/disco/proc/deejay(S)
	if(QDELETED(src) || !active || charge < 5)
		to_chat(usr, "<span class='warning'>The device is not able to play more DJ sounds at this time.</span>")
		return
	charge -= 5
	playsound(src, S, 300, 1)

/obj/machinery/disco/proc/dance_setup()
	stop = world.time + selection.song_length
	var/turf/cen = get_turf(src)
	FOR_DVIEW(var/turf/t, 3, get_turf(src),INVISIBILITY_LIGHTING)
		if(t.x == cen.x && t.y > cen.y)
			var/obj/item/flashlight/spotlight/L = new /obj/item/flashlight/spotlight(t)
			L.light_color = "red"
			L.light_power = 30 - (get_dist(src, L) * 8)
			L.range = 1+get_dist(src, L)
			spotlights+=L
			continue
		if(t.x == cen.x && t.y < cen.y)
			var/obj/item/flashlight/spotlight/L = new /obj/item/flashlight/spotlight(t)
			L.light_color = "purple"
			L.light_power = 30 - (get_dist(src, L) * 8)
			L.range = 1+get_dist(src, L)
			spotlights+=L
			continue
		if(t.x > cen.x && t.y == cen.y)
			var/obj/item/flashlight/spotlight/L = new /obj/item/flashlight/spotlight(t)
			L.light_color = "#ffff00"
			L.light_power = 30 - (get_dist(src, L) * 8)
			L.range = 1+get_dist(src, L)
			spotlights+=L
			continue
		if(t.x < cen.x && t.y == cen.y)
			var/obj/item/flashlight/spotlight/L = new /obj/item/flashlight/spotlight(t)
			L.light_color = "green"
			L.light_power = 30 - (get_dist(src, L) * 8)
			L.range = 1+get_dist(src, L)
			spotlights+=L
			continue
		if((t.x+1 == cen.x && t.y+1 == cen.y) || (t.x+2==cen.x && t.y+2 == cen.y))
			var/obj/item/flashlight/spotlight/L = new /obj/item/flashlight/spotlight(t)
			L.light_color = "sw"
			L.light_power = 30 - (get_dist(src, L) * 8)
			L.range = 1.4+get_dist(src, L)
			spotlights+=L
			continue
		if((t.x-1 == cen.x && t.y-1 == cen.y) || (t.x-2==cen.x && t.y-2 == cen.y))
			var/obj/item/flashlight/spotlight/L = new /obj/item/flashlight/spotlight(t)
			L.light_color = "ne"
			L.light_power = 30 - (get_dist(src, L) * 8)
			L.range = 1.4+get_dist(src, L)
			spotlights+=L
			continue
		if((t.x-1 == cen.x && t.y+1 == cen.y) || (t.x-2==cen.x && t.y+2 == cen.y))
			var/obj/item/flashlight/spotlight/L = new /obj/item/flashlight/spotlight(t)
			L.light_color = "se"
			L.light_power = 30 - (get_dist(src, L) * 8)
			L.range = 1.4+get_dist(src, L)
			spotlights+=L
			continue
		if((t.x+1 == cen.x && t.y-1 == cen.y) || (t.x+2==cen.x && t.y-2 == cen.y))
			var/obj/item/flashlight/spotlight/L = new /obj/item/flashlight/spotlight(t)
			L.light_color = "nw"
			L.light_power = 30 - (get_dist(src, L) * 8)
			L.range = 1.4+get_dist(src, L)
			spotlights+=L
			continue
		continue
	END_FOR_DVIEW

/obj/machinery/disco/proc/hierofunk()
	for(var/i in 1 to 10)
		new /obj/effect/temp_visual/hierophant/telegraph/edge(get_turf(src))
		sleep(5)

/obj/machinery/disco/proc/lights_spin()
	for(var/i in 1 to 25)
		if(QDELETED(src) || !active)
			return
		var/obj/effect/overlay/sparkles/S = new /obj/effect/overlay/sparkles(src)
		S.alpha = 0
		sparkles += S
		switch(i)
			if(1 to 8)
				spawn(0)
					S.orbit(src, 30, TRUE, 60, 36, TRUE, FALSE)
			if(9 to 16)
				spawn(0)
					S.orbit(src, 62, TRUE, 60, 36, TRUE, FALSE)
			if(17 to 24)
				spawn(0)
					S.orbit(src, 95, TRUE, 60, 36, TRUE, FALSE)
			if(25)
				S.pixel_y = 7
				S.forceMove(get_turf(src))
		sleep(7)
	if(selection.song_name == "Engineering's Ultimate High-Energy Hustle")
		sleep(280)
	for(var/obj/reveal in sparkles)
		reveal.alpha = 255
	while(active)
		for(var/obj/item/flashlight/spotlight/glow in spotlights) // The multiples reflects custom adjustments to each colors after dozens of tests
			if(QDELETED(src) || !active || QDELETED(glow))
				return
			if(glow.light_color == "red")
				glow.light_color = "nw"
				glow.light_power = glow.light_power * 1.48
				glow.light_range = 0
				glow.update_light()
				continue
			if(glow.light_color == "nw")
				glow.light_color = "green"
				glow.light_range = glow.range * 1.1
				glow.light_power = glow.light_power * 2 // Any changes to power must come in pairs to neutralize it for other colors
				glow.update_light()
				continue
			if(glow.light_color == "green")
				glow.light_color = "sw"
				glow.light_power = glow.light_power * 0.5
				glow.light_range = 0
				glow.update_light()
				continue
			if(glow.light_color == "sw")
				glow.light_color = "purple"
				glow.light_power = glow.light_power * 2.27
				glow.light_range = glow.range * 1.15
				glow.update_light()
				continue
			if(glow.light_color == "purple")
				glow.light_color = "se"
				glow.light_power = glow.light_power * 0.44
				glow.light_range = 0
				glow.update_light()
				continue
			if(glow.light_color == "se")
				glow.light_color = "#ffff00"
				glow.light_range = glow.range * 0.9
				glow.update_light()
				continue
			if(glow.light_color == "#ffff00")
				glow.light_color = "ne"
				glow.light_range = 0
				glow.update_light()
				continue
			if(glow.light_color == "ne")
				glow.light_color = "red"
				glow.light_power = glow.light_power * 0.68
				glow.light_range = glow.range * 0.85
				glow.update_light()
				continue
		if(prob(2))  // Unique effects for the dance floor that show up randomly to mix things up
			INVOKE_ASYNC(src, .proc/hierofunk)
		sleep(selection.song_beat)


/obj/machinery/disco/proc/dance(mob/living/M) //Show your moves
	set waitfor = FALSE
	switch(rand(0,9))
		if(0 to 1)
			dance2(M)
		if(2 to 3)
			dance3(M)
		if(4 to 6)
			dance4(M)
		if(7 to 9)
			dance5(M)

/obj/machinery/disco/proc/dance2(mob/living/M)
	for(var/i = 1, i < 10, i++)
		for(var/d in list(NORTH, SOUTH, EAST, WEST, EAST, SOUTH, NORTH, SOUTH, EAST, WEST, EAST, SOUTH))
			M.setDir(d)
			if(i == WEST && !M.incapacitated())
				M.SpinAnimation(7, 1)
			sleep(1)
		sleep(20)

/obj/machinery/disco/proc/dance3(mob/living/M)
	var/matrix/initial_matrix = matrix(M.transform)
	for(var/i in 1 to 75)
		if(!M)
			return
		switch(i)
			if(1 to 15)
				initial_matrix = matrix(M.transform)
				initial_matrix.Translate(0, 1)
				animate(M, transform = initial_matrix, time = 1, loop = 0)
			if(16 to 30)
				initial_matrix = matrix(M.transform)
				initial_matrix.Translate(1, -1)
				animate(M, transform = initial_matrix, time = 1, loop = 0)
			if(31 to 45)
				initial_matrix = matrix(M.transform)
				initial_matrix.Translate(-1, -1)
				animate(M, transform = initial_matrix, time = 1, loop = 0)
			if(46 to 60)
				initial_matrix = matrix(M.transform)
				initial_matrix.Translate(-1, 1)
				animate(M, transform = initial_matrix, time = 1, loop = 0)
			if(61 to 75)
				initial_matrix = matrix(M.transform)
				initial_matrix.Translate(1, 0)
				animate(M, transform = initial_matrix, time = 1, loop = 0)
		M.setDir(turn(M.dir, 90))
		switch(M.dir)
			if(NORTH)
				initial_matrix = matrix(M.transform)
				initial_matrix.Translate(0,3)
				animate(M, transform = initial_matrix, time = 1, loop = 0)
			if(SOUTH)
				initial_matrix = matrix(M.transform)
				initial_matrix.Translate(0,-3)
				animate(M, transform = initial_matrix, time = 1, loop = 0)
			if(EAST)
				initial_matrix = matrix(M.transform)
				initial_matrix.Translate(3,0)
				animate(M, transform = initial_matrix, time = 1, loop = 0)
			if(WEST)
				initial_matrix = matrix(M.transform)
				initial_matrix.Translate(-3,0)
				animate(M, transform = initial_matrix, time = 1, loop = 0)
		sleep(1)
	M.lying_fix()


/obj/machinery/disco/proc/dance4(mob/living/M)
	var/speed = rand(1, 3)
	set waitfor = 0
	var/time = 30
	while(time)
		sleep(speed)
		for(var/i in 1 to speed)
			M.setDir(pick(cardinal))
			M.resting = !M.resting
			M.update_canmove()
		 time--

/obj/machinery/disco/proc/dance5(mob/living/M)
	animate(M, transform = matrix(180, MATRIX_ROTATE), time = 1, loop = 0)
	var/matrix/initial_matrix = matrix(M.transform)
	for(var/i in 1 to 60)
		if(!M)
			return
		if(i<31)
			initial_matrix = matrix(M.transform)
			initial_matrix.Translate(0,1)
			animate(M, transform = initial_matrix, time = 1, loop = 0)
		if(i>30)
			initial_matrix = matrix(M.transform)
			initial_matrix.Translate(0,-1)
			animate(M, transform = initial_matrix, time = 1, loop = 0)
		M.setDir(turn(M.dir, 90))
		switch(M.dir)
			if(NORTH)
				initial_matrix = matrix(M.transform)
				initial_matrix.Translate(0,3)
				animate(M, transform = initial_matrix, time = 1, loop = 0)
			if(SOUTH)
				initial_matrix = matrix(M.transform)
				initial_matrix.Translate(0,-3)
				animate(M, transform = initial_matrix, time = 1, loop = 0)
			if(EAST)
				initial_matrix = matrix(M.transform)
				initial_matrix.Translate(3,0)
				animate(M, transform = initial_matrix, time = 1, loop = 0)
			if(WEST)
				initial_matrix = matrix(M.transform)
				initial_matrix.Translate(-3,0)
				animate(M, transform = initial_matrix, time = 1, loop = 0)
		sleep(1)
	M.lying_fix()



/mob/living/proc/lying_fix()
	animate(src, transform = null, time = 1, loop = 0)
	lying_prev = 0

/obj/machinery/disco/proc/dance_over()
	QDEL_LIST(spotlights)
	QDEL_LIST(sparkles)
	for(var/mob/living/L in rangers)
		if(!L || !L.client)
			continue
		L.stop_sound_channel(CHANNEL_JUKEBOX)
	rangers = list()



/obj/machinery/disco/process()
	if(charge < 35)
		charge += 1
	if(world.time < stop && active)
		var/sound/song_played = sound(selection.song_path)

		for(var/mob/M in range(10,src))
			if(!(M in rangers))
				rangers[M] = TRUE
				M.playsound_local(get_turf(M), null, 100, channel = CHANNEL_JUKEBOX, S = song_played)
			if(prob(5+(allowed(M) * 4)) && M.canmove && isliving(M))
				dance(M)
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
		icon_state = "disco0"
		stop = world.time + 100
