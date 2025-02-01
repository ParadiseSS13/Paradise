/datum/objective/is_invalid_target(datum/mind/possible_target)
	. = ..()
	if(.)
		return
	if(team)
		for(var/datum/antagonist/target_datum in possible_target.antag_datums)
			if(team == target_datum.get_team())
				return TARGET_INVALID_SAME_TEAM

/datum/objective/raider_steal
	name = "Raider theft"
	needs_target = FALSE
	/// Сколько ценностей надо украсть
	var/precious_amount = 30
	/// На сколько ценность должна быть "цена" чтобы её засчитать
	var/precious_value = 200
	/// Сколько нужно украсть дополнительных ценностей в зависимости от количества людей в игре
	var/dynamic_amount = 10
	/// Каждый X игроков добавляем доп. число ценностей
	var/dynamic_player = 15

/datum/objective/raider_steal/update_explanation_text()
	explanation_text = "Соберите [precious_amount] ценностей, у каждой из которых цена минимум на [precious_value] кикиридитов. Все ценности должны быть приняты Расчичетчикиком."

/datum/objective/raider_steal/New(text, datum/team/team_to_join)
	. = ..()
	generate_amount_goal()

/datum/objective/raider_steal/proc/generate_amount_goal()
	var/num = 1
	for(var/mob/new_player/P in GLOB.player_list)
		if(P.client && P.ready)
			num++
	precious_amount += round((num / dynamic_player) * dynamic_amount)
	update_explanation_text()
	return precious_amount

/datum/objective/raider_steal/check_completion()
	var/list_count = 0
	var/obj/machinery/vox_trader/trader = locate() in GLOB.machines
	if(!trader)
		return
	trader.synchronize_traders_stats()
	for(var/I in trader.precious_collected_dict)
		list_count += trader.precious_collected_dict[I]["count"]
	if(list_count >= precious_amount)
		return TRUE
	return FALSE

/datum/objective/raider_entirety_steal
	name = "Raider entirety theft"
	needs_target = FALSE
	/// Общая сумма ценностей
	var/precious_value = 50000
	/// Сколько нужно украсть дополнительных ценностей на каждого игрока
	var/dynamic_value = 750

/datum/objective/raider_entirety_steal/update_explanation_text()
	explanation_text = "Соберите ценностей на сумму [precious_value]. Все ценности должны быть приняты Расчичетчикиком."

/datum/objective/raider_entirety_steal/New(text, datum/team/team_to_join)
	. = ..()
	generate_value_goal()

/datum/objective/raider_entirety_steal/proc/generate_value_goal()
	var/num = 1
	var/precious_amount
	for(var/mob/new_player/P in GLOB.player_list)
		if(P.client && P.ready)
			num++
	precious_amount += num * dynamic_value
	update_explanation_text()
	return precious_amount

/datum/objective/raider_entirety_steal/check_completion()
	var/value_sum = 0
	for(var/obj/machinery/vox_trader/trader in GLOB.machines)
		value_sum += trader.all_values_sum
	if(value_sum >= precious_value)
		return TRUE
	return FALSE


/datum/objective/raider_collection_access
	name = "Raider access collect"
	needs_target = FALSE
	/// Сколько доступов надо украсть
	var/access_amount

/datum/objective/raider_collection_access/update_explanation_text()
	explanation_text = "Соберите [access_amount] уникальных доступов. Все доступы должны быть приняты Расчичетчикиком."

/datum/objective/raider_collection_access/New(text, datum/team/team_to_join)
	. = ..()
	access_amount = length(get_all_accesses())
	update_explanation_text()

/datum/objective/raider_collection_access/check_completion()
	for(var/obj/machinery/vox_trader/trader in GLOB.machines)
		if(length(trader.collected_access_list) >= access_amount)
			return TRUE
	return FALSE


/datum/objective/raider_collection_tech
	name = "Raider technology collect"
	needs_target = FALSE
	var/tech_amount	= 9 // Всего в игре технологий (12): 9 обычных, 1 комбат, 1 нелегал, 1 абдуктор.
	var/tech_min_level = 7 // 7-8 - максимум для обычных технологий, не считая гейтов и т.п.

/datum/objective/raider_collection_tech/update_explanation_text()
	explanation_text = "Соберите [tech_amount] уникальных технологий [tech_min_level] или больше уровня. Все технологии должны быть приняты Расчичетчикиком."

/datum/objective/raider_collection_tech/New(text, datum/team/team_to_join)
	. = ..()
	update_explanation_text()

/datum/objective/raider_collection_tech/check_completion()
	for(var/obj/machinery/vox_trader/trader in GLOB.machines)
		if(length(trader.collected_tech_dict))
			var/count = 0
			for(var/tech in trader.collected_tech_dict)
				if(trader.collected_tech_dict[tech] >= tech_min_level)
					count++
			if(count >= tech_amount)
				return TRUE
	return FALSE

