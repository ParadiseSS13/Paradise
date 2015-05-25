/obj/machinery/door/poddoor
	name = "Podlock"
	desc = "That looks like it doesn't open easily."
	icon = 'icons/obj/doors/rapid_pdoor.dmi'
	icon_state = "pdoor1"
	var/id_tag = 1.0
	explosion_block = 3
	var/protected = 1

/obj/machinery/door/poddoor/preopen
	icon_state = "pdoor0"
	density = 0
	opacity = 0

/obj/machinery/door/poddoor/four_tile_ver/
	name = "Large Pod Door"
	icon = 'icons/obj/doors/1x4blast_vert.dmi'

/obj/machinery/door/poddoor/three_tile_ver/
	name = "Large Pod Door"
	icon = 'icons/obj/doors/1x3blast_vert.dmi'

/obj/machinery/door/poddoor/two_tile_ver/
	name = "Large Pod Door"
	icon = 'icons/obj/doors/1x2blast_vert.dmi'

/obj/machinery/door/poddoor/Bumped(atom/AM)
	if(!density)
		return ..()
	else
		return 0

//"BLAST" doors are obviously stronger than regular doors when it comes to BLASTS.
/obj/machinery/door/poddoor/ex_act(severity, target)
	switch(severity)
		if(1.0)
			if(prob(80))
				qdel(src)
			else
				var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
				s.set_up(2, 1, src)
				s.start()
		if(2.0)
			if(prob(20))
				qdel(src)
			else
				var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
				s.set_up(2, 1, src)
				s.start()

		if(3.0)
			if(prob(80))
				var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
				s.set_up(2, 1, src)
				s.start()

/obj/machinery/door/poddoor/attackby(obj/item/weapon/C as obj, mob/user as mob, params)
	src.add_fingerprint(user)
	if (!( istype(C, /obj/item/weapon/crowbar) || (istype(C, /obj/item/weapon/twohanded/fireaxe) && C:wielded == 1) ))
		return
	if ((src.density && (stat & NOPOWER) && !( src.operating )))
		spawn( 0 )
			src.operating = 1
			flick("pdoorc0", src)
			src.icon_state = "pdoor0"
			src.set_opacity(0)
			sleep(15)
			src.density = 0
			src.operating = 0
			return
	return

/obj/machinery/door/poddoor/open()
	if (src.operating == 1) //doors can still open when emag-disabled
		return
	if (!ticker)
		return 0
	if(!src.operating) //in case of emag
		src.operating = 1
	flick("pdoorc0", src)
	src.icon_state = "pdoor0"
	src.set_opacity(0)
	sleep(5)
	src.density = 0
	sleep(5)
	air_update_turf(1)
	update_freelok_sight()

	if(operating == 1) //emag again
		src.operating = 0
	if(autoclose)
		spawn(150)
			autoclose()
	return 1

/obj/machinery/door/poddoor/close()
	if (src.operating)
		return
	src.operating = 1
	flick("pdoorc1", src)
	src.icon_state = "pdoor1"
	src.set_opacity(initial(opacity))
	air_update_turf(1)
	update_freelok_sight()
	sleep(5)
	crush()
	src.density = 1
	sleep(5)

	src.operating = 0
	return

/
/obj/machinery/door/poddoor/two_tile_hor/open()
	if (src.operating == 1) //doors can still open when emag-disabled
		return
	if (!ticker)
		return 0
	if(!src.operating) //in case of emag
		src.operating = 1
	flick("pdoorc0", src)
	src.icon_state = "pdoor0"
	sleep(10)
	src.density = 0
	src.set_opacity(0)

	f1.density = 0
	f1.set_opacity(0)
	f2.density = 0
	f2.set_opacity(0)

	air_update_turf(1)
	update_freelok_sight()

	if(operating == 1) //emag again
		src.operating = 0
	if(autoclose)
		spawn(150)
			autoclose()
	return 1

