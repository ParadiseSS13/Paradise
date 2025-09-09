//Used to hold any procs related to how mindflayers are handled from a gamemode perspective
/datum/game_mode/proc/auto_declare_completion_mindflayer()
	if(!length(mindflayers))
		return

	var/list/text = list("<br><font size=3><span class='bold'>The mindflayers were:</span></font>")
	for(var/datum/mind/mindflayer in mindflayers)
		var/traitorwin = TRUE
		text += "<br>[mindflayer.get_display_key()] was [mindflayer.name] and "
		if(mindflayer.current)
			if(mindflayer.current.stat == DEAD)
				text += "<span class='bold'>died!</span>"
			else
				text += "<span class='bold'>survived!</span>"
		else
			text += "<span class='bold'>had [mindflayer.p_their()] body destroyed</span>!"

		var/list/all_objectives = mindflayer.get_all_objectives()

		if(length(all_objectives))//If the traitor had no objectives, don't need to process this.
			var/count = 1
			for(var/datum/objective/objective in all_objectives)
				text += "<br><b>Objective #[count]</b>: [objective.explanation_text]"
				if(objective.check_completion())
					if(istype(objective, /datum/objective/steal))
						var/datum/objective/steal/S = objective
						SSblackbox.record_feedback("nested tally", "mindflayer_steal_objective", 1, list("Steal [S.steal_target]", "SUCCESS"))
					else
						SSblackbox.record_feedback("nested tally", "mindflayer_objective", 1, list("[objective.type]", "SUCCESS"))
				else
					if(istype(objective, /datum/objective/steal))
						var/datum/objective/steal/S = objective
						SSblackbox.record_feedback("nested tally", "mindflayer_steal_objective", 1, list("Steal [S.steal_target]", "FAIL"))
					else
						SSblackbox.record_feedback("nested tally", "mindflayer_objective", 1, list("[objective.type]", "FAIL"))
					traitorwin = FALSE
				count++

		if(traitorwin)
			SSblackbox.record_feedback("tally", "mindflayer_success", 1, "SUCCESS")
		else
			SSblackbox.record_feedback("tally", "mindflayer_success", 1, "FAIL")

	return text.Join("")

