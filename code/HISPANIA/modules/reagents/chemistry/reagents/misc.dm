/datum/reagent/consumable/blackdeath_blood
	name = "Infected Blood"
	id = "infected_blood"
	description = "Blood whit a terrible disease"
	reagent_state = LIQUID
	color = "#f80000"

/datum/reagent/blackdeath_blood/on_mob_life(mob/living/carbon/M)
	if(volume > 2)
		M.ForceContractDisease(new /datum/disease/black_death(0))
	return ..()