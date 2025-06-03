//Used to hold any procs related to how mindflayers are handled from a gamemode perspective
/datum/game_mode/proc/auto_declare_completion_mindflayer()
	if(!length(mindflayers))
		return

	var/list/text = list("<font size='2'><b>The mindflayers were:</b></font>")
	for(var/datum/mind/mindflayer in mindflayers)
		var/traitorwin = TRUE
		text += "<br>[mindflayer.get_display_key()] was [mindflayer.name] ("
		if(mindflayer.current)
			if(mindflayer.current.stat == DEAD)
				text += "died"
			else
				text += "survived"
		else
			text += "body destroyed"
		text += ")"

		var/list/all_objectives = mindflayer.get_all_objectives()

		if(length(all_objectives))//If the traitor had no objectives, don't need to process this.
			var/count = 1
			for(var/datum/objective/objective in all_objectives)
				if(objective.check_completion())
					text += "<br><b>Objective #[count]</b>: [objective.explanation_text] <font color='green'><b>Success!</b></font>"
					if(istype(objective, /datum/objective/steal))
						var/datum/objective/steal/S = objective
						SSblackbox.record_feedback("nested tally", "mindflayer_steal_objective", 1, list("Steal [S.steal_target]", "SUCCESS"))
					else
						SSblackbox.record_feedback("nested tally", "mindflayer_objective", 1, list("[objective.type]", "SUCCESS"))
				else
					text += "<br><b>Objective #[count]</b>: [objective.explanation_text] <font color='red'>Fail.</font>"
					if(istype(objective, /datum/objective/steal))
						var/datum/objective/steal/S = objective
						SSblackbox.record_feedback("nested tally", "mindflayer_steal_objective", 1, list("Steal [S.steal_target]", "FAIL"))
					else
						SSblackbox.record_feedback("nested tally", "mindflayer_objective", 1, list("[objective.type]", "FAIL"))
					traitorwin = FALSE
				count++

		var/special_role_text
		if(mindflayer.special_role)
			special_role_text = lowertext(mindflayer.special_role)
		else
			special_role_text = "antagonist"

		if(traitorwin)
			text += "<br><font color='green'><b>The [special_role_text] was successful!</b></font>"
			SSblackbox.record_feedback("tally", "mindflayer_success", 1, "SUCCESS")
		else
			text += "<br><font color='red'><b>The [special_role_text] has failed!</b></font>"
			SSblackbox.record_feedback("tally", "mindflayer_success", 1, "FAIL")

	return text.Join("")

