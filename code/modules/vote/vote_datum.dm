
/datum/vote
	/// Person who started the vote
	var/initiator = "серверу"
	/// world.time the vote started at
	var/started_time
	/// The question being asked
	var/question
	/// Vote type text, for showing in UIs and stuff
	var/vote_type_text = "что-то особенное"
	/// Do we want to show the vote counts as it goes
	var/show_counts = FALSE
	/// Vote result type. This determines how a winner is picked
	var/vote_result_type = VOTE_RESULT_TYPE_MAJORITY
	/// Was this vote custom started?
	var/is_custom = FALSE
	/// Choices available in the vote
	var/list/choices = list()
	// Assoc list of [ckeys => choice] who have voted. We dont want to hold client refs.
	var/list/voted = list()


/datum/vote/New(_initiator, _question, list/_choices, _is_custom = FALSE)
	if(SSvote.active_vote)
		CRASH("Попытка начать голосование во время того, как идёт другое!")

	if(_initiator)
		initiator = _initiator
	if(_question)
		question = _question
	if(_choices)
		choices = _choices

	is_custom = _is_custom

	// If we have no choices, dynamically generate them
	if(!length(choices))
		generate_choices()

/datum/vote/proc/start()
	var/text = "Голосование за [capitalize(vote_type_text)] начато благодаря [initiator]."
	if(is_custom)
		vote_type_text = "custom"
		text += "\n[question]"
		if(usr)
			log_admin("[capitalize(vote_type_text)] ([question]) голосование начато благодаря [key_name(usr)].")

	else if(usr)
		log_admin("Голосование за [capitalize(vote_type_text)] начато благодаря [key_name(usr)].")

	log_vote(text)
	started_time = world.time
	announce(text)

/datum/vote/proc/remaining()
	return max(((started_time + GLOB.configuration.vote.vote_time) - world.time), 0)


// Returns the result
/datum/vote/proc/calculate_result()
	switch(vote_result_type)
		if(VOTE_RESULT_TYPE_MAJORITY)
			if(!length(voted))
				to_chat(world, "<span class='interface'>Нет ни одного голоса. Вы все ненавидите демократию?!</span>") // shame them
				return null

			var/list/results = list()

			// Count up all votes
			for(var/ck in voted)
				if(voted[ck] in results)
					results[voted[ck]]++
				else
					results[voted[ck]] = 1

			// Get the biggest vote count, since we can also use this to pick tiebreaks
			var/maxvotes = 0
			for(var/res in results)
				maxvotes = max(results[res], maxvotes)

			var/list/winning_options = list()

			for(var/res in results)
				if(results[res] == maxvotes)
					winning_options |= res

			// Print all results
			for(var/res in results)
				if(res in winning_options)
					// Make it stand out
					to_chat(world, "<span class='interface'><code>[res]</code> - [results[res]] vote\s</span>")
				else
					// Make it normal
					to_chat(world, "<span class='interface'><code>[res]</code> - [results[res]] vote\s</span>")

				// And log it to the DB
				if(!is_custom)
					SSblackbox.record_feedback("nested tally", "votes", results[res], list(vote_type_text, res), ignore_seal = TRUE)

			if(length(winning_options) > 1)
				var/random_dictator = pick(winning_options)
				to_chat(world, "<span class='interface'><b>Ничья между [english_list(winning_options)]. Случайный выбор: <code>[random_dictator]</code>.</b></span>") // shame them
				return random_dictator

			// If we got here there must only be one thing in the list
			var/res = winning_options[1]

			if(res in choices)
				to_chat(world, "<span class='interface'><b><code>[res]</code> выигрывает голосование.</b></span>")
				return res

			to_chat(world, "<span class='interface'>Победитель голосования ([sanitize(res)]) не является допустимым выбором? Какого чёрта?</span>")
			stack_trace("Голосование типа [type] завершилось недопустимым ответом. Ответом был [sanitize(res)], вариантами были: [json_encode(choices)]")
			return null



/datum/vote/proc/announce(start_text)
	to_chat(world, chat_box_purple(
		"<span><font color='purple'><b>[start_text]</b></br></br>\
		<a href='byond://?src=[SSvote.UID()];vote=open'>Нажмите здесь или введите <code>Vote</code>, чтобы оставить голос.</a></br>\
		У вас [GLOB.configuration.vote.vote_time / 10] секунд на выбор.</span>"), MESSAGE_TYPE_OOC)
	SEND_SOUND(world, sound('sound/ambience/alarm4.ogg'))


/datum/vote/proc/tick()
	if(remaining() == 0)
		// Announce result
		var/result = calculate_result()
		handle_result(result)
		qdel(src)


/datum/vote/Destroy(force)
	// Should always be true but ehhhhhhh
	if(SSvote.active_vote == src)
		SSvote.active_vote = null
	return ..()


// Override on children
/datum/vote/proc/handle_result(result)
	return

/datum/vote/proc/generate_choices()
	return


/*
	UI STUFFS
*/
/datum/vote/ui_state(mob/user)
	return GLOB.always_state

/datum/vote/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "VotePanel", "Панель голосования")
		ui.open()

/datum/vote/ui_data(mob/user)
	var/list/data = list()
	data["remaining"] = remaining()
	data["user_vote"] = null
	if(user.ckey in voted)
		data["user_vote"] = voted[user.ckey]

	data["question"] = question
	data["choices"] = choices

	// Admins see counts anyway
	if(show_counts || check_rights(R_ADMIN, FALSE, user))
		data["show_counts"] = TRUE

		// Show counts
		var/list/counts = list()
		for(var/ck in voted)
			if(voted[ck] in counts)
				counts[voted[ck]]++
			else
				counts[voted[ck]] = 1

		data["counts"] = counts
	else
		data["show_counts"] = FALSE
		data["counts"] = list() // No TGUI exploiting for you

	return data

/datum/vote/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return

	. = TRUE

	switch(action)
		if("vote")
			if(params["target"] in choices)
				voted[usr.ckey] = params["target"]
			else
				message_admins("<span class='boldannounceooc'>\[EXPLOIT]</span> Пользователь [key_name_admin(usr)] подделал голосование в панели!")
