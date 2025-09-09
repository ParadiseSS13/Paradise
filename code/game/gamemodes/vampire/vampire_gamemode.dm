/datum/game_mode/vampire
	name = "vampire"
	config_tag = "vampire"
	restricted_jobs = list("AI", "Cyborg")
	protected_jobs = list("Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Blueshield", "Nanotrasen Representative", "Magistrate", "Chaplain", "Internal Affairs Agent", "Nanotrasen Career Trainer", "Nanotrasen Navy Officer", "Special Operations Officer", "Syndicate Officer", "Trans-Solar Federation General", "Nanotrasen Career Trainer",  "Research Director", "Head of Personnel", "Chief Medical Officer", "Chief Engineer", "Quartermaster")
	species_to_mindflayer = list("Machine")
	required_players = 15
	required_enemies = 1
	recommended_enemies = 4
	/// If this gamemode should spawn less vampires than a usual vampire round, as a percentage of how many you want relative to the regular amount
	var/vampire_penalty = 0

/datum/game_mode/vampire/announce()
	to_chat(world, "<B>The current game mode is - Vampires!</B>")
	to_chat(world, "<B>There are Vampires aboard, keep your blood close and neck safe!</B>")

/datum/game_mode/vampire/pre_setup()

	if(GLOB.configuration.gamemode.prevent_mindshield_antags)
		restricted_jobs += protected_jobs

	var/list/datum/mind/possible_vampires = get_players_for_role(ROLE_VAMPIRE)

	var/vampire_amount = 1 + (round(num_players() / 10) * (1 - vampire_penalty))

	if(length(possible_vampires))
		for(var/i in 1 to vampire_amount)
			if(!length(possible_vampires))
				break
			var/datum/mind/vampire = pick_n_take(possible_vampires)
			vampire.restricted_roles = (restricted_jobs + secondary_restricted_jobs)
			if(vampire.current?.client?.prefs.active_character.species in species_to_mindflayer)
				pre_mindflayers += vampire
				vampire.special_role = SPECIAL_ROLE_MIND_FLAYER
				continue
			pre_vampires += vampire
			vampire.special_role = SPECIAL_ROLE_VAMPIRE

		..()
		return TRUE
	else
		return FALSE

/datum/game_mode/vampire/post_setup()
	for(var/datum/mind/vampire in pre_vampires)
		vampire.add_antag_datum(/datum/antagonist/vampire)
	..()

/datum/game_mode/proc/auto_declare_completion_vampire()
	if(!length(vampires))
		return

	var/list/text = list("<br><font size=3><span class='bold'>The vampires were:</span></font>")
	for(var/datum/mind/vampire in vampires)
		var/traitorwin = TRUE
		var/datum/antagonist/vampire/V = vampire.has_antag_datum(/datum/antagonist/vampire)
		text += "<br>[vampire.get_display_key()] was [vampire.name] and "
		if(vampire.current)
			if(vampire.current.stat == DEAD)
				text += "<span class='bold'>died!</span>"
			else
				text += "<span class='bold'>survived!</span>"
				if(V.subclass)
					text += " as a [V.subclass.name]!"
				else
					text += "!"
		else
			text += "<span class='bold'>had [vampire.p_their()] body destroyed!</span>"

		var/list/all_objectives = vampire.get_all_objectives(include_team = FALSE)

		if(length(all_objectives))//If the traitor had no objectives, don't need to process this.
			var/count = 1
			for(var/datum/objective/objective in all_objectives)
				text += "<br><B>Objective #[count]</B>: [objective.explanation_text]"
				if(objective.check_completion())
					if(istype(objective, /datum/objective/steal))
						var/datum/objective/steal/S = objective
						SSblackbox.record_feedback("nested tally", "vampire_steal_objective", 1, list("Steal [S.steal_target]", "SUCCESS"))
					else
						SSblackbox.record_feedback("nested tally", "vampire_objective", 1, list("[objective.type]", "SUCCESS"))
				else
					if(istype(objective, /datum/objective/steal))
						var/datum/objective/steal/S = objective
						SSblackbox.record_feedback("nested tally", "vampire_steal_objective", 1, list("Steal [S.steal_target]", "FAIL"))
					else
						SSblackbox.record_feedback("nested tally", "vampire_objective", 1, list("[objective.type]", "FAIL"))
					traitorwin = FALSE
				count++

		if(traitorwin)
			SSblackbox.record_feedback("tally", "vampire_success", 1, "SUCCESS")
		else
			SSblackbox.record_feedback("tally", "vampire_success", 1, "FAIL")
	return text.Join("")

/datum/game_mode/proc/auto_declare_completion_enthralled()
	if(!length(vampire_enthralled))
		return

	var/list/text = list("<br><font size=3><b>The Enthralled were:</b></font>")
	for(var/datum/mind/mind in vampire_enthralled)
		text += "<br>[mind.get_display_key()] was [mind.name] and"
		if(mind.current)
			if(mind.current.stat == DEAD)
				text += "<span class='bold'>died!</span>"
			else
				text += "<span class='bold'>survived!</span>"
			if(mind.current.real_name != mind.name)
				text += "<span class='bold'> as [mind.current.real_name]!</bold>"
			else
				text += "!"
		else
			text += "<span class='bold'>had their body destroyed!</span>"
	return text.Join("")

