/datum/team/vox_raiders
	name = "Vox Raiders"
	antag_datum_type = /datum/antagonist/vox_raider

/datum/team/vox_raiders/New(list/starting_members, add_antag_datum)
	. = ..()
	forge_objectives()

/datum/team/vox_raiders/proc/forge_objectives()
	PRIVATE_PROC(TRUE)
	// Основная цель
	add_team_objective(new /datum/objective/raider_steal())
	//Коллекционная цель
	var/list/possible_collect_objective_types = list(
		/datum/objective/raider_entirety_steal,
		/datum/objective/raider_collection_access,
		/datum/objective/raider_collection_tech
		)
	var/picked_collect_objective_type = pick(possible_collect_objective_types)
	add_team_objective(new picked_collect_objective_type())
	// Конечная цель
	add_team_objective(new /datum/objective/survive(
	{"Не допустите гибели вас и остальных Воксов из команды. Избегайте смерти влекущие за собой расходы стае."}))

/datum/team/vox_raiders/handle_adding_member(datum/mind/new_member)
	. = ..()
	update_reider_name()

/datum/team/vox_raiders/handle_removing_member(datum/mind/member, force = FALSE)
	. = ..()
	update_reider_name()

/datum/team/vox_raiders/proc/update_reider_name()
	PRIVATE_PROC(TRUE)
	var/new_name = get_raider_names_text()
	if(!new_name)
		name = initial(name)
		return

	name = "[initial(name)] of [new_name]"

/datum/team/vox_raiders/proc/get_raider_names_text(datum/mind/raider_to_exclude)
	var/list/raider_names = list()
	for(var/datum/mind/raider as anything in members)
		if(raider == raider_to_exclude)
			continue

		raider_names += raider.name

	return raider_names.Join(", ")

/datum/team/vox_raiders/on_round_end()
	. = ..()
	var/list/to_send = list()
	for(var/datum/team/vox_raiders/team in GLOB.antagonist_teams)
		if(!objective_holder)
			continue
		var/teamwin = 1
		to_send += "<br><b>Стая [name]</b>"
		for(var/datum/objective/objective in objective_holder.objectives)
			if(!objective.check_completion())
				teamwin = 0
		if(teamwin)
			to_send += "<br><font color='green'><B>Стая успешно завершила свои цели!</B></font>"
		else
			to_send += "<br><font color='red'><B>Стая провалилась!</B></font>"
		var/num_survive = length(members)
		for(var/datum/mind/mind in members)
			if(!mind.current || mind.current.stat==DEAD)
				num_survive--
		if(num_survive == length(members))
			to_send += "<br><font color='green'><B>Вся стая выжила!</B></font>"
		else if(num_survive <= 0)
			to_send += "<br><font color='red'><B>Вся стая погибла!</B></font>"
		else
			to_send += "<br><font color='orange'><B>У стаи есть потери!</B></font>"
	if(!length(to_send))
		return
	to_chat(world, to_send.Join("<br>"))
