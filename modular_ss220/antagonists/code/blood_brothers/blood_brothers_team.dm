/datum/team/proc/get_member_ckeys()
	var/list/member_ckeys = list()
	for(var/datum/mind/member as anything in members)
		if(!member.current)
			continue

		member_ckeys += member.current.ckey

	return member_ckeys


/datum/team/blood_brothers_team
	name = "Blood Brothers"
	antag_datum_type = /datum/antagonist/blood_brother
	/// Amount of objectives to give
	var/objectives_amount = 2
	/// Probability of hijack objective in percent
	var/hijack_probability = 2
	/// Selected meeting area given to the team members
	var/meeting_area = "Согласованная локация"
	/// List of meeting areas that are randomly selected.
	var/static/meeting_areas = list(
		"Бар",
		"Дормы",
		"Док отбытия",
		"Док прибытия",
		"Голодек",
		"Ассистентская",
		"Храм",
		"Библиотека",
	)
	/// List of objective_path -> weight
	var/static/list/available_objectives = list(
		/datum/objective/maroon = 1,
		/datum/objective/assassinate = 1,
		/datum/objective/assassinateonce = 1,
		/datum/objective/debrain = 1,
		/datum/objective/steal = 1,
		/datum/objective/protect = 1
	)

/datum/team/blood_brothers_team/New(list/starting_members, add_antag_datum)
	. = ..()
	pick_meeting_area()
	forge_objectives()

/datum/team/blood_brothers_team/handle_adding_member(datum/mind/new_member)
	. = ..()
	update_brother_name()

/datum/team/blood_brothers_team/handle_removing_member(datum/mind/member, force)
	. = ..()
	update_brother_name()

/datum/team/blood_brothers_team/proc/get_brother_names_text(datum/mind/brother_to_exclude)
	var/list/brother_names = list()
	for(var/datum/mind/brother as anything in members)
		if(brother == brother_to_exclude)
			continue

		brother_names += brother.name

	return brother_names.Join(", ")

/datum/team/blood_brothers_team/proc/pick_meeting_area()
	PRIVATE_PROC(TRUE)
	var/chosen_meeting_area = pick(meeting_areas)
	if(istext(chosen_meeting_area))
		meeting_area = chosen_meeting_area

/datum/team/blood_brothers_team/proc/update_brother_name()
	PRIVATE_PROC(TRUE)
	var/new_name = get_brother_names_text()
	if(!new_name)
		name = initial(name)
		return

	name = "[initial(name)] of [new_name]"

/datum/team/blood_brothers_team/proc/forge_objectives()
	PRIVATE_PROC(TRUE)
	var/is_hijacker = prob(hijack_probability)
	for(var/i in 1 to (objectives_amount - is_hijacker))
		forge_single_objective()

	if(is_hijacker)
		add_team_objective(new /datum/objective/hijack)
	else
		add_team_objective(new /datum/objective/escape(
		{"Сбегите на шаттле или спасательной капсуле вместе с братьями.
		Вы должны быть живы и свободны(Не находиться в бриге шаттла и не быть закованными в наручники).
		Если хотя бы один из вас не удовлетворяет условиям - задание будет провалено для всех!
		"}))

/datum/team/blood_brothers_team/proc/forge_single_objective()
	PRIVATE_PROC(TRUE)
	if(prob(10) && length(active_ais()))
		add_team_objective(new /datum/objective/destroy)
	else
		var/datum/objective/objective_path = pickweight(available_objectives)
		if(!ispath(objective_path))
			error("Wrong objective path in 'available_objectives' of '[type]'")
			return

		add_team_objective(new objective_path())
