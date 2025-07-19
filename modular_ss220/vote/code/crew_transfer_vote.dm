#define ALIVE_VOTE_WEIGHT(online_players) (1)
#define DEAD_VOTE_WEIGHT(online_players) (1 / (1 + NUM_E ** (0.015 * (online_players - 80))))
#define GHOST_VOTE_WEIGHT(online_players) (1 / (1 + NUM_E ** (0.015 * online_players)))
#define LOBBY_VOTE_WEIGHT(online_players) (1 / (1 + NUM_E ** (0.03 * (online_players + 40))))
#define RESULT_PRECISION 0.01

/datum/vote/crew_transfer/calculate_result()
	if(!length(voted))
		to_chat(world, span_interface("Нет ни одного голоса. Вы все ненавидите демократию?!"))
		return null

	var/list/results = list()
	for(var/choice in choices)
		results[choice] = 0

	var/online_players = length(GLOB.clients)

	for(var/ckey in voted)
		var/choice = voted[ckey]
		if(!choice || !(choice in results))
			continue

		var/client/client = get_client_by_ckey(ckey)
		results[choice] += get_vote_weight_for_client(client, online_players)

	var/max_score = 0
	for(var/res in results)
		max_score = max(results[res], max_score)

	var/list/winning_options = list()
	for(var/res in results)
		// Consider values whose difference < RESULT_PRECISION as equal
		if(abs(results[res] - max_score) < RESULT_PRECISION)
			winning_options |= res

	to_chat(world, span_interface("Результаты голосования:"))
	for(var/res in results)
		var/display_score = round(results[res], RESULT_PRECISION)
		var/span_class = (res in winning_options) ? "bold" : "normal"
		to_chat(world, span_interface("<span class='[span_class]'><code>[res]</code> - [display_score] очков</span>"))
		SSblackbox.record_feedback("nested tally", "votes", results[res], list(vote_type_text, res), ignore_seal = TRUE)

	if(length(winning_options) > 1)
		var/random_dictator = pick(winning_options)
		to_chat(world, span_interface("Ничья между [english_list(winning_options)]. Случайный выбор: <code>[random_dictator]</code>."))
		return random_dictator

	var/res = winning_options[1]
	to_chat(world, span_interface("<b><code>[res]</code> выигрывает голосование.</b>"))
	return res

/datum/vote/crew_transfer/proc/get_vote_weight_for_client(client/client, online_players as num) as num
	if(!istype(client) || !client.mob)
		return 0

	var/mob/client_mob = client.mob

	if(client_mob in GLOB.alive_mob_list)
		return ALIVE_VOTE_WEIGHT(online_players)

	if(client_mob in GLOB.new_player_mobs)
		return LOBBY_VOTE_WEIGHT(online_players)

	if(client_mob in GLOB.dead_mob_list)
		var/mob/dead/observer/ghost = client_mob
		if(isobserver(ghost) && ghost.started_as_observer)
			return GHOST_VOTE_WEIGHT(online_players)
		return DEAD_VOTE_WEIGHT(online_players)

	log_game("[client.ckey]'s vote cannot be classified. Their vote will be ignored. Mob type: [client_mob.type]")
	return 0

#undef ALIVE_VOTE_WEIGHT
#undef DEAD_VOTE_WEIGHT
#undef GHOST_VOTE_WEIGHT
#undef LOBBY_VOTE_WEIGHT
#undef RESULT_PRECISION
