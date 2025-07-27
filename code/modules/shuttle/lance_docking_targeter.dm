/obj/item/lance_docking_generator
	name = "lance docking beacon"
	desc = "A signaling device used to place a beacon, to allow the lance to precicely dock."
	icon = 'icons/obj/device.dmi'
	icon_state = "gangtool-red"
	var/gps

/obj/item/lance_docking_generator/Initialize(mapload)
	. = ..()
	gps = new /obj/item/gps/internal/lance_beacon(src)

/obj/item/lance_docking_generator/Destroy()
	qdel(gps)
	return ..()

/obj/item/lance_docking_generator/emag_act(mob/user)
	if(!emagged)
		emagged = TRUE
		to_chat(user, "<span class='notice'>You emag [src], removing its docking safeties.</span>")
		var/turf/T = get_turf(src)
		do_sparks(5, FALSE, T)
		playsound(T, "sparks", 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		return TRUE

/obj/item/lance_docking_generator/attack_self__legacy__attackchain(mob/living/user)
	if(!is_station_level(user.z))
		to_chat(user, "<span class='warning'>You'll want this to dock on the station.</span>")
		return
	var/list/dir_choices = list("North" = NORTH, "East" = EAST, "South" = SOUTH, "West" = WEST)
	var/dir_choice = tgui_input_list(user, "Which direction should the shuttle approach from?", "Dock Orientation", dir_choices)
	if(!dir_choice)
		return

	var/dest_dir = dir_choices[dir_choice]
	var/turf/destination = get_step(user.loc, dest_dir)
	var/obj/docking_port/stationary/lance/port = new(destination)
	port.dir = dest_dir

	var/min_x = -1
	var/min_y = -1
	var/max_x = -1
	var/max_y = -1

	var/list/ordered_turfs = port.return_ordered_turfs()
	for(var/turf/T in ordered_turfs)
		min_x = min_x < 0 ? T.x : min(min_x, T.x)
		min_y = min_y < 0 ? T.y : min(min_y, T.y)
		max_x = max_x < 0 ? T.x : max(max_x, T.x)
		max_y = max_y < 0 ? T.y : max(max_y, T.y)
		for(var/obj/O in T.contents)
			if((istype(O, /obj/machinery/atmospherics/supermatter_crystal) || istype(O, /obj/singularity)) && !emagged)
				to_chat(user, "<span class='warning'>Dangerous landing conditions, aborting!</span>")
				qdel(port, force = TRUE)
				return

	if(min_x <= TRANSITION_BORDER_WEST + 1 || max_x >= TRANSITION_BORDER_EAST - 1)
		to_chat(user, "<span class='warning'>Docking space area too close to edge of sector, aborting!</span>")
		qdel(port, force = TRUE)
		return
	if(min_y <= TRANSITION_BORDER_SOUTH + 1 || max_y >= TRANSITION_BORDER_NORTH - 1)
		to_chat(user, "<span class='warning'>Docking space area too close to edge of sector, aborting!</span>")
		qdel(port, force = TRUE)
		return
	var/list/L2 = list()
	switch(dest_dir)
		if(NORTH)
			L2 = block(port.x - 9, port.y + 36, port.z, port.x + 9, 255, port.z)
		if(SOUTH)
			L2 = block(port.x - 9, 1, port.z, port.x + 9, port.y - 36, port.z)
		if(EAST)
			L2 = block(port.x + 36, port.y - 9, port.z, 255, port.y + 9, port.z)
		if(WEST)
			L2 = block(1, port.y - 9, port.z, port.x - 36, port.y + 9, port.z)
	for(var/turf/BT in L2)
		for(var/obj/Ohno in BT.contents)
			if((istype(Ohno, /obj/machinery/atmospherics/supermatter_crystal) || istype(Ohno, /obj/singularity)) && !emagged)
				to_chat(user, "<span class='warning'>Dangerous landing conditions, aborting!</span>")
				qdel(port, force = TRUE)
				return
	port.register()

	log_admin("[key_name(user)] created the lance docking location at [COORD(port)].")
	to_chat(user, "<span class='notice'>Landing zone set. The signaller vanishes!</span>")
	new /obj/structure/lance_beacon(get_turf(src))
	qdel(src)

/obj/structure/lance_beacon
	name = "lance docking beacon"
	desc = "A beacon that allows the Lance to carefully slam into the station at plasteel destroying speeds."
	icon = 'icons/obj/singularity.dmi'
	icon_state = "beacon1"
	layer = MOB_LAYER - 0.2 //so people can't hide it and it's REALLY OBVIOUS
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE
	var/gps

/obj/structure/lance_beacon/Initialize(mapload)
	. = ..()
	gps = new /obj/item/gps/internal/lance_beacon(src)
	set_light(5, 3, COLOR_WARM_YELLOW)

/obj/structure/lance_beacon/Destroy()
	qdel(gps)
	return ..()

/obj/docking_port/stationary/lance
	name = "lance docking port"
	id = "emergency_home"
	height = 50
	width = 19
	dwidth = 9

/obj/item/gps/internal/lance_beacon
	icon_state = null
	gpstag = "Lance Docking Beacon"
	desc = "It is not reccomended to stand here."
