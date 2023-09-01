GLOBAL_VAR(scoreboard) // Variable to save the scoreboard string once it's been generated


//Thresholds for Score Ratings
#define SINGULARITY_DESERVES_BETTER -3500
#define SINGULARITY_FODDER -3000
#define ALL_FIRED -2500
#define WASTE_OF_OXYGEN -2000
#define HEAP_OF_SCUM -1500
#define LAB_MONKEYS -1000
#define UNDESIREABLES -500
#define SERVANTS_OF_SCIENCE 500
#define GOOD_BUNCH 1000
#define MACHINE_THIRTEEN 1500
#define PROMOTIONS_FOR_EVERYONE 2000
#define AMBASSADORS_OF_DISCOVERY 3000
#define PRIDE_OF_SCIENCE 4000
#define NANOTRASEN_FINEST 5000


/datum/scoreboard
	/// Overall combined score for the whole round.
	var/crewscore = 0
	/// How many useful items have cargo shipped out?
	var/score_things_shipped = 0
	/// How many harvests have hydroponics done?
	var/score_things_harvested = 0
	/// How much ore has been mined on the mining z level?
	var/score_ore_mined = 0
	/// How much research was done by science?
	var/score_research_done = 0
	/// How many random events did the station survive?
	var/score_events_endured = 0
	/// How many APCs have poor charge?
	var/score_power_loss = 0
	/// How many people got out alive?
	var/score_escapees = 0
	/// How many people /didn't/ get out alive?
	var/score_dead_crew = 0
	/// How much blood, puke, stains etc went uncleaned?
	var/score_mess = 0
	/// How many meals were made?
	var/score_meals = 0
	/// How many rampant, uncured diseases are on board the station?
	var/score_disease = 0
	/// How many command members died? (Revolution)
	var/score_dead_command = 0
	/// How many antagonists are alive in the brig? (Nuke ops & Revolution)
	var/score_arrested = 0
	/// How many operatives were killed? (Nuke ops & Revolution)
	var/score_ops_killed = 0
	/// How much noms were had by the crew?
	var/score_food_eaten = 0
	/// How many times was the clown punched, struck, or otherwise maligned?
	var/score_clown_abuse = 0

	// Booleans //
	/// Were the antagonists successful?
	var/score_greentext = FALSE
	/// Did the crew catch all of the antags alive?
	var/all_arrested = FALSE
	/// Is the NAD safe and secure?
	var/disc_secure = FALSE

	// Points penalties/bonuses //
	/// If all APCs on the station are running optimally, big bonus.
	var/power_bonus = FALSE
	/// If there are no messes on the station anywhere, huge bonus.
	var/mess_bonus = FALSE
	/// If the AI is dead, big points penalty.
	var/dead_ai = FALSE
	/// Was the station blown into little bits?
	var/nuked = FALSE
	/// Points penalty for being blown to little bits.
	var/nuked_penalty = 0

	// Player Stats //
	/// What was the name of the richest person on the shuttle?
	var/richest_name = ""
	/// What was the ckey of the richest person on the shuttle?
	var/richest_key = ""
	/// What was the job of the richest person on the shuttle?
	var/richest_job = ""
	/// How much money did the richest person on the shuttle have?
	var/richest_cash = 0

	/// What was the name of the most injured person on the shuttle?
	var/damaged_name
	/// What was the ckey of the most injured person on the shuttle?
	var/damaged_key
	/// What was the job of the most injured person on the shuttle?
	var/damaged_job
	/// How damaged was the most injured person on the shuttle?
	var/damaged_health

	/// Associative list that contains information on all antagonists that went cryo. Used for logging.
	var/list/cryo_antags_info


/datum/scoreboard/proc/scoreboard()
	// Print a list of antagonists to the server log.
	log_antags()

	for(var/M in GLOB.mob_list)
		var/mob/mob = M
		if(is_station_level(mob.z))
			check_station_player(mob)
		else if(SSshuttle.emergency.mode >= SHUTTLE_ENDGAME && istype(get_area(mob), SSshuttle.emergency.areaInstance))
			check_shuttle_player(mob)

	check_apc_power()
	check_cleanables()

	generate_scoreboard()


