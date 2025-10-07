/datum/game_mode/traitor/autotraitor
	name = "AutoTraitor"
	config_tag = "extend-a-traitormongous"

	var/list/possible_traitors
	var/num_players = 0

/datum/game_mode/traitor/autotraitor/announce()
	..()
	to_chat(world, "<b>Game mode is AutoTraitor. Traitors will be added to the round automagically as needed.</b>")

/datum/game_mode/traitor/autotraitor/pre_setup()
	if(GLOB.configuration.gamemode.prevent_mindshield_antags)
		restricted_jobs += protected_jobs

	possible_traitors = get_players_for_role(ROLE_TRAITOR)

	for(var/mob/new_player/P in world)
		if(P.client && P.ready)
			num_players++

	var/num_traitors = 1
	var/max_traitors = 1
	var/traitor_prob = 0
	max_traitors = round(num_players / 10) + 1
	traitor_prob = (num_players - (max_traitors - 1) * 10) * 10

	// Stop setup if no possible traitors
	if(!length(possible_traitors))
		return FALSE

	if(GLOB.configuration.gamemode.traitor_scaling)
		num_traitors = max_traitors - 1 + prob(traitor_prob)
		log_game("Number of traitors: [num_traitors]")
		message_admins("Players counted: [num_players]  Number of traitors chosen: [num_traitors]")
	else
		num_traitors = max(1, min(num_players(), traitors_possible))

	for(var/i in 1 to num_traitors)
		var/datum/mind/traitor = pick(possible_traitors)
		pre_traitors += traitor
		possible_traitors.Remove(traitor)

	for(var/datum/mind/traitor in pre_traitors)
		if(!traitor || !istype(traitor))
			pre_traitors.Remove(traitor)
			continue
		if(istype(traitor))
			traitor.special_role = SPECIAL_ROLE_TRAITOR
			traitor.restricted_roles = restricted_jobs

	return TRUE

/datum/game_mode/traitor/autotraitor/post_setup()
	..()
	addtimer(CALLBACK(src, PROC_REF(traitor_check_loop)), 15 MINUTES)

/datum/game_mode/traitor/autotraitor/proc/traitor_check_loop()
	if(SSshuttle.emergency.mode >= SHUTTLE_ESCAPE)
		return

	var/player_count = 0
	var/traitor_count = 0
	var/list/possible_traitors = list()
	for(var/mob/living/player in GLOB.mob_list)
		if(player.client && player.stat != DEAD)
			if(!player.mind)
				continue
			if(player.mind.offstation_role) //Don't count as crew.
				continue
			player_count += 1
			if(player.mind.has_antag_datum(/datum/antagonist/traitor))
				traitor_count += 1
				continue
			if(ishuman(player) || is_ai(player))
				if((ROLE_TRAITOR in player.client.prefs.be_special) && !player.client.persistent.skip_antag && !jobban_isbanned(player, ROLE_TRAITOR) && !jobban_isbanned(player, ROLE_SYNDICATE))
					possible_traitors += player.mind
	for(var/datum/mind/player in possible_traitors)
		for(var/job in restricted_jobs)
			if(player.assigned_role == job)
				possible_traitors -= player
		if(!player.current || !ishuman(player.current)) // Remove mindshield-implanted mobs from the list
			continue
		var/mob/living/carbon/human/H = player.current
		if(ismindshielded(H))
			possible_traitors -= player
		if(!H.job || H.mind.offstation_role) //Golems, special events stuff, etc.
			possible_traitors -= player

	var/max_traitors = 1
	var/traitor_prob = 0
	max_traitors = round(player_count / 10) + 1
	traitor_prob = (player_count - (max_traitors - 1) * 10) * 5
	if(traitor_count < max_traitors - 1)
		traitor_prob += 50

	if(traitor_count < max_traitors)
		if(prob(traitor_prob))
			message_admins("Making a new Traitor.")
			log_game("Making a new Traitor.")
			if(!length(possible_traitors))
				message_admins("No potential traitors. Cancelling new traitor.")
				log_game("No potential traitors. Cancelling new traitor.")
				addtimer(CALLBACK(src, PROC_REF(traitor_check_loop)), 15 MINUTES)
				return
			var/datum/mind/new_traitor_mind = pick(possible_traitors)
			var/mob/living/new_traitor = new_traitor_mind.current

			to_chat(new_traitor, "<span class='danger'>ATTENTION:</span> It is time to pay your debt to the Syndicate...")
			new_traitor.mind.add_antag_datum(/datum/antagonist/traitor)
			message_admins("[key_name(new_traitor)] was added in as a traitor!")
			log_game("[key_name(new_traitor)] was added in as a traitor.")

	addtimer(CALLBACK(src, PROC_REF(traitor_check_loop)), 15 MINUTES)

/datum/game_mode/traitor/autotraitor/latespawn(mob/living/carbon/human/character)
	..()
	if(SSshuttle.emergency.mode >= SHUTTLE_ESCAPE)
		return

	if(character.client && (ROLE_TRAITOR in character.client.prefs.be_special) && !character.client.persistent.skip_antag && !jobban_isbanned(character, ROLE_TRAITOR) && !jobban_isbanned(character, ROLE_SYNDICATE))
		var/player_count = 0
		var/traitor_count = 0
		for(var/mob/living/player in GLOB.mob_list)
			if(player.client && player.stat != DEAD)
				player_count += 1
				if(player.mind && player.mind.special_role)
					traitor_count += 1

		var/max_traitors = 2
		var/traitor_prob = 0
		max_traitors = round(player_count / 10) + 1
		traitor_prob = (player_count - (max_traitors - 1) * 10) * 5
		if(traitor_count < max_traitors - 1)
			traitor_prob += 50

		if(traitor_count < max_traitors)
			for(var/job in restricted_jobs)
				if(character.mind.assigned_role == job || !ishuman(character))
					return

			if(prob(traitor_prob))
				message_admins("New traitor roll passed. Making a new Traitor.")
				log_game("New traitor roll passed. Making a new Traitor.")
				character.mind.make_Traitor()

/datum/game_mode/traitor/autotraitor/on_mob_cryo(mob/sleepy_mob, obj/machinery/cryopod/cryopod)
	possible_traitors.Remove(sleepy_mob)
