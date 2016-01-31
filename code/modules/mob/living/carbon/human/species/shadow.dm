/datum/species/shadow
	name = "Shadow"
	name_plural = "Shadows"

	icobase = 'icons/mob/human_races/r_shadow.dmi'
	deform = 'icons/mob/human_races/r_shadow.dmi'

	default_language = "Galactic Common"
	unarmed_type = /datum/unarmed_attack/claws
	light_dam = 2
	darksight = 8

	blood_color = "#CCCCCC"
	flesh_color = "#AAAAAA"
	has_organ = list(
		"brain" = /obj/item/organ/brain
		)

	flags = NO_BLOOD | NO_BREATHE | NO_SCAN
	bodyflags = FEET_NOSLIP
	dietflags = DIET_OMNI		//the mutation process allowed you to now digest all foods regardless of initial race
	reagent_tag = PROCESS_ORG
	suicide_messages = list(
		"is attempting to bite their tongue off!",
		"is jamming their claws into their eye sockets!",
		"is twisting their own neck!",
		"is staring into the closest light source!")

/datum/species/shadow/handle_death(var/mob/living/carbon/human/H)
	H.dust()