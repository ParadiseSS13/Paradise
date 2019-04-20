/datum/species/nucleation
	name = "Nucleation"
	name_plural = "Nucleations"
	icobase = 'icons/mob/human_races/r_nucleation.dmi'
	blacklisted = TRUE
	blurb = "A sub-race of unfortunates who have been exposed to too much supermatter radiation. As a result, \
	supermatter crystal clusters have begun to grow across their bodies. Research to find a cure for this ailment \
	has been slow, and so this is a common fate for veteran engineers. The supermatter crystals produce oxygen, \
	negating the need for the individual to breathe. Their massive change in biology, however, renders most medicines \
	obselete. Ionizing radiation seems to cause resonance in some of their crystals, which seems to encourage regeneration \
	and produces a calming effect on the individual. Nucleations are highly stigmatized, and are treated much in the same \
	way as lepers were back on Earth."
	language = "Sol Common"
	burn_mod = 4 // holy shite, poor guys wont survive half a second cooking smores
	brute_mod = 2 // damn, double wham, double dam
	species_traits = list(LIPS, IS_WHITELISTED, NO_BREATHE, NO_BLOOD, NO_PAIN, NO_SCAN, RADIMMUNE)
	dies_at_threshold = TRUE
	dietflags = DIET_OMNI		//still human at their core, so they maintain their eating habits and diet

	//Default styles for created mobs.
	default_hair = "Nucleation Crystals"

	reagent_tag = PROCESS_ORG
	has_organ = list(
		"heart" =    /obj/item/organ/internal/heart,
		"crystallized brain" =    /obj/item/organ/internal/brain/crystal,
		"eyes" =     /obj/item/organ/internal/eyes/luminescent_crystal, //Standard darksight of 2.
		"strange crystal" = /obj/item/organ/internal/nucleation/strange_crystal
		)
	vision_organ = /obj/item/organ/internal/eyes/luminescent_crystal

/datum/species/nucleation/on_species_gain(mob/living/carbon/human/H)
	..()
	H.light_color = "#1C1C00"
	H.set_light(2)

/datum/species/nucleation/handle_death(mob/living/carbon/human/H)
	var/turf/T = get_turf(H)
	H.visible_message("<span class='warning'>[H]'s body explodes, leaving behind a pile of microscopic crystals!</span>")
	explosion(T, 0, 0, 2, 2) // Create a small explosion burst upon death
	qdel(H)