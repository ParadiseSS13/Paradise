/datum/job_selector/assign_role(datum/job_candidate/candidate, datum/job/job, latejoin = FALSE, step = "unknown_step")
	. = ..()
	if(!.)
		return

	log_game("Игрок [candidate.get_ckey()] вошел в раунд с профессией [job.title] ([job.current_positions]/[job.total_positions])")

/datum/mind/proc/log_antag_objectives()
	var/list/objectives = get_all_objectives()
	if(length(objectives))
		log_game("GAME: Start objective log for [html_decode(key)]/[html_decode(name)]")
		var/count = 1
		for(var/datum/objective/objective in objectives)
			log_game("GAME: Objective #[count]: [objective.explanation_text]")
			count++
		log_game("GAME: End objective log for [html_decode(key)]/[html_decode(name)]")

/datum/scoreboard/log_antags()
	. = ..()
	for(var/mind in SSticker.minds)
		var/datum/mind/M = mind
		var/role = M.special_role
		if(role)
			M.log_antag_objectives()
