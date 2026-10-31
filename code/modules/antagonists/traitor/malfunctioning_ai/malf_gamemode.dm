/datum/game_mode/proc/auto_declare_completion_malf()
	if(!length(malf_ais))
		return

	var/list/text = list("<br><font size=3>[SPAN_BOLD("The Malfunctioning AIs were:")]</font>")
	for(var/datum/mind/malf in malf_ais)
		var/malf_win = TRUE
		text += "<br>[malf.get_display_key()] was [malf.name] and "
		if(malf.current)
			if(malf.current.stat == DEAD)
				text += "[SPAN_BOLD("died")]!"
			else
				text += SPAN_BOLD("survived!")
			if(malf.current.real_name != malf.name)
				text += " as [malf.current.real_name]"
			else
				text += "!"
		else
			text += SPAN_BOLD("had [malf.p_their()] body destroyed!")

		var/list/all_objectives = malf.get_all_objectives(include_team = FALSE)
		if(length(all_objectives))
			var/count = 1
			for(var/datum/objective/objective in all_objectives)
				text += "<br><b>Objective #[count]</b>: [objective.explanation_text]"
				if(objective.check_completion())
					SSblackbox.record_feedback("nested tally", "malf_objective", 1, list("[objective.type]", "SUCCESS"))
				else
					SSblackbox.record_feedback("nested tally", "malf_objective", 1, list("[objective.type]", "FAIL"))
					malf_win = FALSE
				count++
		if(malf_win)
			SSblackbox.record_feedback("tally", "malf_success", 1, "SUCCESS")
		else
			SSblackbox.record_feedback("tally", "malf_success", 1, "FAIL")
	return text.Join("")
