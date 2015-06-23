/datum/species/shadow
	name = "Shadow"

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

/datum/species/shadow/handle_death(var/mob/living/carbon/human/H)
	H.dust()