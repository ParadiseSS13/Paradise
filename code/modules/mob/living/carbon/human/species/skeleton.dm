/datum/species/skeleton
	name = "Skeleton"
	name_plural = "Skeletons"

	blurb = "Spoopy and scary."

	icobase = 'icons/mob/human_races/r_skeleton.dmi'

	blood_color = "#FFFFFF"
	flesh_color = "#E6E6C6"

	species_traits = list(NO_BLOOD, NO_HAIR)
	inherent_traits = list(TRAIT_RESISTHEAT, TRAIT_NOBREATH, TRAIT_RESISTCOLD, TRAIT_RESISTHIGHPRESSURE, TRAIT_RESISTLOWPRESSURE, TRAIT_RADIMMUNE, TRAIT_PIERCEIMMUNE, TRAIT_NOHUNGER, TRAIT_XENO_IMMUNE)
	inherent_biotypes = MOB_UNDEAD | MOB_HUMANOID
	tox_mod = 0
	clone_mod = 0
	dies_at_threshold = TRUE
	skinned_type = /obj/item/stack/sheet/bone

	taste_sensitivity = TASTE_SENSITIVITY_NO_TASTE //skeletons can't taste anything

	dietflags = DIET_OMNI
	reagent_tag = PROCESS_ORG

	suicide_messages = list(
		"is snapping their own bones!",
		"is collapsing into a pile!",
		"is twisting their skull off!")

	vision_organ = null
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
				if(L.mend_fracture())
					break // We're only checking one limb here, bucko
		if(prob(3))
			H.say(pick("Thanks Mr. Skeltal", "Thank for strong bones", "Doot doot!"))
		return TRUE

	return ..()
