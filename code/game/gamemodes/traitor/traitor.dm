/datum/game_mode
	// this includes admin-appointed traitors and multitraitors. Easy!
	var/list/datum/mind/traitors = list()
	var/list/datum/mind/implanter = list()
	var/list/datum/mind/implanted = list()

	var/datum/mind/exchange_red
	var/datum/mind/exchange_blue

/datum/game_mode/traitor
	name = "traitor"
	config_tag = "traitor"
	restricted_jobs = list("Cyborg")//They are part of the AI if he is traitor so are they, they use to get double chances
	protected_jobs = list("Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Blueshield", "Nanotrasen Representative", "Security Pod Pilot", "Magistrate", "Internal Affairs Agent", "Brig Physician", "Nanotrasen Navy Officer", "Special Operations Officer", "Syndicate Officer")
	required_players = 0
	required_enemies = 1
	recommended_enemies = 4

	var/list/datum/mind/pre_traitors = list()
	var/traitors_possible = 4 //hard limit on traitors if scaling is turned off
	var/const/traitor_scaling_coeff = 5.0 //how much does the amount of players get divided by to determine traitors
	var/antag_datum = /datum/antagonist/traitor //what type of antag to create

/datum/game_mode/traitor/announce()
	to_chat(world, "<B>The current game mode is - Traitor!</B>")
	to_chat(world, "<B>There is a syndicate traitor on the station. Do not let the traitor succeed!</B>")


/datum/game_mode/traitor/pre_setup()

	if(config.protect_roles_from_antagonist)
		restricted_jobs += protected_jobs

	var/list/possible_traitors = get_players_for_role(ROLE_TRAITOR)

	// stop setup if no possible traitors
	if(!possible_traitors.len)
		return 0

	var/num_traitors = 1

	if(config.traitor_scaling)
		num_traitors = max(1, round((num_players())/(traitor_scaling_coeff)))
	else
		num_traitors = max(1, min(num_players(), traitors_possible))

	for(var/j = 0, j < num_traitors, j++)
		if(!possible_traitors.len)
			break
		var/datum/mind/traitor = pick(possible_traitors)
		pre_traitors += traitor
		traitor.special_role = SPECIAL_ROLE_TRAITOR
		traitor.restricted_roles = restricted_jobs
		possible_traitors.Remove(traitor)

	if(!pre_traitors.len)
		return 0
	return 1


/datum/game_mode/traitor/post_setup()
	for(var/datum/mind/traitor in pre_traitors)
		var/datum/antagonist/traitor/new_antag = new antag_datum()
		addtimer(CALLBACK(traitor, /datum/mind.proc/add_antag_datum, new_antag), rand(10,100))
	if(!exchange_blue)
		exchange_blue = -1 //Block latejoiners from getting exchange objectives
	..()


/datum/game_mode/traitor/declare_completion()
	..()
	return//Traitors will be checked as part of check_extra_completion. Leaving this here as a reminder.

/datum/game_mode/traitor/process()
	// Make sure all objectives are processed regularly, so that objectives
	// which can be checked mid-round are checked mid-round.
	for(var/datum/mind/traitor_mind in traitors)
		for(var/datum/objective/objective in traitor_mind.objectives)
			objective.check_completion()
	return 0


/datum/game_mode/proc/auto_declare_completion_traitor()
	if(traitors.len)
		var/text = "<FONT size = 2><B>The traitors were:</B></FONT>"
		for(var/datum/mind/traitor in traitors)
			var/traitorwin = 1

			text += "<br>[traitor.key] was [traitor.name] ("
			if(traitor.current)
				if(traitor.current.stat == DEAD)
					text += "died"
				else
					text += "survived"
				if(traitor.current.real_name != traitor.name)
					text += " as [traitor.current.real_name]"
			else
				text += "body destroyed"
			text += ")"


			var/TC_uses = 0
			var/uplink_true = 0
			var/purchases = ""
			for(var/obj/item/uplink/H in world_uplinks)
				if(H && H.uplink_owner && H.uplink_owner==traitor.key)
					TC_uses += H.used_TC
					uplink_true=1
					purchases += H.purchase_log

			if(uplink_true) text += " (used [TC_uses] TC) [purchases]"


			if(traitor.objectives && traitor.objectives.len)//If the traitor had no objectives, don't need to process this.
				var/count = 1
				for(var/datum/objective/objective in traitor.objectives)
					if(objective.check_completion())
						text += "<br><B>Objective #[count]</B>: [objective.explanation_text] <font color='green'><B>Success!</B></font>"
						feedback_add_details("traitor_objective","[objective.type]|SUCCESS")
					else
						text += "<br><B>Objective #[count]</B>: [objective.explanation_text] <font color='red'>Fail.</font>"
						feedback_add_details("traitor_objective","[objective.type]|FAIL")
						traitorwin = 0
					count++

			var/special_role_text
			if(traitor.special_role)
				special_role_text = lowertext(traitor.special_role)
			else
				special_role_text = "antagonist"


			if(traitorwin)
				text += "<br><font color='green'><B>The [special_role_text] was successful!</B></font>"
				feedback_add_details("traitor_success","SUCCESS")
			else
				text += "<br><font color='red'><B>The [special_role_text] has failed!</B></font>"
				feedback_add_details("traitor_success","FAIL")

		var/phrases = jointext(GLOB.syndicate_code_phrase, ", ")
		var/responses = jointext(GLOB.syndicate_code_response, ", ")

		text += "<br><br><b>The code phrases were:</b> <span class='danger'>[phrases]</span><br>\
					<b>The code responses were:</b> <span class='danger'>[responses]</span><br><br>"

		to_chat(world, text)
	return 1
