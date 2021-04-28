/obj/item/projectile/energy/electrode_turret
	name = "electrode"
	icon_state = "spark"
	color = "#FFFF00"
	nodamage = 1
	stun = 5
	weaken = 5
	stutter = 5
	jitter = 20
	hitsound = 'sound/weapons/tase.ogg'
	range = 7

/obj/item/projectile/energy/electrode_turret/on_hit(atom/target, blocked = 0)
	. = ..()
	if(!ismob(target) || blocked >= 100) //Fully blocked by mob or collided with dense object - burst into sparks!
		do_sparks(1, 1, src)
	else if(iscarbon(target))
		var/mob/living/carbon/C = target
		if(C.status_flags & CANWEAKEN)
			spawn(5)
				C.do_jitter_animation(jitter)

/obj/item/projectile/energy/electrode/proc/electrode_effect(mob/living/carbon/C)
	C.do_jitter_animation(20)
	C.stuttering = max(8,C.stuttering)
	spawn(1.5 SECONDS) // Las cosas que se tienen que hacer por pasar el electrodo a qdelete
		C.Weaken(5)
		C.Stun(5)
		C.do_jitter_animation(20)
	return TRUE
