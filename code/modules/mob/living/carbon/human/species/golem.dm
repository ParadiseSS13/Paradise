/datum/species/golem
	name = "Golem"

	icobase = 'icons/mob/human_races/r_golem.dmi'
	deform = 'icons/mob/human_races/r_golem.dmi'

	default_language = "Galactic Common"
	flags = NO_BREATHE | NO_PAIN | NO_BLOOD | NO_SCAN

	blood_color = "#515573"
	flesh_color = "#137E8F"

	has_organ = list(
		"brain" = /obj/item/organ/brain/golem
		)

/datum/species/golem/handle_post_spawn(var/mob/living/carbon/human/H)
	if(H.mind)
		H.mind.assigned_role = "Golem"
		H.mind.special_role = "Golem"
	H.real_name = "adamantine golem ([rand(1, 1000)])"
	H.name = H.real_name
	..()