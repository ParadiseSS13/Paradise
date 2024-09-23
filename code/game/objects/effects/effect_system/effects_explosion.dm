/obj/effect/particle_effect/expl_particles
	name = "explosive particles"
	icon_state = "explosion_particle"
	opacity = TRUE

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
