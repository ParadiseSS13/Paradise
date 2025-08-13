/datum/emote/exercise
	key = "exercise"
	key_third_person = "exercises"
	name = EMOTE_EXERCISE
	// message = "упражняется!"
	hands_use_check = TRUE
	emote_type = EMOTE_VISIBLE | EMOTE_FORCE_NO_RUNECHAT // Don't need an emote to see that
	mob_type_allowed_typecache = list(/mob/living, /mob/dead/observer)
	mob_type_blacklist_typecache = list(/mob/living/brain, /mob/camera, /mob/living/silicon/ai)
	mob_type_ignore_stat_typecache = list(/mob/dead/observer)
	cooldown = 3 SECONDS

	var/subtypes_types = /datum/exercise/easy

	var/message_prepare = "начал упражнение."
	var/message_self_prepare = "Вы начали упражнение."
	var/message_blind_prepare = "Вы слышите шорох."
	var/message_warning = "Как вы собрались упражняться?!"
	var/message_tired = "Вы уставший! Передохните."

	var/message_choice = "Упражнения"
	var/message_choice_title = "Каким упражнением займусь?"

	var/is_need_lying = FALSE
	var/is_need_legs = TRUE
	var/is_need_arms = TRUE

/datum/emote/exercise/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	if(!.)
		return FALSE
	. = TRUE

	if(!isliving(user))
		return
	var/mob/living/L = user
	if(L.getStaminaLoss() > 0)
		to_chat(user, span_warning(message_tired))
		return
	if(!can_do_exercise(user))
		return

	user.visible_message(span_notice("[user] [message_prepare]"), span_notice(message_self_prepare), span_notice(message_blind_prepare))

	var/list/choice_dict = list()
	var/list/exercise_list = subtypesof(subtypes_types)
	for(var/i in exercise_list)
		var/datum/exercise/exercise = i
		if(!ishuman(user) && !initial(exercise.can_non_humans_do))
			continue
		choice_dict.Add(list("[initial(exercise.name)]" = exercise))

	var/choice = tgui_input_list(user, message_choice_title, message_choice, choice_dict, 60 SECONDS)

	if(choice)
		var/exercise_type = choice_dict[choice]
		var/datum/exercise/exercise = new exercise_type(src, user)
		var/temp_message = exercise.is_bold_message ? span_boldnotice("[exercise.message]") : span_notice("[exercise.message]")
		var/temp_self_message = exercise.is_bold_message ? span_boldnotice("[exercise.self_message]") : span_notice("[exercise.self_message]")
		var/temp_blind_message = "[exercise.blind_message]"
		user.visible_message(temp_message, temp_self_message, temp_blind_message)
		exercise.volume = get_volume(user)
		exercise.intentional = intentional
		exercise.try_execute()

// Если проверки внести в run_emote, то он будет писать ошибку "Не найдена эмоция", хотя он её нашел.
// Вынесено в отдельный прок емоута, чтобы не дублировать в датуме и не создавать сам датум для проверки.
/datum/emote/exercise/proc/can_do_exercise(mob/user)
	if(!user.mind || !user.client)
		return FALSE
	if(isobserver(user))
		return TRUE

	var/mob/living/L = user

	if(L.incapacitated())
		to_chat(user, span_warning("Вы не в форме!"))
		return FALSE
	if(is_need_lying && (!L.resting || L.buckled))
		to_chat(user, span_warning("Вы в неправильном положении! Ложитесь!"))
		return FALSE

	var/turf/user_turf = get_turf(user)
	if(!user_turf)
		to_chat(user, span_warning("Не на что опереться!"))
		return FALSE
	if(length(user_turf.contents) >= 10)
		to_chat(user, span_warning("Пол захламлен, неудобно!"))
		return FALSE
	for(var/atom/A in user_turf.contents)
		if(isliving(A) && A != user) // antierp
			var/mob/living/target = A
			if(is_need_lying && target.body_position == LYING_DOWN)
				to_chat(user, span_warning("Кто-то подо мной мне мешает!"))
			else
				to_chat(user, span_warning("Кто-то мне мешает!"))
			return FALSE

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		var/list/extremities_legs = list(
			BODY_ZONE_L_ARM,
			BODY_ZONE_R_ARM,
			BODY_ZONE_PRECISE_L_HAND,
			BODY_ZONE_PRECISE_R_HAND,
			)
		var/list/extremities_arms = list(
			BODY_ZONE_L_LEG,
			BODY_ZONE_R_LEG,
			BODY_ZONE_PRECISE_L_FOOT,
			BODY_ZONE_PRECISE_R_FOOT,
			)
		for(var/zone in extremities_legs)
			if(!H.get_limb_by_name(zone))
				to_chat(user, span_warning("У вас проблемы с ногами! [message_warning]"))
				return FALSE
		for(var/zone in extremities_arms)
			if(!H.get_limb_by_name(zone))
				to_chat(user, span_warning("У вас проблемы с руками! [message_warning]"))
				return FALSE

	return TRUE
