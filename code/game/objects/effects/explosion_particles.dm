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
var/icon/smallplosion = 0
var/icon/midplosion = 0
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
	return
/datum/effect/system/explosion/
	var/particles = 10
	var/smoke = 5
	var/smokedur = 75
	var/size = 1
	var/smokerng = 1
	var/pixoff = -32
	var/iconused = 'icons/effects/96x96.dmi'
/datum/effect/system/explosion/set_up(turf/loc)
	..(loc=loc)
/datum/effect/system/explosion/proc/setsize(var/newsize)
	if (size == newsize)
		return
	if (smallplosion == 0)
		smallplosion = new('icons/effects/96x96.dmi')
		smallplosion = smallplosion.Scale(32,32)
	if (midplosion == 0)
		midplosion = new('icons/effects/96x96.dmi')
		midplosion = midplosion.Scale(64,64)
	size = newsize
	switch (newsize)
		if (1)
			iconused = 'icons/effects/96x96.dmi'
			particles = 10
			smoke = 2
			smokedur = 30
			pixoff = -32
			smokerng = 1
			return
		if (2)
			iconused = midplosion
			particles = 6
			smoke = 1
			smokedur = 5
			pixoff = -16
			smokerng = 1
			return
		if (3)
			iconused = smallplosion
			particles = 2
			smoke = 0
			pixoff = 0
			smokerng = 1
			return
/datum/effect/system/explosion/start()
	var/obj/effect/explosion/exptmp = new(location) //, icon = iconused, pixel_y = pixoff, pixel_x = pixoff
	exptmp.icon = iconused
	exptmp.pixel_y = pixoff
	exptmp.pixel_x = pixoff
	exptmp = null
	var/datum/effect/system/expl_particles/P = new/datum/effect/system/expl_particles()
	P.set_up(particles,location)
	P.start()
	if (smoke > 0)
		if (smokerng == 0 || prob(33))
			spawn(-1)
				var/datum/effect/system/harmless_smoke_spread/S = new/datum/effect/system/harmless_smoke_spread()
				S.set_up(smoke,0,location,null)
				S.duration = smokedur
				S.start()