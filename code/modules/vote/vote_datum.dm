
/datum/vote
	/// Person who started the vote
	var/initiator = "the server"
	/// world.time the vote started at
	var/started_time
	/// The question being asked
	var/question
	/// Vote type text, for showing in UIs and stuff
	var/vote_type_text = "unset"
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
		CRASH("Attempted to start another vote with one already in progress!")

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
	var/text = "[capitalize(vote_type_text)] vote started by [initiator]."
	if(is_custom)
		vote_type_text = "custom"
		text += "\n[question]"
		if(usr)
			log_admin("[capitalize(vote_type_text)] ([question]) vote started by [key_name(usr)].")

	else if(usr)
		log_admin("[capitalize(vote_type_text)] vote started by [key_name(usr)].")

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
				to_chat(world, "<span class='interface'>No votes were cast. Do you all hate democracy?!</span>") // shame them
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
				to_chat(world, "<span class='interface'><b>Its a tie between [english_list(winning_options)]. Picking <code>[random_dictator]</code> at random.</b></span>") // shame them
				return random_dictator

			// If we got here there must only be one thing in the list
			var/res = winning_options[1]

			if(res in choices)
				to_chat(world, "<span class='interface'><b><code>[res]</code> won the vote.</b></span>")
				return res

			to_chat(world, "<span class='interface'>The winner of the vote ([sanitize(res)]) isnt a valid choice? What the heck?</span>")
			stack_trace("Vote of type [type] concluded with an invalid answer. Answer was [sanitize(res)], choices were [json_encode(choices)]")
			return null



/datum/vote/proc/announce(start_text)
	to_chat(world, chat_box_purple(
		"<span><font color='purple'><b>[start_text]</b></br></br>\
		<a href='byond://?src=[SSvote.UID()];vote=open'>Click here or type <code>Vote</code> to place your vote.</a></br>\
		You have [GLOB.configuration.vote.vote_time / 10] seconds to vote.</span>"), MESSAGE_TYPE_OOC)
	SEND_SOUND(world, sound('sound/misc/server_alert.ogg'))


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
		ui = new(user, src, "VotePanel", "Vote Panel")
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
				message_admins("<span class='boldannounceooc'>\[EXPLOIT]</span> User [key_name_admin(usr)] spoofed a vote in the vote panel!")
