/**
 * This is a beta game mode to test ways to implement an "infinite" traitor round in which more traitors are automatically added in as needed.
 */
/datum/game_mode/traitor/autotraitor
	name = "AutoTraitor"
	config_tag = "extend-a-traitormongous"


/datum/game_mode/traitor/autotraitor/announce()
	to_chat(world, "<B>The current game mode is - AutoTraitor!</B>")
	to_chat(world, "Syndicate traitors will be added to the round automagically as needed.</B>")


/datum/game_mode/traitor/autotraitor/post_setup()
	..()
	// better to use subsystem, but its good for now
	addtimer(CALLBACK(src, PROC_REF(autotraitor_check)), 15 MINUTES, TIMER_UNIQUE | TIMER_LOOP | TIMER_STOPPABLE)


/datum/game_mode/traitor/autotraitor/latespawn(mob/living/carbon/human/player)
	autotraitor_check(max_traitors = 2)


/datum/game_mode/traitor/autotraitor/proc/autotraitor_check(max_traitors = 1)

	if(SSshuttle.emergency.mode >= SHUTTLE_ESCAPE)
		return

	message_admins("Performing AutoTraitor Check")

	var/num_players = 0
	var/traitorcount = 0
	var/list/possible_traitors = list()

	for(var/mob/living/player in GLOB.mob_list)
		if(!player.client || player.stat == DEAD)
			continue
		num_players++

		if(!player.mind)
			continue

		if(player.mind.special_role)
			traitorcount++
			continue

		if(!player.job || player.mind.offstation_role) //Golems, special events stuff, etc.
			continue

		for(var/job in restricted_jobs)
			if(player.mind.assigned_role == job)
				continue

		if(!ishuman(player) || !(ROLE_TRAITOR in player.client.prefs.be_special) || player.client.skip_antag \
			|| jobban_isbanned(player, ROLE_TRAITOR) || jobban_isbanned(player, "Syndicate") \
			|| !player_old_enough_antag(player.client, ROLE_TRAITOR))
			continue

		var/obj/item/implant/mindshield/implant = locate() in player.contents
		if(implant)
			continue

		possible_traitors += player.mind

	if(!length(possible_traitors))
		message_admins("No potential traitors found. Cancelling attempt.")
		return

	var/traitor_prob = 0
	var/traitor_scale = 10

	if(config.traitor_scaling)
		traitor_scale = config.traitor_scaling

	max_traitors = round(num_players / traitor_scale) + 1
	traitor_prob = (num_players - (max_traitors - 1) * 10) * 5

	if(traitorcount < max_traitors - 1)
		traitor_prob += 50

	if(traitorcount >= max_traitors)
		message_admins("Number of Traitors is at maximum. Skipping attempt.")
		return

	if(!prob(traitor_prob))
		message_admins("Roll for new Traitor is failed. Skipping attempt.")
		return

	possible_traitors = shuffle(possible_traitors)
	var/datum/mind/new_traitor = pick(possible_traitors)
	to_chat(new_traitor.current, "<span class='danger'>ATTENTION:</span> It is time to pay your debt to the Syndicate...")
	new_traitor.add_antag_datum(/datum/antagonist/traitor)
	message_admins("[new_traitor.current.real_name] is the new Traitor.")

