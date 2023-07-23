/atom
	var/tts_seed

// SS220 TODO: usage of tts in dna
/datum/dna
	var/tts_seed_dna

/datum/dna/Clone()
	. = ..()
	var/datum/dna/new_dna = .
	new_dna.tts_seed_dna = tts_seed_dna
	return new_dna

/mob/living/carbon/human/Initialize(mapload, datum/species/new_species)
	. = ..()
	if(dna)
		dna.tts_seed_dna = tts_seed

/atom/proc/select_voice(mob/user, silent_target = FALSE, override = FALSE)
	if(!ismob(src) && !user)
		return null
	var/tts_test_str = "Так звучит мой голос."

	var/tts_seeds
	if(user && (check_rights(R_ADMIN, 0, user) || override))
		tts_seeds = SStts220.tts_seeds_names
	else
		tts_seeds = SStts220.get_available_seeds(src)

	var/new_tts_seed = input(user || src, "Choose your preferred voice:", "Character Preference", tts_seed) as null|anything in tts_seeds
	if(!new_tts_seed)
		return null
	if(!silent_target && ismob(src) && src != user)
		INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(tts_cast), null, src, tts_test_str, new_tts_seed, FALSE)
	if(user)
		INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(tts_cast), null, user, tts_test_str, new_tts_seed, FALSE)
	return new_tts_seed

/atom/proc/change_voice(mob/user, override = FALSE)
	set waitfor = FALSE
	var/new_tts_seed = select_voice(user, override = override)
	if(!new_tts_seed)
		return null
	return update_tts_seed(new_tts_seed)

/atom/proc/update_tts_seed(new_tts_seed)
	tts_seed = new_tts_seed
	return new_tts_seed

/datum/tts_seed
	var/name = "STUB"
	var/value = "STUB"
	var/category = TTS_CATEGORY_OTHER
	var/gender = TTS_GENDER_ANY
	var/datum/tts_provider/provider = /datum/tts_provider
	var/required_donator_level = 0

/datum/tts_seed/vv_edit_var(var_name, var_value)
	return FALSE

