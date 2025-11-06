/datum/game_mode/traitor/vampire
	name = "traitor_vampire"
	config_tag = "traitorvamp"
	traitors_possible = 3 //hard limit on traitors if scaling is turned off
	protected_jobs = list("Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Blueshield", "Nanotrasen Representative", "Magistrate", "Internal Affairs Agent", "Nanotrasen Career Trainer", "Nanotrasen Navy Officer", "Special Operations Officer", "Trans-Solar Federation General",  "Research Director", "Head of Personnel", "Chief Medical Officer", "Chief Engineer", "Quartermaster")
	restricted_jobs = list("Cyborg")
	secondary_restricted_jobs = list("AI", "Chaplain")
	required_players = 10
	recommended_enemies = 3
	secondary_enemies_scaling = 0.025
	species_to_mindflayer = list("Machine")

/datum/game_mode/traitor/vampire/announce()
	to_chat(world, "<B>The current game mode is - Traitor+Vampire!</B>")
	to_chat(world, "<B>There are Vampires on the station along with syndicate operatives out for their own gain! Do not let the vampires and the traitors succeed!</B>")


/datum/game_mode/traitor/vampire/pre_setup()
	if(GLOB.configuration.gamemode.prevent_mindshield_antags)
		restricted_jobs += protected_jobs

	var/list/datum/mind/possible_vampires = get_players_for_role(ROLE_VAMPIRE)
	secondary_enemies = CEILING((secondary_enemies_scaling * num_players()), 1)

	if(length(possible_vampires) <= 0)
		return FALSE

	for(var/I in possible_vampires)
		if((length(pre_vampires) + length(pre_mindflayers)) >= secondary_enemies)
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

/datum/game_mode/traitor/vampire/post_setup()
	for(var/datum/mind/vampire in pre_vampires)
		vampire.add_antag_datum(/datum/antagonist/vampire)
	..()
