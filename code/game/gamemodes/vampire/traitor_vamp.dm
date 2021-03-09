/datum/game_mode/traitor/vampire
	name = "traitor+vampire"
	config_tag = "traitorvamp"
	traitors_possible = 3 //hard limit on traitors if scaling is turned off
	protected_jobs = list("Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Blueshield", "Nanotrasen Representative", "Security Pod Pilot", "Magistrate", "Chaplain", "Brig Physician", "Internal Affairs Agent", "Nanotrasen Navy Officer", "Special Operations Officer")
	restricted_jobs = list("AI", "Cyborg")
	required_players = 10
	required_enemies = 1	// how many of each type are required
	recommended_enemies = 3
	var/protected_species_vampire = list("Machine")

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

	if(possible_vampires.len > 0)
		var/datum/mind/vampire = pick(possible_vampires)
		vampires += vampire
		modePlayer += vampires
		var/datum/mindslaves/slaved = new()
		slaved.masters += vampire
		vampire.som = slaved //we MIGT want to mindslave someone
		vampire.restricted_roles = restricted_jobs
		vampire.special_role = SPECIAL_ROLE_VAMPIRE
		..()
		return 1
	else
		return 0

/datum/game_mode/traitor/vampire/post_setup()
	for(var/datum/mind/vampire in vampires)
		grant_vampire_powers(vampire.current)
		vampire.special_role = SPECIAL_ROLE_VAMPIRE
		forge_vampire_objectives(vampire)
		greet_vampire(vampire)
		update_vampire_icons_added(vampire)
	..()
