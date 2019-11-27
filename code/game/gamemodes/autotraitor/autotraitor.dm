//This is a beta game mode to test ways to implement an "infinite" traitor round in which more traitors are automatically added in as needed.
//Automatic traitor adding is complete pending the inevitable bug fixes.  Need to add a respawn system to let dead people respawn after 30 minutes or so.


/datum/game_mode/traitor/autotraitor
	name = "AutoTraitor"
	config_tag = "extend-a-traitormongous"

	var/list/possible_traitors
	var/num_players = 0

/datum/game_mode/traitor/autotraitor/announce()
	..()
	to_chat(world, "<B>Game mode is AutoTraitor. Traitors will be added to the round automagically as needed.</B>")

/datum/game_mode/traitor/autotraitor/pre_setup()

	if(config.protect_roles_from_antagonist)
		restricted_jobs += protected_jobs

	possible_traitors = get_players_for_role(ROLE_TRAITOR)

	for(var/mob/new_player/P in world)
		if(P.client && P.ready)
			num_players++

	//var/r = rand(5)
	var/num_traitors = 1
	var/max_traitors = 1
	var/traitor_prob = 0
	max_traitors = round(num_players / 10) + 1
	traitor_prob = (num_players - (max_traitors - 1) * 10) * 10

	// Stop setup if no possible traitors
	if(!possible_traitors.len)
		return 0

	if(config.traitor_scaling)
		num_traitors = max_traitors - 1 + prob(traitor_prob)
		log_game("Number of traitors: [num_traitors]")
		message_admins("Players counted: [num_players]  Number of traitors chosen: [num_traitors]")
	else
		num_traitors = max(1, min(num_players(), traitors_possible))


	for(var/i = 0, i < num_traitors, i++)
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

//	if(!traitors.len)
//		return 0
	return 1




/datum/game_mode/traitor/autotraitor/post_setup()
	..()
	traitorcheckloop()

/datum/game_mode/traitor/autotraitor/proc/traitorcheckloop()
	spawn(9000)
		if(SSshuttle.emergency.mode >= SHUTTLE_ESCAPE)
			return
		//message_admins("Performing AutoTraitor Check")
		var/playercount = 0
		var/traitorcount = 0
		var/possible_traitors[0]
		for(var/mob/living/player in GLOB.mob_list)
			if(player.client && player.stat != DEAD)
				playercount += 1
				if(!player.mind)
					continue
				if(player.mind.special_role)
					traitorcount += 1
					continue
				if(ishuman(player) || isrobot(player) || isAI(player))
					if((ROLE_TRAITOR in player.client.prefs.be_special) && !player.client.skip_antag && !jobban_isbanned(player, ROLE_TRAITOR) && !jobban_isbanned(player, "Syndicate"))
						possible_traitors += player.mind
		for(var/datum/mind/player in possible_traitors)
			for(var/job in restricted_jobs)
				if(player.assigned_role == job)
					possible_traitors -= player
			if(!player.current || !ishuman(player.current)) // Remove mindshield-implanted mobs from the list
				continue
			var/mob/living/carbon/human/H = player.current
			for(var/obj/item/implant/mindshield/I in H.contents)
				if(I && I.implanted)
					possible_traitors -= player
			if(!H.job || H.mind.offstation_role) //Golems, special events stuff, etc.
				possible_traitors -= player
		//message_admins("Live Players: [playercount]")
		//message_admins("Live Traitors: [traitorcount]")
//		message_admins("Potential Traitors:")
//		for(var/mob/living/traitorlist in possible_traitors)
//			message_admins("[traitorlist.real_name]")

//		var/r = rand(5)
//		var/target_traitors = 1
		var/max_traitors = 1
		var/traitor_prob = 0
		max_traitors = round(playercount / 10) + 1
		traitor_prob = (playercount - (max_traitors - 1) * 10) * 5
		if(traitorcount < max_traitors - 1)
			traitor_prob += 50


		if(traitorcount < max_traitors)
			//message_admins("Number of Traitors is below maximum.  Rolling for new Traitor.")
			//message_admins("The probability of a new traitor is [traitor_prob]%")

			if(prob(traitor_prob))
				message_admins("Making a new Traitor.")
				if(!possible_traitors.len)
					message_admins("No potential traitors.  Cancelling new traitor.")
					traitorcheckloop()
					return
				var/datum/mind/newtraitormind = pick(possible_traitors)
				var/mob/living/newtraitor = newtraitormind.current
				//message_admins("[newtraitor.real_name] is the new Traitor.")

				to_chat(newtraitor, "<span class='danger'>ATTENTION:</span> It is time to pay your debt to the Syndicate...")
				newtraitor.mind.add_antag_datum(/datum/antagonist/traitor)
			//else
				//message_admins("No new traitor being added.")
		//else
			//message_admins("Number of Traitors is at maximum.  Not making a new Traitor.")

		traitorcheckloop()



/datum/game_mode/traitor/autotraitor/latespawn(mob/living/carbon/human/character)
	..()
	if(SSshuttle.emergency.mode >= SHUTTLE_ESCAPE)
		return
	//message_admins("Late Join Check")
	if(character.client && (ROLE_TRAITOR in character.client.prefs.be_special) && !character.client.skip_antag && !jobban_isbanned(character, ROLE_TRAITOR) && !jobban_isbanned(character, "Syndicate"))
		//message_admins("Late Joiner has Be Syndicate")
		//message_admins("Checking number of players")
		var/playercount = 0
		var/traitorcount = 0
		for(var/mob/living/player in GLOB.mob_list)
			if(player.client && player.stat != DEAD)
				playercount += 1
				if(player.mind && player.mind.special_role)
					traitorcount += 1
		//message_admins("Live Players: [playercount]")
		//message_admins("Live Traitors: [traitorcount]")

		//var/r = rand(5)
		//var/target_traitors = 1
		var/max_traitors = 2
		var/traitor_prob = 0
		max_traitors = round(playercount / 10) + 1
		traitor_prob = (playercount - (max_traitors - 1) * 10) * 5
		if(traitorcount < max_traitors - 1)
			traitor_prob += 50

		//target_traitors = max(1, min(round((playercount + r) / 10, 1), traitors_possible))
		//message_admins("Target Traitor Count is: [target_traitors]")
		if(traitorcount < max_traitors)
			for(var/job in restricted_jobs)
				if(character.mind.assigned_role == job || !ishuman(character))
					return
			//message_admins("Number of Traitors is below maximum.  Rolling for New Arrival Traitor.")
			//message_admins("The probability of a new traitor is [traitor_prob]%")
			if(prob(traitor_prob))
				message_admins("New traitor roll passed.  Making a new Traitor.")
				character.mind.make_Traitor()	//TEMP: Add proper checks for loyalty here. uc_guy
			//else
				//message_admins("New traitor roll failed.  No new traitor.")
	//else
		//message_admins("Late Joiner does not have Be Syndicate")
