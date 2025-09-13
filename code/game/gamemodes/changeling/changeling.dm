
// This list is basically a copy of GLOB.greek_letters, but it also removes letters when a changeling spawns in with that ID
GLOBAL_LIST_INIT(possible_changeling_IDs, list("Alpha","Beta","Gamma","Delta","Epsilon","Zeta","Eta","Theta","Iota","Kappa","Lambda","Mu","Nu","Xi","Omicron","Pi","Rho","Sigma","Tau","Upsilon","Phi","Chi","Psi","Omega"))

/datum/game_mode/changeling
	name = "changeling"
	config_tag = "changeling"
	restricted_jobs = list("AI", "Cyborg")
	protected_jobs = list("Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Blueshield", "Nanotrasen Representative", "Magistrate", "Internal Affairs Agent", "Nanotrasen Career Trainer", "Nanotrasen Navy Officer", "Special Operations Officer", "Syndicate Officer", "Trans-Solar Federation General", "Nanotrasen Career Trainer", "Research Director", "Head of Personnel", "Chief Medical Officer", "Chief Engineer", "Quartermaster")
	species_to_mindflayer = list("Machine")
	required_players = 15
	required_enemies = 1
	recommended_enemies = 4
	/// The total number of changelings allowed to be picked.
	var/changeling_amount = 4

/datum/game_mode/changeling/Destroy(force, ...)
	pre_changelings.Cut()
	pre_mindflayers.Cut()
	return ..()

/datum/game_mode/changeling/announce()
	to_chat(world, "<B>The current game mode is - Changeling!</B>")
	to_chat(world, "<B>There are alien changelings on the station. Do not let the changelings succeed!</B>")

/datum/game_mode/changeling/pre_setup()
	if(GLOB.configuration.gamemode.prevent_mindshield_antags)
		restricted_jobs += protected_jobs

	var/list/datum/mind/possible_changelings = get_players_for_role(ROLE_CHANGELING)

	changeling_amount = 1 + round(num_players() / 10)

	for(var/i in 1 to changeling_amount)
		if(!length(possible_changelings))
			break
		var/datum/mind/changeling = pick_n_take(possible_changelings)
		changeling.restricted_roles = restricted_jobs
		if(changeling.current?.client?.prefs.active_character.species in species_to_mindflayer)
			pre_mindflayers += changeling
			changeling.special_role = SPECIAL_ROLE_MIND_FLAYER
			continue
		pre_changelings += changeling
		changeling.special_role = SPECIAL_ROLE_CHANGELING

	if(!(length(pre_changelings) + length(pre_mindflayers)))
		return FALSE

	return TRUE

/datum/game_mode/changeling/post_setup()
	for(var/datum/mind/changeling as anything in pre_changelings)
		changeling.add_antag_datum(/datum/antagonist/changeling)
		pre_changelings -= changeling
	..()

/datum/game_mode/proc/auto_declare_completion_changeling()
	if(length(changelings))
		var/list/text = list("<br><font size=3><span class='bold'>The changelings were:</span></font>")
		for(var/datum/mind/changeling in changelings)
			var/changelingwin = TRUE

			text += "<br>[changeling.get_display_key()] was [changeling.name] and "
			if(changeling.current)
				if(changeling.current.stat == DEAD)
					text += "<span class='bold'>died</span>!"
				else
					text += "<span class='bold'>survived!</span>"
				if(changeling.current.real_name != changeling.name)
					text += " as [changeling.current.real_name]"
				else
					text += "!"
			else
				text += "<span class='bold'>had [changeling.p_their()] body destroyed!</span>"
				changelingwin = FALSE

			// Removed sanity if(changeling) because we -want- a runtime to inform us that the changelings list is incorrect and needs to be fixed.
			var/datum/antagonist/changeling/cling = changeling.has_antag_datum(/datum/antagonist/changeling)
			text += "<br><b>Changeling ID:</b> [cling.changelingID]."
			text += "<br><b>Genomes Extracted:</b> [cling.absorbed_count]"

			var/list/all_objectives = changeling.get_all_objectives(include_team = FALSE)

			if(length(all_objectives))
				var/count = 1
				for(var/datum/objective/objective in all_objectives)
					text += "<br><b>Objective #[count]</b>: [objective.explanation_text]"
					if(objective.check_completion())
						if(istype(objective, /datum/objective/steal))
							var/datum/objective/steal/S = objective
							SSblackbox.record_feedback("nested tally", "changeling_steal_objective", 1, list("Steal [S.steal_target]", "SUCCESS"))
						else
							SSblackbox.record_feedback("nested tally", "changeling_objective", 1, list("[objective.type]", "SUCCESS"))
					else
						if(istype(objective, /datum/objective/steal))
							var/datum/objective/steal/S = objective
							SSblackbox.record_feedback("nested tally", "changeling_steal_objective", 1, list("Steal [S.steal_target]", "FAIL"))
						else
							SSblackbox.record_feedback("nested tally", "changeling_objective", 1, list("[objective.type]", "FAIL"))
						changelingwin = 0
					count++

			if(changelingwin)
				SSblackbox.record_feedback("tally", "changeling_success", 1, "SUCCESS")
			else
				SSblackbox.record_feedback("tally", "changeling_success", 1, "FAIL")
		return text.Join("")
