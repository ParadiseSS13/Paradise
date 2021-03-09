/datum/game_mode/devil
	name = "devil"
	config_tag = "devil"
	protected_jobs = list("Security Officer", "Warden", "Detective", "Nanotrasen Representative", "Security Pod Pilot", "Magistrate",
						 "Internal Affairs Agent", "Librarian", "Chaplain", "Head of Security", "Captain",  "Brig Physician",
						 "Nanotrasen Navy Officer", "Special Operations Officer", "AI", "Cyborg")
	required_players = 2
	required_enemies = 1
	recommended_enemies = 4

	var/traitors_possible = 4 //hard limit on devils if scaling is turned off
	var/num_modifier = 0 // Used for gamemodes, that are a child of traitor, that need more than the usual.
	var/objective_count = 2
	var/minimum_devils = 1
	var/devil_scale_coefficient = 10

/datum/game_mode/devil/announce()
	to_chat(world, {"<B>The current game mode is - Devil!</B><br>)
		<span class='danger'>Devils</span>: Purchase souls and tempt the crew to sin!<br>
		<span class='notice'>Crew</span>: Resist the lure of sin and remain pure!"})

/datum/game_mode/devil/pre_setup()

	if(config.protect_roles_from_antagonist)
		restricted_jobs += protected_jobs

	var/list/possible_devils = get_players_for_role(ROLE_DEVIL)
	var/num_devils = 0
	if(!possible_devils.len)
		return 0
	if(config.traitor_scaling)
		num_devils = max(1, round((num_players())/(devil_scale_coefficient))+1)
	else
		num_devils = max(1, min(num_players(), traitors_possible))


	for(var/j = 0, j < num_devils, j++)
		if (!possible_devils.len)
			break
		var/datum/mind/devil = pick(possible_devils)
		devils += devil
		devil.special_role = ROLE_DEVIL
		devil.restricted_roles = restricted_jobs

		log_game("[devil.key] (ckey) has been selected as a [config_tag]")
		possible_devils.Remove(devil)

	if(devils.len < required_enemies)
		return 0
	return 1


/datum/game_mode/devil/post_setup()
	for(var/datum/mind/devil in devils)
		spawn(rand(10, 100))
			finalize_devil(devil, TRUE)
			spawn(100)
				forge_devil_objectives(devil, objective_count) //This has to be in a separate loop, as we need devil names to be generated before we give objectives in devil agent.
				devil.devilinfo.announce_laws(devil.current)
				var/obj_count = 1
				to_chat(devil.current, "<span class='notice'> Your current objectives:</span>")
				for(var/datum/objective/objective in devil.objectives)
					to_chat(devil.current, "<B>Objective #[obj_count]</B>: [objective.explanation_text]")
					obj_count++
	modePlayer += devils
	..()
	return 1
