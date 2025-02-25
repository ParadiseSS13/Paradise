/datum/exercise/easy
	name = "Упражняться"
	will_do_more_due_to_oxy_damage = FALSE
	brute_border = 250
	exercise_div = 10
	split_message = 10

/datum/exercise/easy/normal

/datum/exercise/easy/warmup
	name = "Разомнуться"
	message = "приготовился разминаться."
	self_message = "Вы готовитесь разминаться."
	blind_message = "Вы слышите шорох."
	message_exercise = ""

	message_force_stop = "прекратил разминаться"
	message_self_force_stop = "Вы прекратили разминаться"
	verb_case = "разомнувшись"
	verb_times = "раз"

	message_do = "разминается"
	message_self_do = "Вы разминаетесь"
	message_end = "Вы достаточно разомнулись."

	brute_border = 500
	exercise_div = 10

/datum/exercise/easy/stretch
	name = "Потянуться"
	message = "приготовился потягиваться."
	self_message = "Вы готовитесь потягиваться."
	blind_message = "Вы слышите шорох."
	message_exercise = ""

	message_force_stop = "прекратил потягиваться"
	message_self_force_stop = "Вы прекратили потягиваться"
	verb_case = "потянувшись"
	verb_times = "раз"

	message_do = "потягивается"
	message_self_do = "Вы потягиваетесь"
	message_end = "Вы достаточно потянулись."

	brute_border = 200
	exercise_div = 7
