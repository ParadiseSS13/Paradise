/obj/structure/particle_accelerator/particle_emitter
	name = "EM Containment Grid"
	desc_holder = "This part launches the Alpha particles. You might not want to stand near this end."
	icon_state = null
	var/fire_delay = 50
	var/last_shot = 0

/obj/structure/particle_accelerator/particle_emitter/center
	name = "EM Containment Grid Center"
	icon_state = "emitter_center"
	reference = "emitter_center"

/obj/structure/particle_accelerator/particle_emitter/left
	name = "EM Containment Grid Left"
	icon_state = "emitter_left"
	reference = "emitter_left"

/obj/structure/particle_accelerator/particle_emitter/right
	name = "EM Containment Grid Right"
	icon_state = "emitter_right"
	reference = "emitter_right"

/obj/structure/particle_accelerator/particle_emitter/proc/set_delay(delay)
	if(delay && delay >= 0)
		fire_delay = delay
		return 1
	return 0


/obj/structure/particle_accelerator/particle_emitter/proc/emit_particle(strength = 0)
	if((last_shot + fire_delay) <= world.time)
		last_shot = world.time
		var/turf/T = get_turf(src)
		var/obj/effect/accelerated_particle/P
		switch(strength)
			if(0)
				P = new/obj/effect/accelerated_particle/weak(T)
			if(1)
				P = new/obj/effect/accelerated_particle(T)
			if(2)
				P = new/obj/effect/accelerated_particle/strong(T)
			if(3)
				P = new/obj/effect/accelerated_particle/powerful(T)
		P.setDir(dir)
		return TRUE
	return FALSE
