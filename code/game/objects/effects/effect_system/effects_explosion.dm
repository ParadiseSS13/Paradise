/obj/effect/particle_effect/expl_particles
	name = "explosive particles"
	icon_state = "explosion_particle"
	opacity = 1
	anchored = 1

/obj/effect/particle_effect/expl_particles/New()
	..()
	QDEL_IN(src, 15)

/datum/effect_system/expl_particles
	number = 10

/datum/effect_system/expl_particles/start()
	for(var/i in 1 to number)
		spawn(0)
			var/obj/effect/particle_effect/expl_particles/expl = new /obj/effect/particle_effect/expl_particles(location)
			var/direct = pick(GLOB.alldirs)
			var/steps_amt = pick(1;25,2;50,3,4;200)
			for(var/j in 1 to steps_amt)
				sleep(1)
				step(expl,direct)

/obj/effect/explosion
	name = "explosive particles"
	icon = 'icons/effects/96x96.dmi'
	icon_state = "explosion"
	opacity = 1
	anchored = 1
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	pixel_x = -32
	pixel_y = -32

/obj/effect/explosion/New()
	..()
	QDEL_IN(src, 10)

/datum/effect_system/explosion

/datum/effect_system/explosion/set_up(loca)
	if(isturf(loca))
		location = loca
	else
		location = get_turf(loca)

/datum/effect_system/explosion/start()
	new/obj/effect/explosion(location)
	var/datum/effect_system/expl_particles/P = new/datum/effect_system/expl_particles()
	P.set_up(10, 0, location)
	P.start()

/datum/effect_system/explosion/smoke

/datum/effect_system/explosion/smoke/proc/create_smoke()
	var/datum/effect_system/smoke_spread/S = new
	S.set_up(5,0,location,null)
	S.start()

/datum/effect_system/explosion/smoke/start()
	..()
	addtimer(CALLBACK(src, .proc/create_smoke), 5)
