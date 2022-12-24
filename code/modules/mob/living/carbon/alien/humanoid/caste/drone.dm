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

/mob/living/carbon/alien/humanoid/drone/get_caste_organs()
	. = ..()
	. += list(
		/obj/item/organ/internal/xenos/plasmavessel/drone,
		/obj/item/organ/internal/xenos/acidgland,
		/obj/item/organ/internal/xenos/resinspinner,
	)


//Drones use the same base as generic humanoids.
//Drone verbs

