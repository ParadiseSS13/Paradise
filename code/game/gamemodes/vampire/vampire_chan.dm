/datum/game_mode/vampire/changeling
	name = "vampire_changeling"
	config_tag = "vampchan"
	restricted_jobs = list("AI", "Cyborg")
	protected_jobs = list("Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Blueshield", "Nanotrasen Representative", "Magistrate", "Chaplain", "Internal Affairs Agent", "Nanotrasen Career Trainer", "Nanotrasen Navy Officer", "Special Operations Officer", "Syndicate Officer", "Solar Federation General", "Research Director", "Head of Personnel", "Chief Medical Officer", "Chief Engineer", "Quartermaster")
	species_to_mindflayer = list("Machine")
	recommended_enemies = 3
	secondary_enemies_scaling = 0.025
	vampire_penalty = 0.4 // Cut out 40% of the vampires since we'll replace some with changelings

/datum/game_mode/vampire/changeling/pre_setup()
	if(GLOB.configuration.gamemode.prevent_mindshield_antags)
		restricted_jobs += protected_jobs

	var/list/datum/mind/possible_changelings = get_players_for_role(ROLE_CHANGELING)
	secondary_enemies = CEILING((secondary_enemies_scaling * num_players()), 1)

	if(!length(possible_changelings))
		return ..()

	for(var/I in possible_changelings)
		if(length(pre_changelings) >= secondary_enemies)
			break
		var/datum/mind/changeling = pick_n_take(possible_changelings)
		changeling.restricted_roles = (restricted_jobs + secondary_restricted_jobs)
		if(changeling.current?.client?.prefs.active_character.species in species_to_mindflayer)
			pre_mindflayers += changeling
			secondary_enemies -= 1 // Again, since we aren't increasing pre_changeling we'll just decrement what it's compared to.
			changeling.special_role = SPECIAL_ROLE_MIND_FLAYER
			continue
		pre_changelings += changeling
		changeling.special_role = SPECIAL_ROLE_CHANGELING

	return ..()

/datum/game_mode/vampire/changeling/announce()
	to_chat(world, "<b>The current game mode is - Vampires+Changelings!</b>")
	to_chat(world, "<b>Some of your co-workers are vampires, and others might not even be your coworkers!</b>")

/datum/game_mode/vampire/changeling/post_setup()
	for(var/datum/mind/changeling as anything in pre_changelings)
		changeling.add_antag_datum(/datum/antagonist/changeling)
	..()
