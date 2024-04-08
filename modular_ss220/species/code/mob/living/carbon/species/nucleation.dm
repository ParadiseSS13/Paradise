/datum/species/nucleation
	name = "Nucleation"
	name_plural = "Nucleations"
	icobase = 'modular_ss220/species/icons/mob/human_races/r_nucleation.dmi'
	blurb = "A sub-race of unfortunates who have been exposed to too much supermatter radiation. As a result, \
	supermatter crystal clusters have begun to grow across their bodies. Research to find a cure for this ailment \
	has been slow, and so this is a common fate for veteran engineers. The supermatter crystals produce oxygen, \
	negating the need for the individual to breathe. Their massive change in biology, however, renders most medicines \
	obselete. Ionizing radiation seems to cause resonance in some of their crystals, which seems to encourage regeneration \
	and produces a calming effect on the individual. Nucleations are highly stigmatized, and are treated much in the same \
	way as lepers were back on Earth."
	language = "Sol Common"
	burn_mod = 0.5
	brute_mod = 2
	siemens_coeff = 0.5
	species_traits = list(LIPS, NO_BLOOD, NO_CLONESCAN)
	inherent_traits = list(TRAIT_NOBREATH, TRAIT_RADIMMUNE, TRAIT_NOPAIN, TRAIT_SUPERMATTER_IMMUNE)
	bodyflags = SHAVED
	dies_at_threshold = TRUE
	dietflags = DIET_OMNI		//still human at their core, so they maintain their eating habits and diet

	//Default styles for created mobs.
	default_hair = "Nucleation Crystals"

	reagent_tag = PROCESS_ORG
	has_organ = list(
		"heart" =    /obj/item/organ/internal/heart,
		"brain" =    /obj/item/organ/internal/brain/crystal,
		"eyes" =     /obj/item/organ/internal/eyes/luminescent_crystal, //Standard darksight of 2.
		"ears" = /obj/item/organ/internal/ears/resonant_crystal,
		"strange crystal" = /obj/item/organ/internal/nucleation/strange_crystal,
		"strange crystal" = /obj/item/organ/internal/nucleation/strange_crystal,
		"strange crystal" = /obj/item/organ/internal/nucleation/strange_crystal,
		)

	var/organ_explosion_thrown_range = 4
	var/organ_explosion_thrown_speed = 2
	var/max_light_impact_range = 4
	var/max_flash_range = 12

/datum/species/nucleation/on_species_gain(mob/living/carbon/human/H)
	..()
	H.light_color = "#1C1C00"
	H.set_light(2)

/datum/species/nucleation/handle_death(gibbed, mob/living/carbon/human/H)
	var/turf/T = get_turf(H)
	var/datum/mind/mind = H.mind
	H.visible_message(span_danger("Тело [H] взрывается, оставляя после себя кучу микроскопических кристаллов!"))
	H.gib()
	var/nutrition_mod = H.nutrition / NUTRITION_LEVEL_FAT
	var/light_impact_range = round(max_light_impact_range * nutrition_mod)
	var/flash_range = round(max_flash_range * nutrition_mod)
	explosion(T, 0, 0, min(light_impact_range, max_light_impact_range), min(flash_range, max_flash_range))

	// Не даем более возродиться
	if(mind)
		mind.current.ghostize(FALSE)
		if(!QDELETED(mind.current))
			mind.current.remove_status_effect(STATUS_EFFECT_REVIVABLE)
		SEND_SIGNAL(mind.current, COMSIG_LIVING_SET_DNR)
