/mob/living/carbon/human/proc/sword_reflect(obj/item/projectile/P)
	if(l_hand && istype(l_hand, /obj/item/melee/energy/sword))
		var/obj/item/melee/energy/sword/S = l_hand
		if(in_throw_mode && S.deflect_dots > 0)
			S.attempt_reload()
			return TRUE
	else if(r_hand && istype(r_hand, /obj/item/melee/energy/sword))
		var/obj/item/melee/energy/sword/S = r_hand
		if(in_throw_mode && S.deflect_dots > 0)
			S.attempt_reload()
			return TRUE
	return FALSE
