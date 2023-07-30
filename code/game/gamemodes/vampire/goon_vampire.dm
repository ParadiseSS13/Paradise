/**
 * This is the gamemode file for the ported goon gamemode vampires.
 * They get a traitor objective and a blood sucking objective.
 */
/datum/game_mode
	var/list/datum/mind/goon_vampires = list()
	var/list/datum/mind/goon_vampire_enthralled = list() //those controlled by a vampire


/datum/game_mode/goon_vampire
	name = "goonvampire"
	config_tag = "goonvampire"
	restricted_jobs = list("AI", "Cyborg")
	protected_jobs = list("Security Officer", "Security Cadet", "Warden", "Detective", "Head of Security", "Captain", "Blueshield", "Nanotrasen Representative", "Security Pod Pilot", "Magistrate", "Chaplain", "Brig Physician", "Internal Affairs Agent", "Nanotrasen Navy Officer", "Nanotrasen Navy Field Officer", "Special Operations Officer", "Supreme Commander", "Syndicate Officer")
	protected_species = list("Machine", "Голем")
	required_players = 15
	required_enemies = 1
	recommended_enemies = 4
	///list of minds of soon to be vampires
	var/list/datum/mind/pre_vampires = list()


/datum/game_mode/goon_vampire/announce()
	to_chat(world, "<B>The current game mode is - Vampires!</B>")
	to_chat(world, "<B>There are Bluespace Vampires infesting your fellow crewmates, keep your blood close and neck safe!</B>")


/datum/game_mode/goon_vampire/pre_setup()

	if(config.protect_roles_from_antagonist)
		restricted_jobs += protected_jobs

	var/list/datum/mind/possible_vampires = get_players_for_role(ROLE_VAMPIRE)

	var/vampire_scale = 10
	if(config.traitor_scaling)
		vampire_scale = config.traitor_scaling
	var/vampire_amount = 1 + round(num_players() / vampire_scale)
	add_game_logs("Number of vampires chosen: [vampire_amount]")

	if(length(possible_vampires))
		for(var/i in 1 to vampire_amount)
			if(!length(possible_vampires))
				break
			var/datum/mind/vampire = pick_n_take(possible_vampires)
			pre_vampires += vampire
			vampire.special_role = SPECIAL_ROLE_VAMPIRE
			vampire.restricted_roles = restricted_jobs

		..()
		return TRUE
	else
		return FALSE


/datum/game_mode/goon_vampire/post_setup()
	for(var/datum/mind/vampire in pre_vampires)
		vampire.add_antag_datum(/datum/antagonist/goon_vampire)
	..()


/datum/game_mode/proc/auto_declare_completion_goon_vampire()
	if(!length(goon_vampires))
		return

	var/text = "<FONT size = 2><B>The vampires were:</B></FONT>"
	for(var/datum/mind/vampire in goon_vampires)
		var/traitorwin = TRUE
		text += "<br>[vampire.get_display_key()] was [vampire.name] ("
		if(vampire.current)
			if(vampire.current.stat == DEAD)
				text += "died"
			else
				text += "survived"
		else
			text += "body destroyed"
		text += ")"

		var/list/all_objectives = vampire.get_all_objectives()

		if(length(all_objectives))//If the traitor had no objectives, don't need to process this.
			var/count = 1
			for(var/datum/objective/objective in all_objectives)
				if(objective.check_completion())
					text += "<br><B>Objective #[count]</B>: [objective.explanation_text] <font color='green'><B>Success!</B></font>"
					if(istype(objective, /datum/objective/steal))
						var/datum/objective/steal/steal = objective
						SSblackbox.record_feedback("nested tally", "vampire_steal_objective", 1, list("Steal [steal.steal_target]", "SUCCESS"))
					else
						SSblackbox.record_feedback("nested tally", "vampire_objective", 1, list("[objective.type]", "SUCCESS"))
				else
					text += "<br><B>Objective #[count]</B>: [objective.explanation_text] <font color='red'>Fail.</font>"
					if(istype(objective, /datum/objective/steal))
						var/datum/objective/steal/steal = objective
						SSblackbox.record_feedback("nested tally", "vampire_steal_objective", 1, list("Steal [steal.steal_target]", "FAIL"))
					else
						SSblackbox.record_feedback("nested tally", "vampire_objective", 1, list("[objective.type]", "FAIL"))
					traitorwin = FALSE
				count++

		var/special_role_text
		if(vampire.special_role)
			special_role_text = lowertext(vampire.special_role)
		else
			special_role_text = "antagonist"

		if(traitorwin)
			text += "<br><font color='green'><B>The [special_role_text] was successful!</B></font>"
			SSblackbox.record_feedback("tally", "vampire_success", 1, "SUCCESS")
		else
			text += "<br><font color='red'><B>The [special_role_text] has failed!</B></font>"
			SSblackbox.record_feedback("tally", "vampire_success", 1, "FAIL")
	to_chat(world, text)
	return TRUE


/datum/game_mode/proc/auto_declare_completion_goon_enthralled()
	if(!length(goon_vampire_enthralled))
		return

	var/text = "<FONT size = 2><B>The Enthralled were:</B></FONT>"
	for(var/datum/mind/mind in goon_vampire_enthralled)
		text += "<br>[mind.get_display_key()] was [mind.name] ("
		if(mind.current)
			if(mind.current.stat == DEAD)
				text += "died"
			else
				text += "survived"
			if(mind.current.real_name != mind.name)
				text += " as [mind.current.real_name]"
		else
			text += "body destroyed"
		text += ")"
	to_chat(world, text)
	return TRUE

