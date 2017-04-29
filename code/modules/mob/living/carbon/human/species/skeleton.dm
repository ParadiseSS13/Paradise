/datum/species/skeleton
	name = "Skeleton"
	name_plural = "Skeletons"

	blurb = "Spoopy and scary."

	icobase = 'icons/mob/human_races/r_skeleton.dmi'
	deform = 'icons/mob/human_races/r_skeleton.dmi'
	path = /mob/living/carbon/human/skeleton
	default_language = "Galactic Common"
	unarmed_type = /datum/unarmed_attack/punch

	blood_color = "#FFFFFF"
	flesh_color = "#E6E6C6"

	flags = NO_BREATHE | NO_BLOOD | RADIMMUNE

	oxy_mod = 0

	virus_immune = 1 //why is this a var and not a flag?
	dietflags = DIET_OMNI
	on_species_life_proc_name = "on_skeleton_life"

	warning_low_pressure = -1
	hazard_low_pressure = -1
	hazard_high_pressure = 999999999
	warning_high_pressure = 999999999

	cold_level_1 = -1
	cold_level_2 = -1
	cold_level_3 = -1

	heat_level_1 = 999999999
	heat_level_2 = 999999999
	heat_level_3 = 999999999
	heat_level_3_breathe = 999999999

	suicide_messages = list(
		"is snapping their own bones!",
		"is collapsing into a pile!",
		"is twisting their skull off!")
	has_organ = list(
		"brain" = /obj/item/organ/internal/brain/golem,
	) //Has default darksight of 2.
