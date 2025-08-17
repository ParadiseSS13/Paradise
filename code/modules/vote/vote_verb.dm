/client/verb/vote()
	set category = "OOC"
	set name = "Vote"

	if(SSvote.active_vote)
		SSvote.active_vote.ui_interact(usr)
	else
		to_chat(usr, "Нет активных голосований")

/client/proc/start_vote()
	set category = "Admin"
	set name = "Начать голосование"
	set desc = "Начать голосование на сервере"

	if(!check_rights(R_ADMIN))
		return

	if(SSvote.active_vote)
		to_chat(usr, "Голосование уже в процессе")
		return

	// Ask admins which type of vote they want to start
	var/vote_types = subtypesof(/datum/vote)
	vote_types |= "\[CUSTOM]"

	// This needs to be a map to instance it properly. I do hate it as well, dont worry.
	var/list/votemap = list()
	for(var/vtype in vote_types)
		votemap["[vtype]"] = vtype

	var/choice = tgui_input_list(usr, "Выбрать тип голосования", "Голосование", vote_types)

	if(choice == null)
		return

	if(choice != "\[CUSTOM]")
		// Not custom, figure it out
		var/datum/vote/votetype = votemap["[choice]"]
		SSvote.start_vote(new votetype(usr.ckey))
		return

	// Its custom, lets ask
	var/question = tgui_input_text(usr, "За что голосуем?", "Create Vote", encode = FALSE)
	if(isnull(question))
		return

	var/list/choices = list()
	for(var/i in 1 to 10)
		var/option = tgui_input_text(usr, "Впишите опцию или нажмите отмену для завершения", "Create Vote", encode = FALSE)
		if(isnull(option) || !usr.client)
			break
		choices |= option

	var/c2 = tgui_alert(usr, "Показать подсчеты во время голосования?", "Голоса", list("Да", "Нет"))
	var/c3 = input(usr, "Выберите тип расчета результата", "Голосование", VOTE_RESULT_TYPE_MAJORITY) as anything in list(VOTE_RESULT_TYPE_MAJORITY)

	var/datum/vote/V = new /datum/vote(usr.ckey, question, choices, TRUE)
	V.show_counts = (c2 == "Yes")
	V.vote_result_type = c3
	SSvote.start_vote(V)

