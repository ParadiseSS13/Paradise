//Fallback values for TTS voices

/mob/living/add_tts_component()
	AddComponent(/datum/component/tts_component)

/mob/living/simple_animal/add_tts_component()
	AddComponent(/datum/component/tts_component, /datum/tts_seed/silero/angel)

/mob/living/silicon/add_tts_component()
	AddComponent(/datum/component/tts_component, null, TTS_TRAIT_ROBOTIZE)

/mob/living/carbon/human/Initialize(mapload, datum/species/new_species)
	. = ..()
	if(dna)
		dna.tts_seed_dna = get_tts_seed()
