/mob/living/carbon/alien/diona/attack_hand(mob/living/carbon/human/M as mob)
	if(istype(M) && M.a_intent == "help")
		if(M.species && M.species.name == "Diona" && do_merge(M))
			return
		get_scooped(M)
		return
	..()