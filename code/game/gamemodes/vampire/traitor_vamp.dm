/datum/game_mode/traitor/vampire
	name = "traitor_vampire"
	config_tag = "traitorvamp"
	traitors_possible = 3 //hard limit on traitors if scaling is turned off
	protected_jobs = list("Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Blueshield", "Nanotrasen Representative", "Magistrate", "Internal Affairs Agent", "Nanotrasen Navy Officer", "Special Operations Officer", "Trans-Solar Federation General")
	restricted_jobs = list("Cyborg")
	secondary_restricted_jobs = list("AI", "Chaplain")
	required_players = 10
	required_enemies = 1	// how many of each type are required
	recommended_enemies = 3
	secondary_enemies_scaling = 0.025
	secondary_protected_species = list("Machine")
	var/list/datum/mind/pre_vampires = list()

/datum/game_mode/traitor/vampire/announce()
	to_chat(world, "<B>The current game mode is - Traitor+Vampire!</B>")
	to_chat(world, "<B>There are Bluespace Vampires infesting your fellow crew on the station along with some syndicate operatives out for their own gain! Do not let the vampires and the traitors succeed!</B>")


/datum/game_mode/traitor/vampire/pre_setup()
	if(GLOB.configuration.gamemode.prevent_mindshield_antags)
		restricted_jobs += protected_jobs

	var/list/datum/mind/possible_vampires = get_players_for_role(ROLE_VAMPIRE)
	secondary_enemies = CEILING((secondary_enemies_scaling * num_players()), 1)

	for(var/mob/new_player/player in GLOB.player_list)
		if((player.mind in possible_vampires) && (player.client.prefs.active_character.species in secondary_protected_species))
			possible_vampires -= player.mind

	if(length(possible_vampires) > 0)
		for(var/I in possible_vampires)
			if(length(pre_vampires) >= secondary_enemies)
				break
			var/datum/mind/vampire = pick_n_take(possible_vampires)
			pre_vampires += vampire
			vampire.special_role = SPECIAL_ROLE_VAMPIRE
			vampire.restricted_roles = (restricted_jobs + secondary_restricted_jobs)
		..()
		return 1
	else
		return 0

/datum/game_mode/traitor/vampire/post_setup()
	for(var/datum/mind/vampire in pre_vampires)
		vampire.add_antag_datum(/datum/antagonist/vampire)
	..()
