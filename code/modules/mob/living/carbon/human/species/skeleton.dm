/datum/species/skeleton
	name = "Skeleton"
	name_plural = "Skeletons"

	blurb = "Spoopy and scary."

	icobase = 'icons/mob/human_races/r_skeleton.dmi'
	deform = 'icons/mob/human_races/r_skeleton.dmi'

	blood_color = "#FFFFFF"
	flesh_color = "#E6E6C6"

	species_traits = list(NO_BREATHE, NO_BLOOD, RADIMMUNE, VIRUSIMMUNE)
	dies_at_threshold = TRUE
	skinned_type = /obj/item/stack/sheet/bone

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

	suicide_messages = list(
		"is snapping their own bones!",
		"is collapsing into a pile!",
		"is twisting their skull off!")
	has_organ = list(
		"brain" = /obj/item/organ/internal/brain/golem,
	) //Has default darksight of 2.

/datum/species/skeleton/handle_reagents(mob/living/carbon/human/H, datum/reagent/R)
	// Crazylemon is still silly
	if(R.id == "milk")
		H.heal_overall_damage(4, 4)
		if(prob(5)) // 5% chance per proc to find a random limb, and mend it
			var/list/our_organs = H.bodyparts.Copy()
			shuffle(our_organs)
			for(var/obj/item/organ/external/L in our_organs)
				if(istype(L))
					if(L.brute_dam < L.min_broken_damage)
						L.status &= ~ORGAN_BROKEN
						L.status &= ~ORGAN_SPLINTED
						H.handle_splints()
						L.perma_injury = 0
					break // We're only checking one limb here, bucko
		if(prob(3))
			H.say(pick("Thanks Mr. Skeltal", "Thank for strong bones", "Doot doot!"))
		return TRUE

	return ..()