/obj/machinery/door/poddoor/two_tile_hor/close()
	if (src.operating)
		return
	src.operating = 1
	flick("pdoorc1", src)
	src.icon_state = "pdoor1"
	src.density = 1

	f1.density = 1
	f1.set_opacity(1)
	f2.density = 1
	f2.set_opacity(1)

	if (src.visible)
		src.set_opacity(1)
	air_update_turf(1)
	update_freelok_sight()

	sleep(10)
	src.operating = 0
	return

/obj/machinery/door/poddoor/three_tile_hor/open()
	if (src.operating == 1) //doors can still open when emag-disabled
		return
	if (!ticker)
		return 0
	if(!src.operating) //in case of emag
		src.operating = 1
	flick("pdoorc0", src)
	src.icon_state = "pdoor0"
	sleep(10)
	src.density = 0
	src.set_opacity(0)

	f1.density = 0
	f1.set_opacity(0)
	f2.density = 0
	f2.set_opacity(0)
	f3.density = 0
	f3.set_opacity(0)

	air_update_turf(1)
	update_freelok_sight()

	if(operating == 1) //emag again
		src.operating = 0
	if(autoclose)
		spawn(150)
			autoclose()
	return 1

/obj/machinery/door/poddoor/three_tile_hor/close()
	if (src.operating)
		return
	src.operating = 1
	flick("pdoorc1", src)
	src.icon_state = "pdoor1"
	src.density = 1

	f1.density = 1
	f1.set_opacity(1)
	f2.density = 1
	f2.set_opacity(1)
	f3.density = 1
	f3.set_opacity(1)

	if (src.visible)
		src.set_opacity(1)
	air_update_turf(1)
	update_freelok_sight()

	sleep(10)
	src.operating = 0
	return

/obj/machinery/door/poddoor/four_tile_hor/open()
	if (src.operating == 1) //doors can still open when emag-disabled
		return
	if (!ticker)
		return 0
	if(!src.operating) //in case of emag
		src.operating = 1
	flick("pdoorc0", src)
	src.icon_state = "pdoor0"
	sleep(10)
	src.density = 0
	src.set_opacity(0)

	f1.density = 0
	f1.set_opacity(0)
	f2.density = 0
	f2.set_opacity(0)
	f3.density = 0
	f3.set_opacity(0)
	f4.density = 0
	f4.set_opacity(0)

	air_update_turf(1)
	update_freelok_sight()

	if(operating == 1) //emag again
		src.operating = 0
	if(autoclose)
		spawn(150)
			autoclose()
	return 1

/obj/machinery/door/poddoor/four_tile_hor/close()
	if (src.operating)
		return
	src.operating = 1
	flick("pdoorc1", src)
	src.icon_state = "pdoor1"
	src.density = 1

	f1.density = 1
	f1.set_opacity(1)
	f2.density = 1
	f2.set_opacity(1)
	f3.density = 1
	f3.set_opacity(1)
	f4.density = 1
	f4.set_opacity(1)

	if (src.visible)
		src.set_opacity(1)
	air_update_turf(1)
	update_freelok_sight()

	sleep(10)
	src.operating = 0
	return



/obj/machinery/door/poddoor/two_tile_ver/open()
	if (src.operating == 1) //doors can still open when emag-disabled
		return
	if (!ticker)
		return 0
	if(!src.operating) //in case of emag
		src.operating = 1
	flick("pdoorc0", src)
	src.icon_state = "pdoor0"
	sleep(10)
	src.density = 0
	src.set_opacity(0)

	f1.density = 0
	f1.set_opacity(0)
	f2.density = 0
	f2.set_opacity(0)

	air_update_turf(1)
	update_freelok_sight()

	if(operating == 1) //emag again
		src.operating = 0
	if(autoclose)
		spawn(150)
			autoclose()
	return 1

/obj/machinery/door/poddoor/two_tile_ver/close()
	if (src.operating)
		return
	src.operating = 1
	flick("pdoorc1", src)
	src.icon_state = "pdoor1"
	src.density = 1

	f1.density = 1
	f1.set_opacity(1)
	f2.density = 1
	f2.set_opacity(1)

	if (src.visible)
		src.set_opacity(1)
	air_update_turf(1)
	update_freelok_sight()

	sleep(10)
	src.operating = 0
	return

