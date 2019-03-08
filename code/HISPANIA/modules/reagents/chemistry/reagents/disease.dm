/datum/reagent/virush
	name = "VirusH"
	id = "virush"
	description = "An unknown virus that will turn you into a zombie"
	color = "#FF0000"
	can_synth = FALSE

/datum/reagent/virush/on_mob_life(mob/living/carbon/M)
	if(volume > 1.5)
		M.ForceContractDisease(new /datum/disease/transformation/virush(0))
	..()

