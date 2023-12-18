// FOR THE LOVE OF GOD PLACE THIS FILE IN THE RIGHT PLACE WHEN I'M NOT LAZY ENOUGH TO PROPERLY DO IT
// Yes this is copypasted from Vampire gamemode

/datum/game_mode
	/// The list of all the mindflayers
	var/list/datum/mind/mindflayers = list()

/datum/game_mode/mindflayer
	name = "mindflayer"
	config_tag = "mindflayer"
	restricted_jobs = list("AI", "Cyborg")
	protected_jobs = list("Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Blueshield", "Nanotrasen Representative", "Magistrate", "Chaplain", "Internal Affairs Agent", "Nanotrasen Navy Officer", "Special Operations Officer", "Syndicate Officer", "Solar Federation General")
//	protected_species = list("Machine") // lol, lmao
	required_players = 15
	required_enemies = 1
	recommended_enemies = 4
	///list of minds of soon to be mindflayers
	var/list/datum/mind/pre_mindflayers = list()

/datum/game_mode/mindflayer/announce()
	to_chat(world, "<b>The current game mode is - mindflayers!</b>")
	to_chat(world, "<b>There are Bluespace mindflayers infesting your fellow crewmates, keep your blood close and neck safe!</b>")

/datum/game_mode/mindflayer/pre_setup()

	if(GLOB.configuration.gamemode.prevent_mindshield_antags)
		restricted_jobs += protected_jobs

	var/list/datum/mind/possible_mindflayers = get_players_for_role(ROLE_MIND_FLAYER)

	var/mindflayer_amount = 1 + round(num_players() / 10)

	if(length(possible_mindflayers))
		for(var/i in 1 to mindflayer_amount)
			if(!length(possible_mindflayers))
				break
			var/datum/mind/mindflayer = pick_n_take(possible_mindflayers)
			pre_mindflayers += mindflayer
			mindflayer.special_role = SPECIAL_ROLE_MIND_FLAYER
			mindflayer.restricted_roles = restricted_jobs

		..()
		return TRUE
	else
		return FALSE

/datum/game_mode/mindflayer/post_setup()
	for(var/datum/mind/mindflayer in pre_mindflayers)
		mindflayer.add_antag_datum(/datum/antagonist/mindflayer)
	..()

/datum/game_mode/proc/auto_declare_completion_mindflayer()
	if(!length(mindflayers))
		return

	var/text = "<font size='2'><b>The mindflayers were:</b></font>"
	for(var/datum/mind/mindflayer in mindflayers)
		var/traitorwin = TRUE
//		var/datum/antagonist/mindflayer/flayer = mindflayer.has_antag_datum(/datum/antagonist/mindflayer) // Why was this commented out again?
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
	to_chat(world, text)
	return TRUE

