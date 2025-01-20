// ===========================
// ========== EMOTE ==========
// ===========================

/datum/emote/exercise/pushup
	key = "pushup"
	key_third_person = "pushups"
	name = EMOTE_PUSHUP
	subtypes_types = /datum/exercise/pushup

	message_prepare = "начал отжиматься."
	message_self_prepare = "Вы начали отжиматься."
	message_blind_prepare = "Вы слышите шорох."
	message_warning = "Как вы собрались отжиматься?!"

	message_choice = "Отжимания"
	message_choice_title = "Отжимание с каким упором?"

	is_need_lying = TRUE

// ===========================
// ======= DATUM TYPES =======
// ===========================

/datum/exercise/pushup
	name = "ДЕБАГ АЧЖУМАНИЯ (Вы не должны это видеть)"
	message = "перенес свой вес на руки и ноги."
	self_message = "Вы переносите свой вес на руки и ноги."
	blind_message = "Вы слышите шорох."

	message_force_stop = "прекратил отжиматься"
	message_self_force_stop = "Вы прекратили отжиматься"
	verb_case = "отжавшись"
	verb_times = "раз"

	message_do = "отжимается" // "[user] [message_do]"
	message_self_do = "Вы отжимаетесь"
	message_end = "Вы обессиленные падаете на пол"

	brute_border = 50
	exercise_div = 2

/datum/exercise/pushup/correct
	name = "На ноги и руки"
	message = "перенес свой вес на руки и ноги."
	self_message = "Вы переносите свой вес на руки и ноги."

/datum/exercise/pushup/correct/safety
	name = "На ноги и руки - безопасный"
	will_do_more_due_to_oxy_damage = FALSE

/datum/exercise/pushup/knees
	name = "На колени"
	message = "переносит свой вес на колени. Жалкое зрелище."
	self_message = "Вы сместили вес на колени. СЛАБАК!"
	message_exercise = "на коленях"
	can_non_humans_do = FALSE
	difficulty_mod = 0.6

/datum/exercise/pushup/one_arm
	name = "На одной руке"
	message = "перенес свой вес на ОДНУ РУКУ! Мощно!"
	self_message = "Вы переносите свой вес на одну руку. Сильно!"
	message_exercise = "на одной руке"
	can_non_humans_do = FALSE
	is_bold_message = TRUE
	difficulty_mod = 2

/datum/exercise/pushup/clap
	name = "На ноги и руки с хлопком"
	message = "перенес свой вес на руки и ноги и приготовился для хлопков! Хоп!"
	self_message = "Вы переносите свой вес на руки и ноги и приготовились для хлопков. Хоп!"
	message_exercise = "с хлопком"
	can_non_humans_do = FALSE
	is_bold_message = TRUE
	staminaloss_per_exercise = 10
	sounds = list(
		'modular_ss220/emotes/audio/claps/clap1.ogg',
		'modular_ss220/emotes/audio/claps/clap2.ogg',
		'modular_ss220/emotes/audio/claps/clap3.ogg',
		)

/datum/exercise/pushup/clap/fast
	name = "На ноги и руки с хлопком - быстрый"
	difficulty_mod = 1.25
	time_mod = 0.6
	split_message = 5

/datum/exercise/pushup/clap/one_arm
	name = "На одной руке с хлопком"
	message = "перенес свой вес на ОДНУ РУКУ и приготовил вторую для ХЛОПКА! НЕВЕРОЯТНО!"
	self_message = "Вы переносите свой вес на одну руку, а вторую приготовили для хлопка. Невероятно!"
	message_exercise = "на одной руке с хлопком"
	is_bold_message = TRUE
	staminaloss_per_exercise = 10
	difficulty_mod = 2

/datum/exercise/pushup/correct/slow
	name = "На ноги и руки - медленный"
	message_exercise = "медленно"
	difficulty_mod = 0.8
	time_mod = 2
	split_message = 5

/datum/exercise/pushup/correct/slow/very
	name = "На ноги и руки - очень медленный"
	message_exercise = "крайне медленно"
	difficulty_mod = 0.6
	time_mod = 4

/datum/exercise/pushup/correct/fast
	name = "На ноги и руки - быстрый"
	message_exercise = "быстро"
	difficulty_mod = 1.1
	time_mod = 0.6
	split_message = 2

/datum/exercise/pushup/correct/fast/very
	name = "На ноги и руки - очень быстрый"
	message_exercise = "крайне быстро"
	difficulty_mod = 1.2
	time_mod = 0.3
	split_message = 5

/datum/exercise/pushup/correct/foot
	name = "На ступнях"
	message = "переносит свой вес на ступни и убрал руки за спину! КАК ОН ЭТО ДЕЛАЕТ?!"
	self_message = "Вы сместили вес на ступни и убрали руки. ЭТО БУДЕТ НЕВОЗМОЖНО!"
	message_exercise = "на ступнях и без рук"
	staminaloss_per_exercise = 30
	difficulty_mod = 10
	is_bold_message = TRUE
	will_do_more_due_to_oxy_damage = FALSE
	can_non_humans_do = FALSE
