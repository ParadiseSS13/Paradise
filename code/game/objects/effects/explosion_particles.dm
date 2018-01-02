/obj/effect/expl_particles
	name = "explosive particles"
	icon = 'icons/effects/effects.dmi'
	icon_state = "explosion_particle"
	opacity = 1
	anchored = 1
	mouse_opacity = 0

/obj/effect/expl_particles/New()
	..()
	spawn (15)
		qdel(src)
	return

/obj/effect/expl_particles/Move()
	..()
	return

/datum/effect/system/expl_particles
	number = 10

/datum/effect/system/expl_particles/set_up(n = 10, loca)
	number = n
	if(istype(loca, /turf/)) location = loca
	else location = get_turf(loca)

/datum/effect/system/expl_particles/start()
	var/i = 0
	for(i=0, i<src.number, i++)
		spawn(0)
			var/obj/effect/expl_particles/expl = new /obj/effect/expl_particles(src.location)
			var/direct = pick(alldirs)
			for(i=0, i<pick(1;25,2;50,3,4;200), i++)
				sleep(1)
				step(expl,direct)

/obj/effect/explosion
	name = "explosive particles"
	icon = 'icons/effects/96x96.dmi'
	icon_state = "explosion"
	opacity = 1
	anchored = 1
	mouse_opacity = 0
	pixel_x = -32
	pixel_y = -32

/obj/effect/explosion/New()
	..()
	spawn (10)
		qdel(src)

/datum/effect/system/explosion/set_up(turf/loc)
	..(loc=loc)

/datum/effect/system/explosion/start()
	new/obj/effect/explosion( location )
	var/datum/effect/system/expl_particles/P = new/datum/effect/system/expl_particles()
	P.set_up(10,location)
	P.start()

/datum/effect/system/explosion/smoke

/datum/effect/system/explosion/smoke/start()
	..()
	spawn(5)
		var/datum/effect/system/harmless_smoke_spread/S = new/datum/effect/system/harmless_smoke_spread()
		S.set_up(5,0,location,null)
		S.start()