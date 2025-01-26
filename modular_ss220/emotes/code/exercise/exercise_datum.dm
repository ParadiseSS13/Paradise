/datum/exercise
	var/name = "ДЕБАГ УПРАЖНЕНИЯ (Пример что может быть)"
	var/message = "готовится к упражнению."
	var/self_message = "Вы готовитесь к упражнению."
	var/blind_message = "Вы слышите шорох."
	var/message_exercise = ""	// Дополнение для добавления в типе
	var/is_bold_message = FALSE // Выделяем наше сообщение
	var/split_message = 1 // Отображение сообщений каждые N раз, защита от спама

	// "[user] [message_force_stop], [verb_case] [exercises_in_a_row] [verb_times]"]
	var/message_force_stop = "прекратил упражняться" // "[user] [message_force_stop]"
	var/message_self_force_stop = "Вы прекратили упражняться"
	var/verb_case = "сделав упражнение"
	var/verb_times = "раз"

	var/message_do = "упражняется" // "[user] [message_do]"
	var/message_self_do = "Вы упражняетесь"
	var/message_end = "Вы обессилены"

	// Сообщения когда начинаем задыхаться
	var/message_oxy_grade = list(
		"",											// 0+
		" с одышкой",								// 20+
		" с умеренной одышкой",						// 40+
		" с тяжелой одышкой",						// 60+
		" весь покраснев и выпучив глаза",			// 80+
		", еле держась и прикрыв глаза",	// 100+
	)
	var/message_oxy_every_value = 20

	// Ограничители
	var/can_non_humans_do = TRUE // Отображение в списке для животных и гостов
	var/will_do_more_due_to_oxy_damage = TRUE // Сделает ли больше за счет урона по дыханию

	// Значения модификаторов используемых в рассчетах
	var/staminaloss_per_exercise = 5 // Начальное значение проходящее через модификаторы
	var/difficulty_mod = 1 // Чем больше - тем сложнее, умножаем
	var/time_mod = 1 // Чем больше - тем медленнее

	// Звуки воспроизводимые при каждом упражнении
	var/sounds
	var/volume = 50
	var/intentional = FALSE

	// Ранговая зависимость
	var/list/physical_job_exp_types = list(EXP_TYPE_SECURITY, EXP_TYPE_SUPPLY, EXP_TYPE_ENGINEERING)
	var/no_physical_job_div = 10 // Делитель опыта НЕ физических проф

	// Корректировки
	var/const/stamina_border_max = 95 // 100 - стаминакрит сбрасывающий анимацию
	var/const/oxy_border_max = 120 // 130 - оксикрит
	var/exercise_div = 1 // Чем больше - тем легче, корректировка для всех типов

	// Усложнители против абуза химикатов и прочего
	var/exercise_difficulty_level = 30 // Каждые N упражнений усложняем
	var/exercise_difficulty_level_valueloss = 1 // На сколько усложняем
	var/brute_border = 100 // С какого кол-ва упражнений начнет наносить урон

	// Внутренне изменяемые параметры
	var/datum/emote/exercise/emote
	var/mob/user
	var/exercises_in_a_row = 0 // Сделано упражнений подряд

/datum/exercise/New(datum/emote/linked_emote, mob/linked_user)
	. = ..()
	user = linked_user
	emote = linked_emote

/datum/exercise/proc/try_execute()
	if(!emote.can_do_exercise(user))
		return
	prepare_for_exercise_animation()
	execute()
	clear_exercise_animation()

/datum/exercise/proc/execute()
	if(isobserver(user)) // Госты тоже хотят упражняться!
		exercise_animation()
		return

	var/mob/living/L = user
	var/exercise_value
	var/currentloss = L.getStaminaLoss() + L.getOxyLoss()
	var/oxy_border = will_do_more_due_to_oxy_damage ? oxy_border_max : 0
	var/borderloss = stamina_border_max + oxy_border
	while(currentloss < borderloss)
		if(!emote.can_do_exercise(user))
			return
		currentloss = L.getStaminaLoss() + L.getOxyLoss()
		exercise_value = calculate_valueloss_per_exercise() / time_mod
		if(exercise_value >= stamina_border_max)
			exercise_value = stamina_border_max + 5
		var/temp_time_mod = L.getOxyLoss() / 100 + time_mod
		if(!exercise_animation(temp_time_mod))
			exercise_stopped(user)
			return
		exercise_count(user)

		if(sounds)
			emote.play_sound_effect(user, intentional, get_sound(), volume)

		if((L.getStaminaLoss() + exercise_value) <= stamina_border_max)
			L.adjustStaminaLoss(exercise_value)
			continue

		L.setStaminaLoss(stamina_border_max)
		L.adjustOxyLoss(exercise_value)
		if(exercises_in_a_row >= brute_border)
			L.adjustBruteLoss(min(1, exercise_value))
		if(currentloss >= borderloss)
			to_chat(user, span_warning("[message_end], [verb_case] [exercises_in_a_row] [verb_times]..."))
			return

