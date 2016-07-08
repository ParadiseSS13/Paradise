/datum/species/shadow
	name = "Shadow"
	name_plural = "Shadows"

	icobase = 'icons/mob/human_races/r_shadow.dmi'
	deform = 'icons/mob/human_races/r_shadow.dmi'

	default_language = "Galactic Common"
	unarmed_type = /datum/unarmed_attack/claws
	darksight = 8

	blood_color = "#CCCCCC"
	flesh_color = "#AAAAAA"
	has_organ = list(
		"brain" = /obj/item/organ/internal/brain
		)

	flags = NO_BLOOD | NO_BREATHE | RADIMMUNE
	virus_immune = 1
	dietflags = DIET_OMNI		//the mutation process allowed you to now digest all foods regardless of initial race
	reagent_tag = PROCESS_ORG
	suicide_messages = list(
		"is attempting to bite their tongue off!",
		"is jamming their claws into their eye sockets!",
		"is twisting their own neck!",
		"is staring into the closest light source!")

/datum/species/shadow/handle_life(var/mob/living/carbon/human/H)
	var/light_amount = 0
	if(isturf(H.loc))
		var/turf/T = H.loc
		light_amount = T.get_lumcount()*10

		if(light_amount > 2) //if there's enough light, start dying
			H.take_overall_damage(1,1)
		else if(light_amount < 2) //heal in the dark
			H.heal_overall_damage(1,1)