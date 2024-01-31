/atom
	var/tts_seed

/datum/dna
	var/tts_seed_dna

/datum/dna/Clone()
	. = ..()
	var/datum/dna/new_dna = .
	new_dna.tts_seed_dna = tts_seed_dna
	return new_dna

/atom/proc/select_voice(mob/user, silent_target = FALSE, override = FALSE, fancy_voice_input_tgui = FALSE)
	if(!user)
		if(!ismob(src))
			return null
		else
			user = src

	var/static/tts_test_str = "Так звучит мой голос."

	var/tts_seeds
	var/tts_gender = get_converted_tts_seed_gender(user.gender)
	var/list/tts_seeds_by_gender = SStts220.tts_seeds_by_gender[tts_gender]
	if(user && (check_rights(R_ADMIN, FALSE, user) || override))
		tts_seeds = tts_seeds_by_gender
	else
		tts_seeds = tts_seeds_by_gender && SStts220.get_available_seeds(src) // && for lists means intersection

	var/datum/character_save/active_character = user.client?.prefs.active_character
	var/new_tts_seed
	if(active_character?.tts_seed && (user.gender == active_character.gender))
		if(alert(user || src, "Оставляем голос вашего персонажа [active_character.real_name]?", "Выбор голоса", "Нет", "Да") ==  "Да")
			new_tts_seed = active_character.tts_seed

	if(!new_tts_seed)
		if(fancy_voice_input_tgui)
			new_tts_seed = tgui_input_list(user, "Выберите голос вашего персонажа", "Преобразуем голос", tts_seeds)
		else
			new_tts_seed = input(user, "Выберите голос вашего персонажа", "Преобразуем голос") as null|anything in tts_seeds

		if(!new_tts_seed)
			return null

	if(!silent_target && src != user && ismob(src))
		INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(tts_cast), null, src, tts_test_str, new_tts_seed, FALSE)

	if(user)
		INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(tts_cast), null, user, tts_test_str, new_tts_seed, FALSE)

	return new_tts_seed

/atom/proc/change_voice(mob/user, override = FALSE, fancy_voice_input_tgui = FALSE)
	set waitfor = FALSE
	var/new_tts_seed = select_voice(user = user, override = override, fancy_voice_input_tgui = fancy_voice_input_tgui)
	if(!new_tts_seed)
		return null
	return update_tts_seed(new_tts_seed)

/atom/proc/update_tts_seed(new_tts_seed)
	tts_seed = new_tts_seed
	return new_tts_seed

/mob/living/carbon/human/change_dna(datum/dna/new_dna, include_species_change, keep_flavor_text)
	. = ..()
	tts_seed = dna.tts_seed_dna

/client/create_response_team_part_1(new_gender, new_species, role, turf/spawn_location)
	. = ..()
	var/mob/living/ert_member = .
	ert_member.change_voice(src.mob)

/mob/living/silicon/verb/synth_change_voice()
	set name = "Смена голоса"
	set desc = "Express yourself!"
	set category = "Подсистемы"
	change_voice(fancy_voice_input_tgui = TRUE)

/atom/proc/get_converted_tts_seed_gender(gender_to_convert = gender)
	switch(gender_to_convert)
		if(MALE)
			return TTS_GENDER_MALE
		if(FEMALE)
			return TTS_GENDER_FEMALE
		else
			return TTS_GENDER_ANY

/atom/proc/pick_tts_seed_gender()
	var/tts_gender = get_converted_tts_seed_gender()
	return pick(SStts220.tts_seeds_by_gender[tts_gender])

/atom/proc/get_random_tts_seed_gender()
	var/tts_choice = pick_tts_seed_gender(gender)
	var/datum/tts_seed/seed = SStts220.tts_seeds[tts_choice]
	if(!seed)
		return null
	return seed.name

/**
* Surgery to change the voice of TTS.
* Below are the operations for organics and IPC.
*/

// Surgery for organics
/datum/surgery/vocal_cords_surgery
	name = "Vocal Cords Tuning Surgery"
	steps = list(
		/datum/surgery_step/generic/cut_open,
		/datum/surgery_step/generic/retract_skin,
		/datum/surgery_step/tune_vocal_cords,
		/datum/surgery_step/generic/cauterize
		)
	possible_locs = list(BODY_ZONE_PRECISE_MOUTH)


/datum/surgery/vocal_cords_surgery/can_start(mob/user, mob/living/carbon/target)
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		if(!H.check_has_mouth())
			return FALSE
		return TRUE

/datum/surgery_step/tune_vocal_cords
	name = "tune vocal cords"
	allowed_tools = list(/obj/item/scalpel = 100, /obj/item/kitchen/knife = 50, /obj/item/wirecutters = 35)
	time = 6 SECONDS
	var/target_vocal = "vocal cords"

/datum/surgery_step/tune_vocal_cords/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] begins to tune [target]'s vocals.", span_notice("You begin to tune [target]'s vocals..."))
	..()

/datum/surgery_step/tune_vocal_cords/end_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	target.change_voice(user, TRUE)
	user.visible_message("[user] tunes [target]'s vocals completely!", span_notice("You tune [target]'s vocals completely."))
	return TRUE

/datum/surgery_step/tune_vocal_cords/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/head/head = target.get_organ(target_zone)
	user.visible_message(span_warning("[user]'s hand slips, tearing [target_vocal] in [target]'s throat with [tool]!"), \
						span_warning("Your hand slips, tearing [target_vocal] in [target]'s throat with [tool]!"))
	target.tts_seed = SStts220.get_random_seed(target)
	target.apply_damage(10, BRUTE, head, sharp = TRUE)
	return FALSE

// Surgery for IPC
/datum/surgery/vocal_cords_surgery/ipc
	name = "Microphone Setup Operation"
	steps = list(
		/datum/surgery_step/robotics/external/unscrew_hatch,
		/datum/surgery_step/robotics/external/open_hatch,
		/datum/surgery_step/tune_vocal_cords/ipc,
		/datum/surgery_step/robotics/external/close_hatch
		)
	requires_organic_bodypart = FALSE

/datum/surgery/vocal_cords_surgery/ipc/can_start(mob/user, mob/living/carbon/target)
	if(!ishuman(target))
		return FALSE

	var/mob/living/carbon/human/H = target
	var/obj/item/organ/external/head/affected = H.get_organ(user.zone_selected)
	if(!affected)
		return FALSE
	if(!affected.is_robotic())
		return FALSE
	return TRUE

/datum/surgery_step/tune_vocal_cords/ipc
	name = "microphone setup"
	allowed_tools = list(/obj/item/multitool = 100, /obj/item/screwdriver = 55, /obj/item/scalpel = 25, /obj/item/kitchen/knife = 20)
	target_vocal = "microphone"
