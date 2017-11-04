/////////////////////////////////////////////
//SPARK SYSTEM (like steam system)
// The attach(atom/atom) proc is optional, and can be called to attach the effect
// to something, like the RCD, so then you can just call start() and the sparks
// will always spawn at the items location.
/////////////////////////////////////////////

/obj/effect/particle_effect/sparks
	name = "sparks"
	desc = "it's a spark what do you need to know?"
	icon_state = "sparks"
	anchored = 1
	var/hotspottemp = 1000

/obj/effect/particle_effect/sparks/New()
	..()
	playsound(loc, "sparks", 100, 1)
	var/turf/T = loc
	if(isturf(T))
		T.hotspot_expose(hotspottemp, 100)
	QDEL_IN(src, 20)

/obj/effect/particle_effect/sparks/Destroy()
	var/turf/T = loc
	if(isturf(T))
		T.hotspot_expose(hotspottemp,100)
	return ..()

/obj/effect/particle_effect/sparks/Move()
	..()
	var/turf/T = loc
	if(isturf(T))
		T.hotspot_expose(hotspottemp,100)

/datum/effect_system/spark_spread
	effect_type = /obj/effect/particle_effect/sparks

//////////////////////////////////
//////SPARKLE FIREWORKS
/////////////////////////////////
////////////////////////////
/obj/effect/particle_effect/sparks/sparkles
	name = "sparkle"
	icon = 'icons/obj/fireworks.dmi'//findback
	icon_state = "sparkel"
	hotspottemp = 3000

/obj/effect/particle_effect/sparks/sparkles/New()
	var/icon/I = new(src.icon,src.icon_state)
	var/r = rand(0,255)
	var/g = rand(0,255)
	var/b = rand(0,255)
	I.Blend(rgb(r,g,b),ICON_MULTIPLY)
	src.icon = I
	..()

/datum/effect_system/sparkle_spread
	effect_type = /obj/effect/particle_effect/sparks/sparkles
