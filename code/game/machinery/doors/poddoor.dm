/obj/machinery/door/poddoor
	name = "blast door"
	desc = "That looks like it doesn't open easily."
	icon = 'icons/obj/doors/rapid_pdoor.dmi'
	icon_state = "pdoor1"
	explosion_block = 3
	heat_proof = 1
	var/id_tag = 1.0
	var/protected = 1

/obj/machinery/door/poddoor/preopen
	icon_state = "pdoor0"
	density = 0
	opacity = 0

/obj/machinery/door/poddoor/Bumped(atom/AM)
	if(!density)
		return ..()
	else
		return 0

//"BLAST" doors are obviously stronger than regular doors when it comes to BLASTS.
/obj/machinery/door/poddoor/ex_act(severity, target)
	switch(severity)
		if(1)
			if(prob(80))
				qdel(src)
			else
				var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
				s.set_up(2, 1, src)
				s.start()
		if(2)
			if(prob(20))
				qdel(src)
			else
				var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
				s.set_up(2, 1, src)
				s.start()

		if(3)
			if(prob(80))
				var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
				s.set_up(2, 1, src)
				s.start()

/obj/machinery/door/poddoor/attackby(obj/item/weapon/C, mob/user, params)
	add_fingerprint(user)
	if(!(iscrowbar(C) || (istype(C, /obj/item/weapon/twohanded/fireaxe) && C:wielded == 1)))
		return
	if((density && (stat & NOPOWER) && !operating))
		spawn(0)
			operating = 1
			flick("pdoorc0", src)
			icon_state = "pdoor0"
			set_opacity(0)
			sleep(15)
			density = 0
			operating = 0
			return
	return

/obj/machinery/door/poddoor/open()
	if(operating || emagged) //doors can still open when emag-disabled
		return
	if(!ticker)
		return 0
	if(!operating) //in case of emag
		operating = 1
	flick("pdoorc0", src)
	icon_state = "pdoor0"
	set_opacity(0)
	sleep(5)
	density = 0
	sleep(5)
	air_update_turf(1)
	update_freelook_sight()

	if(operating) //emag again
		operating = 0
	if(autoclose)
		spawn(150)
			autoclose()
	return 1

/obj/machinery/door/poddoor/close()
	if(operating)
		return
	operating = 1
	flick("pdoorc1", src)
	icon_state = "pdoor1"
	set_opacity(initial(opacity))
	air_update_turf(1)
	update_freelook_sight()
	sleep(5)
	crush()
	density = 1
	sleep(5)

	operating = 0
	return

/obj/machinery/door/poddoor/multi_tile // Whoever wrote the old code for multi-tile spesspod doors needs to burn in hell.
	name = "large pod door"
	layer = CLOSED_DOOR_LAYER

/obj/machinery/door/poddoor/multi_tile/four_tile_ver/
	icon = 'icons/obj/doors/1x4blast_vert.dmi'
	width = 4
	dir = NORTH

/obj/machinery/door/poddoor/multi_tile/three_tile_ver/
	icon = 'icons/obj/doors/1x3blast_vert.dmi'
	width = 3
	dir = NORTH

/obj/machinery/door/poddoor/multi_tile/two_tile_ver/
	icon = 'icons/obj/doors/1x2blast_vert.dmi'
	width = 2
	dir = NORTH

/obj/machinery/door/poddoor/multi_tile/four_tile_hor/
	icon = 'icons/obj/doors/1x4blast_hor.dmi'
	width = 4
	dir = EAST

/obj/machinery/door/poddoor/multi_tile/three_tile_hor/
	icon = 'icons/obj/doors/1x3blast_hor.dmi'
	width = 3
	dir = EAST

/obj/machinery/door/poddoor/multi_tile/two_tile_hor/
	icon = 'icons/obj/doors/1x2blast_hor.dmi'
	width = 2
	dir = EAST
