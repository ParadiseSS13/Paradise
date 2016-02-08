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
	virus_immune = 1 //why is this a var and not a flag?
	dietflags = DIET_OMNI
	reagent_tag = PROCESS_ORG

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
		"brain" = /obj/item/organ/brain/golem,
	)

/datum/species/skeleton/handle_reagents(var/mob/living/carbon/human/H, var/datum/reagent/R)
	// Crazylemon is still silly
	if(R.id == "milk")
		H.heal_overall_damage(4,4)
		if(prob(5)) // 5% chance per proc to find a random limb, and mend it
			var/list/our_organs = H.organs.Copy()
			shuffle(our_organs)
			for(var/obj/item/organ/external/L in our_organs)
				if(istype(L))
					if(L.brute_dam < L.min_broken_damage)
						L.status &= ~ORGAN_BROKEN
						L.status &= ~ORGAN_SPLINTED
						L.perma_injury = 0
					break // We're only checking one limb here, bucko
		if(prob(3))
			H.say(pick("Thanks Mr Skeltal", "Thank for strong bones", "Doot doot!"))
		return 1

	return ..()