/datum/scoreboard/proc/log_antags()
	var/list/total_antagonists = list()
	// Look into all mobs in the world, dead or alive
	for(var/M in SSticker.minds)
		var/datum/mind/mind = M
		var/role = mind.special_role

		// If they're an antagonist of some sort.
		if(role)
			if(total_antagonists[role]) // If the role exists already, add the name to it.
				total_antagonists[role] += ", [mind.name]([mind.key])"
			else // If the role doesn't exist in the list, create it and add the mob
				total_antagonists[role] += ": [mind.name]([mind.key])"

	// Now print them all into the log!
	log_game("Antagonists at round end were...")
	for(var/I in total_antagonists)
		log_game("[I]s[total_antagonists[I]].")

	// Log antags and their objectives
	for(var/datum/mind/antag in SSticker.minds)
		log_antag_objectives(antag)

	// Log antags that went cryo during the round (and their objectives)
	log_cryo_antags()


/datum/scoreboard/proc/log_cryo_antags()
	if(!cryo_antags_info || !length(cryo_antags_info))
		return

	var/list/total_antagonists = list()
	for(var/i in 1 to length(cryo_antags_info))
		var/antag = cryo_antags_info[i]
		var/role = cryo_antags_info[antag][1]

		if(total_antagonists[role])
			total_antagonists[role] += ", [antag]"
		else
			total_antagonists[role] += ": [antag]"

	log_game("Antagonists that went cryo were...")
	for(var/antag in total_antagonists)
		log_game("[antag]s[total_antagonists[antag]].")

	for(var/i in 1 to length(cryo_antags_info))
		var/antag = cryo_antags_info[i]
		var/role = cryo_antags_info[antag][1]

		if(length(cryo_antags_info[antag]) > 1)	// antag had objectives
			log_game("Start objective log for [antag]-[role]")
			for(var/objective in 2 to length(cryo_antags_info[antag]))
				log_game(cryo_antags_info[antag][objective])
			log_game("End objective log for [antag]-[role]")

	QDEL_LIST_ASSOC(cryo_antags_info)


/datum/scoreboard/proc/save_antag_info(datum/mind/antag_mind)
	if(!antag_mind || !SSticker?.score)
		return

	if(!cryo_antags_info)
		cryo_antags_info = list()

	var/current_index = "[html_decode(antag_mind.name)]([html_decode(antag_mind.key)])"
	cryo_antags_info[current_index] = list()
	cryo_antags_info[current_index] += "[html_decode(antag_mind.special_role)]"

	var/list/all_objectives = antag_mind.get_all_objectives()
	if(!length(all_objectives))
		return

	var/count = 1
	for(var/datum/objective/objective in all_objectives)
		cryo_antags_info[current_index] += "Objective #[count]: [objective.explanation_text]"
		count++


/datum/scoreboard/proc/check_station_player(mob/mob)
	if(!is_station_level(mob.z) || mob.stat < DEAD)
		return
	if(isAI(mob))
		dead_ai = TRUE
		score_dead_crew++
	else if(ishuman(mob))
		score_dead_crew++


/datum/scoreboard/proc/check_shuttle_player(mob/mob)
	if(!mob.mind || mob.stat == DEAD || !ishuman(mob))
		return
	var/mob/living/carbon/human/human = mob

	score_escapees++

	var/cash_score = get_score_container_worth(human)
	if(cash_score > richest_cash)
		richest_cash = cash_score
		richest_name = human.real_name
		richest_job = human.job
		richest_key = human.key

	var/damage_score = human.getBruteLoss() + human.getFireLoss() + human.getToxLoss() + human.getOxyLoss()
	if(damage_score > damaged_health)
		damaged_health = damage_score
		damaged_name = human.real_name
		damaged_job = human.job
		damaged_key = human.key


/datum/scoreboard/proc/check_apc_power()
	for(var/A in GLOB.apcs)
		var/obj/machinery/power/apc/apc = A
		if(!is_station_level(apc.z))
			continue
		var/obj/item/stock_parts/cell/cell = apc.cell
		if(!cell?.charge < 2300)
			score_power_loss++ //200 charge leeway


/datum/scoreboard/proc/check_cleanables()
	for(var/obj/effect/decal/cleanable/decal in world)
		if(!is_station_level(decal.z))
			continue
		if(istype(decal, /obj/effect/decal/cleanable/blood/gibs))
			score_mess += 3
		else if(istype(decal, /obj/effect/decal/cleanable/blood))
			score_mess += 1
		else if(istype(decal, /obj/effect/decal/cleanable/vomit))
			score_mess += 1