/obj/machinery/door/poddoor/three_tile_ver/open()
	if (src.operating == 1) //doors can still open when emag-disabled
		return
	if (!ticker)
		return 0
	if(!src.operating) //in case of emag
		src.operating = 1
	flick("pdoorc0", src)
	src.icon_state = "pdoor0"
	sleep(10)
	src.density = 0
	src.set_opacity(0)

	f1.density = 0
	f1.set_opacity(0)
	f2.density = 0
	f2.set_opacity(0)
	f3.density = 0
	f3.set_opacity(0)

	air_update_turf(1)
	update_freelok_sight()

	if(operating == 1) //emag again
		src.operating = 0
	if(autoclose)
		spawn(150)
			autoclose()
	return 1

/obj/machinery/door/poddoor/three_tile_ver/close()
	if (src.operating)
		return
	src.operating = 1
	flick("pdoorc1", src)
	src.icon_state = "pdoor1"
	src.density = 1

	f1.density = 1
	f1.set_opacity(1)
	f2.density = 1
	f2.set_opacity(1)
	f3.density = 1
	f3.set_opacity(1)

	if (src.visible)
		src.set_opacity(1)
	air_update_turf(1)
	update_freelok_sight()

	sleep(10)
	src.operating = 0
	return

/obj/machinery/door/poddoor/four_tile_ver/open()
	if (src.operating == 1) //doors can still open when emag-disabled
		return
	if (!ticker)
		return 0
	if(!src.operating) //in case of emag
		src.operating = 1
	flick("pdoorc0", src)
	src.icon_state = "pdoor0"
	sleep(10)
	src.density = 0
	src.set_opacity(0)

	f1.density = 0
	f1.set_opacity(0)
	f2.density = 0
	f2.set_opacity(0)
	f3.density = 0
	f3.set_opacity(0)
	f4.density = 0
	f4.set_opacity(0)

	air_update_turf(1)
	update_freelok_sight()

	if(operating == 1) //emag again
		src.operating = 0
	if(autoclose)
		spawn(150)
			autoclose()
	return 1

/obj/machinery/door/poddoor/four_tile_ver/close()
	if (src.operating)
		return
	src.operating = 1
	flick("pdoorc1", src)
	src.icon_state = "pdoor1"
	src.density = 1

	f1.density = 1
	f1.set_opacity(1)
	f2.density = 1
	f2.set_opacity(1)
	f3.density = 1
	f3.set_opacity(1)
	f4.density = 1
	f4.set_opacity(1)

	if (src.visible)
		src.set_opacity(1)
	air_update_turf(1)
	update_freelok_sight()

	sleep(10)
	src.operating = 0
	return


/obj/machinery/door/poddoor/two_tile_hor
	var/obj/machinery/door/poddoor/filler_object/f1
	var/obj/machinery/door/poddoor/filler_object/f2
	icon = 'icons/obj/doors/1x2blast_hor.dmi'

	New()
		..()
		f1 = new/obj/machinery/door/poddoor/filler_object (src.loc)
		f2 = new/obj/machinery/door/poddoor/filler_object (get_step(f1,EAST))
		f1.density = density
		f2.density = density
		f1.set_opacity(opacity)
		f2.set_opacity(opacity)

	Destroy()
		del f1
		del f2
		..()

/obj/machinery/door/poddoor/two_tile_ver
	var/obj/machinery/door/poddoor/filler_object/f1
	var/obj/machinery/door/poddoor/filler_object/f2
	icon = 'icons/obj/doors/1x2blast_vert.dmi'

	New()
		..()
		f1 = new/obj/machinery/door/poddoor/filler_object (src.loc)
		f2 = new/obj/machinery/door/poddoor/filler_object (get_step(f1,NORTH))
		f1.density = density
		f2.density = density
		f1.set_opacity(opacity)
		f2.set_opacity(opacity)

	Destroy()
		del f1
		del f2
		..()

