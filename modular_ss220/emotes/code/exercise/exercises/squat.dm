// ===========================
// ========== EMOTE ==========
// ===========================

/datum/emote/exercise/squat
	key = "squat"
	key_third_person = "squats"
	name = EMOTE_SQUAT
	subtypes_types = /datum/exercise/squat

	message_prepare = "начал приседать."
	message_self_prepare = "Вы начали приседать."
	message_blind_prepare = "Вы слышите шорох."
	message_warning = "Как вы собрались приседать?!"

	message_choice = "Приседания"
	message_choice_title = "Как приседаем?"

	is_need_lying = FALSE

// ===========================
// ======= DATUM TYPES =======
// ===========================

/datum/exercise/squat
	name = "ДЕБАГ ПРЮСЕУДАНИЯ (Вы не должны это видеть)"
	message = "согнулся в коленях."
	self_message = "Вы сгибаетесь в коленях."
	blind_message = "Вы слышите шорох."
	message_exercise = ""

	message_force_stop = "прекратил приседать"
	message_self_force_stop = "Вы прекратили приседать"
	verb_case = "присев"
	verb_times = "раз"

	message_do = "приседает" // "[user] [message_do]"
	message_self_do = "Вы приседаете"
	message_end = "Ваши ноги подкосились и не могут разогнуться"

	brute_border = 150
	exercise_div = 5

/datum/exercise/squat/correct
	name = "Обычные"
	message = "согнулся в коленях."
	self_message = "Вы согнулись в коленях."

/datum/exercise/squat/correct/safety
	name = "Обычные - безопасные"
	will_do_more_due_to_oxy_damage = FALSE

/datum/exercise/squat/correct/slow
	name = "Обычные - медленные"
	message_exercise = "медленно"
	difficulty_mod = 0.8
	time_mod = 2
	split_message = 5

/datum/exercise/squat/correct/slow/very
	name = "Обычные - очень медленные"
	message_exercise = "крайне медленно"
	difficulty_mod = 0.6
	time_mod = 4

/datum/exercise/squat/correct/fast
	name = "Обычные - быстрые"
	message_exercise = "быстро"
	difficulty_mod = 1.1
	time_mod = 0.6
	split_message = 2

/datum/exercise/squat/correct/fast/very
	name = "Обычные - очень быстрые"
	message_exercise = "крайне быстро"
	difficulty_mod = 1.2
	time_mod = 0.3
	split_message = 5

/datum/exercise/squat/correct/foot
	name = "На цыпочках"
	message = "сгибается в коленях и ступнями встает на цыпочки! Как напряглись его икры!"
	self_message = "Вы согнулись в коленях и встали на цыпочки. Как же я хорош!"
	message_exercise = "на цыпочках"
	staminaloss_per_exercise = 10
	difficulty_mod = 3
	is_bold_message = TRUE
	will_do_more_due_to_oxy_damage = FALSE
	can_non_humans_do = FALSE
