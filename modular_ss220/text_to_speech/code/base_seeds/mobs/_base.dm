//Fallback values for TTS voices

/mob/living/Initialize()
	. = ..()
	if(!tts_seed)
		tts_seed = get_random_tts_seed_gender()

/mob/living/carbon/human/Initialize(mapload, datum/species/new_species)
	. = ..()
	if(dna)
		dna.tts_seed_dna = tts_seed