/obj/machinery/door/poddoor/three_tile_hor
	var/obj/machinery/door/poddoor/filler_object/f1
	var/obj/machinery/door/poddoor/filler_object/f2
	var/obj/machinery/door/poddoor/filler_object/f3
	icon = 'icons/obj/doors/1x3blast_hor.dmi'

	New()
		..()
		f1 = new/obj/machinery/door/poddoor/filler_object (src.loc)
		f2 = new/obj/machinery/door/poddoor/filler_object (get_step(f1,EAST))
		f3 = new/obj/machinery/door/poddoor/filler_object (get_step(f2,EAST))
		f1.density = density
		f2.density = density
		f3.density = density
		f1.set_opacity(opacity)
		f2.set_opacity(opacity)
		f3.set_opacity(opacity)

	Destroy()
		del f1
		del f2
		del f3
		..()

/obj/machinery/door/poddoor/three_tile_ver
	var/obj/machinery/door/poddoor/filler_object/f1
	var/obj/machinery/door/poddoor/filler_object/f2
	var/obj/machinery/door/poddoor/filler_object/f3
	icon = 'icons/obj/doors/1x3blast_vert.dmi'

	New()
		..()
		f1 = new/obj/machinery/door/poddoor/filler_object (src.loc)
		f2 = new/obj/machinery/door/poddoor/filler_object (get_step(f1,NORTH))
		f3 = new/obj/machinery/door/poddoor/filler_object (get_step(f2,NORTH))
		f1.density = density
		f2.density = density
		f3.density = density
		f1.set_opacity(opacity)
		f2.set_opacity(opacity)
		f3.set_opacity(opacity)

	Destroy()
		del f1
		del f2
		del f3
		..()

/obj/machinery/door/poddoor/four_tile_hor
	var/obj/machinery/door/poddoor/filler_object/f1
	var/obj/machinery/door/poddoor/filler_object/f2
	var/obj/machinery/door/poddoor/filler_object/f3
	var/obj/machinery/door/poddoor/filler_object/f4
	icon = 'icons/obj/doors/1x4blast_hor.dmi'

	New()
		..()
		f1 = new/obj/machinery/door/poddoor/filler_object (src.loc)
		f2 = new/obj/machinery/door/poddoor/filler_object (get_step(f1,EAST))
		f3 = new/obj/machinery/door/poddoor/filler_object (get_step(f2,EAST))
		f4 = new/obj/machinery/door/poddoor/filler_object (get_step(f3,EAST))
		f1.density = density
		f2.density = density
		f3.density = density
		f4.density = density
		f1.set_opacity(opacity)
		f2.set_opacity(opacity)
		f3.set_opacity(opacity)
		f4.set_opacity(opacity)

	Destroy()
		del f1
		del f2
		del f3
		del f4
		..()

/obj/machinery/door/poddoor/four_tile_ver
	var/obj/machinery/door/poddoor/filler_object/f1
	var/obj/machinery/door/poddoor/filler_object/f2
	var/obj/machinery/door/poddoor/filler_object/f3
	var/obj/machinery/door/poddoor/filler_object/f4
	icon = 'icons/obj/doors/1x4blast_vert.dmi'

	New()
		..()
		f1 = new/obj/machinery/door/poddoor/filler_object (src.loc)
		f2 = new/obj/machinery/door/poddoor/filler_object (get_step(f1,NORTH))
		f3 = new/obj/machinery/door/poddoor/filler_object (get_step(f2,NORTH))
		f4 = new/obj/machinery/door/poddoor/filler_object (get_step(f3,NORTH))
		f1.density = density
		f2.density = density
		f3.density = density
		f4.density = density
		f1.set_opacity(opacity)
		f2.set_opacity(opacity)
		f3.set_opacity(opacity)
		f4.set_opacity(opacity)

	Destroy()
		del f1
		del f2
		del f3
		del f4
		..()

/obj/machinery/door/poddoor/filler_object
	name = ""
	icon_state = ""