/datum/exercise/proc/get_sound()
	if(length(sounds))
		return pick(sounds)
	return FALSE

/datum/exercise/proc/calculate_valueloss_per_exercise()
	// Humans have 120 stamina
	// Default loss per exercise = 5 stamina
	var/mob/living/L = user
	if(ismachineperson(user) || isskeleton(user))
		return 0.1

	var/valueloss = staminaloss_per_exercise

	if(L.getBruteLoss() >= 20)
		valueloss += L.getBruteLoss() / 10
	if(L.nutrition <= NUTRITION_LEVEL_STARVING)
		valueloss += 2
	if(L.health <= ((L.maxHealth / 10) * 9))
		valueloss += 2

	if(!ishuman(user))
		return max(1, valueloss)

	var/mob/living/carbon/human/H = user

	valueloss += 0.5 * H.age/10
	if(H.wear_suit)
		valueloss += 0.5
	if(H.back)
		valueloss += 0.5

	var/list/extremities = list(
		BODY_ZONE_L_ARM,
		BODY_ZONE_R_ARM,
		BODY_ZONE_L_LEG,
		BODY_ZONE_R_LEG,
		)
	for(var/zone in extremities)
		var/obj/item/organ/limb = H.get_limb_by_name(zone)
		if(limb.is_robotic())
			valueloss -= 1

	var/is_physical_job = FALSE
	var/list/exp_types = is_physical_job ? physical_job_exp_types : list(EXP_TYPE_CREW)

	var/datum/job/job = SSjobs.GetJob(H.job)
	for(var/exp_type in exp_types)
		if(exp_type in physical_job_exp_types)
			is_physical_job = TRUE
			break
	var/list/play_records = params2list(H.client.prefs.exp)

	// Берем немного суммы часов за экипаж, отдаляя их от персонала занимающейся физической работой
	var/exp_sum = text2num(play_records[EXP_TYPE_CREW]) / no_physical_job_div
	if(job)
		for(var/exp_type in job.exp_map)
			if(!(exp_type in exp_types))
				exp_sum += text2num(play_records[exp_type])
	exp_sum /= 60 // Конвертируем из минут в часы

	valueloss += staminaloss_per_exercise - exp_sum / 100

	if(valueloss <= 0)
		valueloss = 1

	valueloss += (exercises_in_a_row + 1) / exercise_difficulty_level * exercise_difficulty_level_valueloss

	if(isgrey(user) || istajaran(user))
		valueloss *= 2
	if(isvulpkanin(user) || iswolpin(user))
		valueloss /= 2
	if(iskidan(user) || isunathi(user))
		valueloss /= 3
	if(isdiona(user))
		valueloss /= 5

	valueloss /= exercise_div
	valueloss *= difficulty_mod

	return max(0.25, valueloss)

/datum/exercise/proc/exercise_stopped()
	user.visible_message(
		span_boldnotice("[user] [message_force_stop], [verb_case] [exercises_in_a_row] [verb_times]."),
		span_boldnotice("[message_self_force_stop], [verb_case] [exercises_in_a_row] [verb_times]."),
		blind_message)

/datum/exercise/proc/exercise_count()
	exercises_in_a_row++

	if(!ishuman(user)) // антиспам
		return
	var/split_count = exercises_in_a_row / split_message
	if(!(split_count == round(split_count)))
		return

	var/mob/living/L = user
	var/exercise_text = get_exercise_message_addition(L)
	var/temp_message = "[user] [message_do][exercise_text]!"
	var/temp_self_message = "[message_self_do][exercise_text]!"
	user.visible_message(
		is_bold_message ? span_boldnotice(temp_message) : span_notice(temp_message),
		is_bold_message ? span_boldnotice(temp_self_message) : span_notice(temp_self_message),
		blind_message)

/datum/exercise/proc/get_exercise_message_addition()
	var/mob/living/L = user
	var/message_num = round(L.getOxyLoss() / message_oxy_every_value) + 1
	var/grade_length = length(message_oxy_grade)
	if(message_num > grade_length)
		message_num = grade_length
	var/temp_message_exercise = message_exercise != "" ? " [message_exercise]" : ""
	return "[temp_message_exercise][message_oxy_grade[message_num]]"
