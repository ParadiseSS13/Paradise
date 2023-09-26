/atom
	var/tts_seed

/datum/dna
	var/tts_seed_dna

/datum/dna/Clone()
	. = ..()
	var/datum/dna/new_dna = .
	new_dna.tts_seed_dna = tts_seed_dna
	return new_dna

/atom/proc/select_voice(mob/user, silent_target = FALSE, override = FALSE)
	if(!ismob(src) && !user)
		return null
	var/static/tts_test_str = "Так звучит мой голос."

	var/tts_seeds
	if(user && (check_rights(R_ADMIN, FALSE, user) || override))
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

/mob/living/carbon/human/Initialize(mapload, datum/species/new_species)
	. = ..()
	if(dna)
		dna.tts_seed_dna = tts_seed

/mob/living/carbon/human/change_dna(datum/dna/new_dna, include_species_change, keep_flavor_text)
	. = ..()
	tts_seed = dna.tts_seed_dna

/client/create_response_team_part_1(new_gender, new_species, role, turf/spawn_location)
	. = ..()
	var/mob/living/ert_member = .
	ert_member.change_voice(src.mob)

/mob/living/silicon/verb/synth_change_voice()
	set name = "Change Voice"
	set desc = "Express yourself!"
	set category = "Subsystems"
	change_voice()
