/datum/dna
	var/datum/tts_seed/tts_seed_dna

/datum/dna/Clone()
	. = ..()
	var/datum/dna/new_dna = .
	new_dna.tts_seed_dna = tts_seed_dna
	return new_dna

/mob/living/carbon/human/UpdateAppearance(list/UI)
	. = ..()
	AddComponent(/datum/component/tts_component, dna.tts_seed_dna)
