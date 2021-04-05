/obj/item/gun/proc/radial_check(mob/living/carbon/human/H)
	if(!QDELETED(src) || !H.is_in_hands(src) || H.incapacitated())
		return FALSE
	return TRUE
