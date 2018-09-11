/datum/species/vox/armalis
	name = "Vox Armalis"
	name_plural = "Vox Armalis"
	icobase = 'icons/mob/human_races/r_armalis.dmi'
	blacklisted = TRUE
	deform = 'icons/mob/human_races/r_armalis.dmi'
	path = /mob/living/carbon/human/voxarmalis
	unarmed_type = /datum/unarmed_attack/claws/armalis

	warning_low_pressure = 50
	hazard_low_pressure = 0

	cold_level_1 = 80
	cold_level_2 = 50
	cold_level_3 = 0

	heat_level_1 = 2000
	heat_level_2 = 3000
	heat_level_3 = 4000

	brute_mod = 0.2
	burn_mod = 0.2

	eyes = "blank_eyes"

	species_traits = list(NO_SCAN, NO_BLOOD, NO_PAIN)
	bodyflags = HAS_TAIL
	dietflags = DIET_OMNI	//should inherit this from vox, this is here just in case

	blood_color = "#2299FC"
	flesh_color = "#808D11"

	reagent_tag = PROCESS_ORG

	tail = "armalis_tail"
	icon_template = 'icons/mob/human_races/r_armalis.dmi'

	has_organ = list(
		"heart" =    /obj/item/organ/internal/heart,
		"lungs" =    /obj/item/organ/internal/lungs/vox,
		"liver" =    /obj/item/organ/internal/liver,
		"kidneys" =  /obj/item/organ/internal/kidneys,
		"brain" =    /obj/item/organ/internal/brain,
		"eyes" =     /obj/item/organ/internal/eyes, //Default darksight of 2.
		"stack" =    /obj/item/organ/internal/stack/vox //Not the same as the cortical stack implant Vox Raiders spawn with. The cortical stack implant is used
		)												//for determining the success of the heist game-mode's 'leave nobody behind' objective, while this is just an organ.

	suicide_messages = list(
		"is attempting to bite their tongue off!",
		"is jamming their claws into their eye sockets!",
		"is twisting their own neck!",
		"is holding their breath!",
		"is huffing oxygen!")

/datum/species/vox/armalis/handle_reagents() //Skip the Vox oxygen reagent toxicity. Armalis are above such things.
	return 1