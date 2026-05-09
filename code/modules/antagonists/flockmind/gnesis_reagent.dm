/datum/reagent/toxin/gnesis
	name = "coagulated gnesis"
	description = "A thick teal fluid of alien origin. It moves in ways that suggest it might be alive in some way."
	color =  "#4d736d"
	taste_description = "oily, with a sweet aftertaste"

/datum/reagent/toxin/gnesis/on_mob_life(mob/living/M)
	if(volume > 12)
		M.ForceContractDisease(new /datum/disease/flock(0))
	return ..()
