/datum/game_mode/traitor/vampire
	name = "traitor+vampire"
	config_tag = "traitorvamp"
	traitors_possible = 3 //hard limit on traitors if scaling is turned off
	protected_jobs = list("Security Officer", "Security Cadet", "Warden", "Detective", "Head of Security", "Captain", "Blueshield", "Nanotrasen Representative", "Security Pod Pilot", "Magistrate", "Chaplain", "Brig Physician", "Internal Affairs Agent", "Nanotrasen Navy Officer", "Nanotrasen Navy Field Officer", "Special Operations Officer", "Supreme Commander")
	restricted_jobs = list("AI", "Cyborg")
	required_players = 10
	required_enemies = 1	// how many of each type are required
	recommended_enemies = 3
	var/protected_species_vampire = list("Machine", "Голем")
	var/list/datum/mind/pre_vampires = list()


/datum/game_mode/traitor/vampire/announce()
	to_chat(world, "<B>The current game mode is - Traitor+Vampire!</B>")
	to_chat(world, "<B>There is a Vampire from Space Transylvania on the station along with some syndicate operatives out for their own gain! Do not let the vampire and the traitors succeed!</B>")


/datum/game_mode/traitor/vampire/pre_setup()
	if(config.protect_roles_from_antagonist)
		restricted_jobs += protected_jobs

	var/list/datum/mind/possible_vampires = get_players_for_role(ROLE_VAMPIRE)

	for(var/mob/new_player/player in GLOB.player_list)
		if((player.mind in possible_vampires) && (player.client.prefs.species in protected_species_vampire))
			possible_vampires -= player.mind

	if(length(possible_vampires))
		var/datum/mind/vampire = pick_n_take(possible_vampires)
		pre_vampires += vampire
		vampire.special_role = SPECIAL_ROLE_VAMPIRE
		vampire.restricted_roles = restricted_jobs

		..()
		return TRUE
	else
		return FALSE

/datum/game_mode/traitor/vampire/post_setup()
	for(var/datum/mind/vampire in pre_vampires)
		vampire.add_antag_datum(/datum/antagonist/vampire)
	..()

