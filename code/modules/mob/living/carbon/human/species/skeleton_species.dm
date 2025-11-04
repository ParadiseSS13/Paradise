/// The OG skellybones, quite OP. As of this comment, only available through ash-drake loot (2023-03-07)
/datum/species/skeleton
	name = "Ancient Skeleton"
	name_plural = "Ancient Skeletons"

	blurb = "Spoopy and scary."

	icobase = 'icons/mob/human_races/r_skeleton.dmi'

	blood_color = "#FFFFFF"
	flesh_color = "#E6E6C6"

	species_traits = list(NO_BLOOD, NO_HAIR, NOT_SELECTABLE)
	inherent_traits = list(TRAIT_RESISTHEAT, TRAIT_NOBREATH, TRAIT_RESISTCOLD, TRAIT_RESISTHIGHPRESSURE, TRAIT_RESISTLOWPRESSURE, TRAIT_RADIMMUNE, TRAIT_PIERCEIMMUNE, TRAIT_NOHUNGER, TRAIT_XENO_IMMUNE, TRAIT_BURN_WOUND_IMMUNE)
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
	meat_type = /obj/item/food/meat/human // They've always done this.
	has_organ = list(
		"brain" = /obj/item/organ/internal/brain/golem,
	) //Has default darksight of 2.

	/// How much brute and burn does milk heal per handle_reagents()
	var/milk_heal_amount = 4
	/// How likely (in %) are we to heal a fracture?
	var/milk_fracture_repair_probability = 5

/datum/species/skeleton/handle_reagents(mob/living/carbon/human/H, datum/reagent/R)
	// Crazylemon is still silly
	if(R.id == "milk")
		H.heal_overall_damage(milk_heal_amount, milk_heal_amount)
		if(prob(milk_fracture_repair_probability)) // 5% chance per proc to find a random limb, and mend it
			var/list/our_organs = H.bodyparts.Copy()
			shuffle(our_organs)
			for(var/obj/item/organ/external/L in our_organs)
				if(L.mend_fracture())
					break // We're only checking one limb here, bucko
		if(prob(3))
			H.say(pick("Thanks Mr. Skeltal", "Thank for strong bones", "Doot doot!"))
		return TRUE

	return ..()

/// Wizard subtype, subtype to allow balancing separately from other skellies
/datum/species/skeleton/lich
	name = "Lich"
	name_plural = "Liches"

/// The most common (and weakest) type, legion corpses and skeleton map spawners are these
/datum/species/skeleton/brittle
	name = "Brittle Skeleton"
	name_plural = "Brittle Skeletons"
	inherent_traits = list(TRAIT_RESISTHEAT, TRAIT_NOBREATH, TRAIT_RESISTHIGHPRESSURE, TRAIT_RADIMMUNE, TRAIT_PIERCEIMMUNE, TRAIT_NOHUNGER, TRAIT_XENO_IMMUNE, TRAIT_BURN_WOUND_IMMUNE)
	milk_heal_amount = 0.66 // On par with saline-glucose (after averaging that out)
	milk_fracture_repair_probability = 0 //no bone juice here
