/////////////////////////////////////////////
//SPARK SYSTEM (like steam system)
// The attach(atom/atom) proc is optional, and can be called to attach the effect
// to something, like the RCD, so then you can just call start() and the sparks
// will always spawn at the items location.
/////////////////////////////////////////////

/obj/effect/effect/sparks
	name = "sparks"
	desc = "it's a spark what do you need to know?"
	icon_state = "sparks"
	anchored = 1.0
	mouse_opacity = 0
	var/amount = 6.0

/obj/effect/effect/sparks/New()
	..()
	playsound(src.loc, "sparks", 100, 1)
	var/turf/T = loc
	if(istype(T, /turf))
		T.hotspot_expose(1000, 100)
	spawn (100)
		qdel(src)

/obj/effect/effect/sparks/Destroy()
	var/turf/T = src.loc
	if(istype(T, /turf))
		T.hotspot_expose(1000,100)
	return ..()

/obj/effect/effect/sparks/Move()
	..()
	var/turf/T = src.loc
	if(istype(T, /turf))
		T.hotspot_expose(1000,100)
	return

/datum/effect/system/spark_spread
	var/total_sparks = 0 // To stop it being spammed and lagging!

/datum/effect/system/spark_spread/set_up(n = 3, c = 0, loca)
	if(n > 10)
		n = 10
	number = n
	cardinals = c
	if(istype(loca, /turf/))
		location = loca
	else
		location = get_turf(loca)

/datum/effect/system/spark_spread/start()
	var/i = 0
	for(i=0, i<src.number, i++)
		if(src.total_sparks > 20)
			return
		spawn(0)
			if(holder)
				src.location = get_turf(holder)
			var/obj/effect/effect/sparks/sparks = new /obj/effect/effect/sparks(src.location)
			src.total_sparks++
			var/direction
			if(src.cardinals)
				direction = pick(cardinal)
			else
				direction = pick(alldirs)
			for(i=0, i<pick(1,2,3), i++)
				sleep(5)
				step(sparks,direction)
			spawn(20)
				qdel(sparks)
				src.total_sparks--

//////////////////////////////////
//////SPARKLE FIREWORKS
/////////////////////////////////
////////////////////////////
/obj/effect/sparkles
	name = "sparkle"
	icon = 'icons/obj/fireworks.dmi'//findback
	icon_state = "sparkel"
	var/amount = 6.0
	anchored = 1.0
	mouse_opacity = 0

/obj/effect/sparkles/New()
	..()
	var/icon/I = new(src.icon,src.icon_state)
	var/r = rand(0,255)
	var/g = rand(0,255)
	var/b = rand(0,255)
	I.Blend(rgb(r,g,b),ICON_MULTIPLY)
	src.icon = I
	playsound(src.loc, "sparks", 100, 1)
	var/turf/T = src.loc
	if(istype(T, /turf))
		T.hotspot_expose(3000,100)
	spawn (100)
		qdel(src)
	return

/obj/effect/sparkles/Destroy()
	var/turf/T = src.loc
	if(istype(T, /turf))
		T.hotspot_expose(3000,100)
	return ..()

/obj/effect/sparkles/Move()
	..()
	var/turf/T = src.loc
	if(istype(T, /turf))
		T.hotspot_expose(3000,100)
	return

/datum/effect/system/sparkle_spread
	var/total_sparks = 0 // To stop it being spammed and lagging!

/datum/effect/system/sparkle_spread/set_up(n = 3, c = 0, loca)
	if(n > 10)
		n = 10
	number = n
	cardinals = c
	if(istype(loca, /turf/))
		location = loca
	else
		location = get_turf(loca)

/datum/effect/system/sparkle_spread/start()
	var/i = 0
	for(i=0, i<src.number, i++)
		if(src.total_sparks > 20)
			return
		spawn(0)
			if(holder)
				src.location = get_turf(holder)
			var/obj/effect/sparkles/sparks = new(src.location)
			src.total_sparks++
			var/direction
			if(src.cardinals)
				direction = pick(cardinal)
			else
				direction = pick(alldirs)
			for(i=0, i<pick(1,2,3), i++)
				sleep(5)
				step(sparks,direction)
			spawn(20)
				qdel(sparks)
				src.total_sparks--