/datum/scoreboard/proc/generate_scoreboard()
	// Point modifiers
	var/points_events_endured = score_events_endured	 * 50
	var/points_research_done = score_research_done		 * 30
	var/points_disease = score_disease					 * 30
	var/points_dead_crew = score_dead_crew				 * 25
	var/points_escapees = score_escapees				 * 25
	var/points_power_loss = score_power_loss			 * 20
	var/points_things_harvested = score_things_harvested * 5
	var/points_things_shipped = score_things_shipped	 * 5
	var/points_meals = score_meals						 * 5
	var/points_ore_mined = score_ore_mined				 * 2

	// Bonuses
	crewscore += points_events_endured
	crewscore += points_research_done
	crewscore += points_escapees
	crewscore += points_things_harvested
	crewscore += points_things_shipped
	crewscore += points_meals
	crewscore += points_ore_mined

	if(!score_power_loss)
		crewscore += 2500
		power_bonus = TRUE

	if(!score_mess)
		crewscore += 1500
		mess_bonus = TRUE

	if(all_arrested) // This only seems to be implemented for Rev and Nukies. -DaveKorhal
		crewscore *= 3 // This needs to be here for the bonus to be applied properly

	// Penalties
	crewscore -= points_dead_crew
	crewscore -= points_power_loss
	crewscore -= points_disease
	crewscore -= score_mess

	if(dead_ai)
		crewscore -= 250

	// Generate the score panel
	var/dat = {"<head><title>Итоги смены №[GLOB.round_id]</title><meta charset='UTF-8'></head>"}
	if(SSticker.mode)
		dat += SSticker.mode.get_scoreboard_stats()

	dat += {"
	<b><u>Общая статистика</u></b><br>
	<u>Хорошее</u><br>
	<b>Добыто руды:</b> [score_ore_mined] ([points_ore_mined] [declension_ru(points_ore_mined, "очко", "очка", "очков")])<br>"}

	if(score_escapees)
		dat += "<b>Эвакуировалось на шаттле:</b> [score_escapees] ([points_escapees] очков)<br>"

	dat += "<b>Есть электропитание на всей станции:</b> [power_bonus ? "Да" : "Нет"] ([power_bonus * 2500] очков)<br>"
	dat += "<b>Вся станция в чистоте и порядке:</b> [mess_bonus ? "Да" : "Нет"] ([mess_bonus * 1500] очков)<br><br>"

	dat += "<U>Плохое</U><br>"
	dat += "<b>Трупов на станции:</b> [score_dead_crew] (-[points_dead_crew] очков)<br>"
	if(!mess_bonus)
		dat += "<b>Неприбранная грязь:</b> [score_mess] (-[score_mess] [declension_ru(score_mess, "очко", "очка", "очков")])<br>"
	if(!power_bonus)
		dat += "<b>Проблемы с питанием на станции:</b> [score_power_loss] (-[points_power_loss] очков)<br>"
	dat += {"
	<b>ИИ уничтожен:</b> [dead_ai ? "Да" : "Нет"] (-[dead_ai * 250] очков)<br><br>

	<U>Прочее</U><br>
	<b>Съедено еды:</b> [score_food_eaten] [declension_ru(score_food_eaten, "укус", "укуса", "укусов")]/[declension_ru(score_food_eaten, "глоток", "глотка", "глотков")].<br>
	<b>Клоуна избили:</b> [score_clown_abuse] [declension_ru(score_clown_abuse, "раз", "раза", "раз")]<br><br>"}

	if(score_escapees)
		dat += "<b>Самый богатый из эвакуировавшихся:</b> [richest_name], [richest_job]: $[num2text(richest_cash, 50)] ([richest_key])<br>"
		if(damaged_health)
			dat += "<b>Самый потрёпанный из эвакуировавшихся:</b> [damaged_name], [damaged_job]: [damaged_health] урона ([damaged_key])<br>"
	else
		if(SSshuttle.emergency.mode <= SHUTTLE_STRANDED)
			dat += "Станция не была эвакуирована!<br>"
		else
			dat += "Никто не выжил!<br>"

	dat += SSticker.mode.declare_job_completion()
	dat += SSticker.mode.declare_ambition_completion()

	dat += {"
	<hr><br>
	<b><u>ИТОГОВЫЙ РЕЗУЛЬТАТ: [crewscore]</u></b><br>
	"}

	var/score_rating = "Аристократы!"
	switch(crewscore)
		if(-INFINITY to SINGULARITY_DESERVES_BETTER) score_rating = 				"Даже после выхода Сингулярности было бы лучше"
		if(SINGULARITY_DESERVES_BETTER+1 to SINGULARITY_FODDER) score_rating = 		"Вами только Сингулярность кормить"
		if(SINGULARITY_FODDER+1 to ALL_FIRED) score_rating = 						"Вы все уволены"
		if(ALL_FIRED+1 to WASTE_OF_OXYGEN) score_rating = 							"На вас без толку был потрачен отличный кислород"
		if(WASTE_OF_OXYGEN+1 to HEAP_OF_SCUM) score_rating = 						"Жалкое сборище недотёп и неудачников"
		if(HEAP_OF_SCUM+1 to LAB_MONKEYS) score_rating = 							"Лабораторные мартышки вас превзошли"
		if(LAB_MONKEYS+1 to UNDESIREABLES) score_rating = 							"Неудовлетворительно"
		if(UNDESIREABLES+1 to SERVANTS_OF_SCIENCE-1) score_rating = 				"Амбивалентно средне"
		if(SERVANTS_OF_SCIENCE to GOOD_BUNCH-1) score_rating = 						"Умелые научные ассистенты"
		if(GOOD_BUNCH to MACHINE_THIRTEEN-1) score_rating = 						"Лучшие из довольно компетентных"
		if(MACHINE_THIRTEEN to PROMOTIONS_FOR_EVERYONE-1) score_rating = 			"Образцовый экипаж"
		if(PROMOTIONS_FOR_EVERYONE to AMBASSADORS_OF_DISCOVERY-1) score_rating = 	"Всем — премия!"
		if(AMBASSADORS_OF_DISCOVERY to PRIDE_OF_SCIENCE-1) score_rating = 			"Пионеры новых открытий"
		if(PRIDE_OF_SCIENCE to NANOTRASEN_FINEST-1) score_rating = 					"Гордость науки во плоти"
		if(NANOTRASEN_FINEST to INFINITY) score_rating = 							"Лучшие кадры НаноТрейзен"

	dat += "<b><u>РЕЙТИНГ:</u></b> [score_rating]"
	GLOB.scoreboard = jointext(dat, "")

	for(var/mob/mob in GLOB.player_list)
		if(mob.client)
			to_chat(mob, "<b>Итоговый результат экипажа:</b>")
			to_chat(mob, "<b><font size='4'><a href='?src=[mob.UID()];scoreboard=1'>[crewscore]</a></font></b>")
			if(!mob.get_preference(PREFTOGGLE_DISABLE_SCOREBOARD))
				mob << browse(GLOB.scoreboard, "window=roundstats;size=700x900")


/**
 * A recursive function to properly determine the wealthiest escapee
 */
/datum/scoreboard/proc/get_score_container_worth(atom/C, level=0)
	if(level >= 5)
		// in case the containers recurse or something
		return 0
	else
		. = 0
		for(var/obj/item/card/id/id in C.contents)
			var/datum/money_account/A = get_money_account(id.associated_account_number)
			// has an account?
			if(A)
				. += A.money
		for(var/obj/item/stack/spacecash/cash in C.contents)
			. += cash.amount
		for(var/obj/item/storage/S in C.contents)
			. += .(S, level + 1)


/datum/game_mode/proc/get_scoreboard_stats()
	return null


/datum/game_mode/proc/set_scoreboard_vars()
	return null


#undef SINGULARITY_DESERVES_BETTER
#undef SINGULARITY_FODDER
#undef ALL_FIRED
#undef WASTE_OF_OXYGEN
#undef HEAP_OF_SCUM
#undef LAB_MONKEYS
#undef UNDESIREABLES
#undef SERVANTS_OF_SCIENCE
#undef GOOD_BUNCH
#undef MACHINE_THIRTEEN
#undef PROMOTIONS_FOR_EVERYONE
#undef AMBASSADORS_OF_DISCOVERY
#undef PRIDE_OF_SCIENCE
#undef NANOTRASEN_FINEST
