/mob/living/carbon/alien/diona/attack_hand(mob/living/carbon/human/M as mob)

	if(istype(M))
		//Let people pick the little buggers up.
		if(M.a_intent == "help")
			if(M.species && M.species.name == "Diona")
				M << "You feel your being twine with that of [src] as it merges with your biomass."
				src << "You feel your being twine with that of [M] as you merge with its biomass."
				src.verbs += /mob/living/carbon/alien/diona/proc/split
				src.verbs -= /mob/living/carbon/alien/diona/proc/merge
				src.loc = M
			else
				get_scooped(M)
			return

	..()