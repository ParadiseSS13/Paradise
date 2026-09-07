/mob/living/carbon/alien/humanoid/drone
	name = "alien drone"
	caste = "d"
	maxHealth = 150
	health = 150
	icon_state = "aliend_s"
	surgery_container = /datum/xenobiology_surgery_container/alien/drone

/mob/living/carbon/alien/humanoid/drone/Initialize(mapload)
	. = ..()
	name = "alien drone ([rand(1, 1000)])"
	real_name = name
	AddSpell(new /datum/spell/alien_spell/evolve_queen)

/mob/living/carbon/alien/humanoid/drone/get_caste_organs()
	. = ..()
	. += list(
		/obj/item/organ/internal/alien/plasmavessel/drone,
		/obj/item/organ/internal/alien/acidgland,
		/obj/item/organ/internal/alien/resinspinner,
	)
