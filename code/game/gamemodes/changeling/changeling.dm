#define LING_FAKEDEATH_TIME					50 SECONDS
#define LING_ABSORB_RECENT_SPEECH			8	//The amount of recent spoken lines to gain on absorbing a mob

GLOBAL_LIST_INIT(possible_changeling_IDs, list("Alpha","Beta","Gamma","Delta","Epsilon","Zeta","Eta","Theta","Iota","Kappa","Lambda","Mu","Nu","Xi","Omicron","Pi","Rho","Sigma","Tau","Upsilon","Phi","Chi","Psi","Omega"))

/datum/game_mode
	var/list/datum/mind/changelings = list()

/datum/game_mode/changeling
	name = "changeling"
	config_tag = "changeling"
	restricted_jobs = list("AI", "Cyborg")
	protected_jobs = list("Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Blueshield", "Nanotrasen Representative", "Magistrate", "Internal Affairs Agent", "Nanotrasen Navy Officer", "Special Operations Officer", "Syndicate Officer", "Solar Federation General")
	protected_species = list("Machine")
	required_players = 15
	required_enemies = 1
	recommended_enemies = 4
	/// The total number of changelings allowed to be picked.
	var/changeling_amount = 4
	/// A list containing references to the minds of soon-to-be changelings. This is seperate to avoid duplicate entries in the `changelings` list.
	var/list/datum/mind/pre_changelings = list()

/datum/game_mode/changeling/Destroy(force, ...)
	pre_changelings.Cut()
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
		pre_changelings += changeling
		changeling.restricted_roles = restricted_jobs
		changeling.special_role = SPECIAL_ROLE_CHANGELING

	if(!length(pre_changelings))
		return FALSE

	return TRUE

/datum/game_mode/changeling/post_setup()
	for(var/datum/mind/changeling as anything in pre_changelings)
		changeling.add_antag_datum(/datum/antagonist/changeling)
		pre_changelings -= changeling
	..()

/datum/game_mode/proc/auto_declare_completion_changeling()
	if(length(changelings))
		var/text = "<FONT size = 3><B>The changelings were:</B></FONT>"
		for(var/datum/mind/changeling in changelings)
			var/changelingwin = TRUE

			text += "<br>[changeling.get_display_key()] was [changeling.name] ("
			if(changeling.current)
				if(changeling.current.stat == DEAD)
					text += "died"
				else
					text += "survived"
				if(changeling.current.real_name != changeling.name)
					text += " as [changeling.current.real_name]"
			else
				text += "body destroyed"
				changelingwin = FALSE
			text += ")"

			//Removed sanity if(changeling) because we -want- a runtime to inform us that the changelings list is incorrect and needs to be fixed.
			var/datum/antagonist/changeling/cling = changeling.has_antag_datum(/datum/antagonist/changeling)
			text += "<br><b>Changeling ID:</b> [cling.changelingID]."
			text += "<br><b>Genomes Extracted:</b> [cling.absorbed_count]"

			var/list/all_objectives = changeling.get_all_objectives(include_team = FALSE)

			if(length(all_objectives))
				var/count = 1
				for(var/datum/objective/objective in all_objectives)
					if(objective.check_completion())
						text += "<br><B>Objective #[count]</B>: [objective.explanation_text] <font color='green'><B>Success!</B></font>"
						if(istype(objective, /datum/objective/steal))
							var/datum/objective/steal/S = objective
							SSblackbox.record_feedback("nested tally", "changeling_steal_objective", 1, list("Steal [S.steal_target]", "SUCCESS"))
						else
							SSblackbox.record_feedback("nested tally", "changeling_objective", 1, list("[objective.type]", "SUCCESS"))
					else
						text += "<br><B>Objective #[count]</B>: [objective.explanation_text] <font color='red'>Fail.</font>"
						if(istype(objective, /datum/objective/steal))
							var/datum/objective/steal/S = objective
							SSblackbox.record_feedback("nested tally", "changeling_steal_objective", 1, list("Steal [S.steal_target]", "FAIL"))
						else
							SSblackbox.record_feedback("nested tally", "changeling_objective", 1, list("[objective.type]", "FAIL"))
						changelingwin = 0
					count++

			if(changelingwin)
				text += "<br><font color='green'><B>The changeling was successful!</B></font>"
				SSblackbox.record_feedback("tally", "changeling_success", 1, "SUCCESS")
			else
				text += "<br><font color='red'><B>The changeling has failed.</B></font>"
				SSblackbox.record_feedback("tally", "changeling_success", 1, "FAIL")

		to_chat(world, text)

	return TRUE
