/mob/living/carbon/alien/humanoid/drone
	name = "alien drone"
	caste = "d"
	maxHealth = 100
	health = 100
	icon_state = "aliend_s"

/mob/living/carbon/alien/humanoid/drone/Initialize(mapload)
	. = ..()
	if(src.name == "alien drone")
		src.name = "alien drone ([rand(1, 1000)])"
	src.real_name = src.name
	AddSpell(new /datum/spell/alien_spell/evolve_queen)

/mob/living/carbon/alien/humanoid/drone/get_caste_organs()
	. = ..()
	. += list(
		/obj/item/organ/internal/alien/plasmavessel/drone,
		/obj/item/organ/internal/alien/acidgland,
		/obj/item/organ/internal/alien/resinspinner,
	)


//Drones use the same base as generic humanoids.
//Drone verbs

