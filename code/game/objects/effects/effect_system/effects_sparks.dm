/////////////////////////////////////////////
//SPARK SYSTEM (like steam system)
// The attach(atom/atom) proc is optional, and can be called to attach the effect
// to something, like the RCD, so then you can just call start() and the sparks
// will always spawn at the items location.
/////////////////////////////////////////////

/proc/do_sparks(n, c, source)
	// n - number of sparks
	// c - cardinals, bool, do the sparks only move in cardinal directions?
	// source - source of the sparks.

	var/datum/effect_system/spark_spread/sparks = new
	sparks.set_up(n, c, source)
	sparks.autocleanup = TRUE
	INVOKE_ASYNC(sparks, TYPE_PROC_REF(/datum/effect_system, start))

/obj/effect/particle_effect/sparks
	name = "sparks"
	desc = "it's a spark what do you need to know?"
	icon_state = "sparks"
	var/hotspottemp = 1000

/obj/effect/particle_effect/sparks/New()
	..()
	playsound(src, "sparks", 100, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	var/turf/T = loc
	if(isturf(T))
		T.hotspot_expose(hotspottemp, 1)
	QDEL_IN(src, 20)

/obj/effect/particle_effect/sparks/Destroy()
	var/turf/T = loc
	if(isturf(T))
		T.hotspot_expose(hotspottemp,1)
	return ..()

/obj/effect/particle_effect/sparks/Move()
	..()
	var/turf/T = loc
	if(isturf(T))
		T.hotspot_expose(hotspottemp,1)

/datum/effect_system/spark_spread
	effect_type = /obj/effect/particle_effect/sparks

/datum/effect_system/spark_spread/generate_effect()
	var/spark_budget = GLOBAL_SPARK_LIMIT - GLOB.sparks_active
	if(spark_budget <= 0)
		return
	GLOB.sparks_active++
	return ..()

/datum/effect_system/spark_spread/decrement_total_effect()
	GLOB.sparks_active--
	return ..()

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
