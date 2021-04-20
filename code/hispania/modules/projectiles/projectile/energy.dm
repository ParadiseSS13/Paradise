/obj/item/projectile/energy/electrode/proc/electrode_effect(mob/living/carbon/C)
	C.Jitter(20)
	C.stuttering = max(8, C.stuttering)
	addtimer(CALLBACK(src, .proc/apply_stun, C), apply_stun_delay)
	return TRUE

/obj/item/projectile/energy/electrode/proc/apply_stun(mob/living/carbon/C)
	C.Weaken(5)
	C.Stun(5)
