#define VOTE_COUNTING_MAJORITY "Majority"
#define VOTE_COUNTING_TICKET "Ticket"

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
	/// Vote counting algorithm. This determines how a winner is picked
	var/vote_counting = VOTE_COUNTING_MAJORITY
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
	// Sanitize the votes first
	for(var/ck in voted)
		if(!(voted[ck] in choices))
			stack_trace("Someone managed to cast a vote outside of presented options! The choices were [json_encode(choices)]; the vote is [voted[ck]]")
			voted -= ck  // so that the following code doesn't get confused
			continue

	// Count up all votes
	var/list/results = list()
	for(var/choice in choices)
		results[choice] = 0
	for(var/ck in voted)
		results[voted[ck]] += 1

	// And log them to DB
	if(!is_custom)
		for(var/res in results)
			SSblackbox.record_feedback("nested tally", "votes", results[res], list(vote_type_text, res), ignore_seal = TRUE)

	// Here goes the actual winner selection code
	switch(vote_counting)
		if(VOTE_COUNTING_MAJORITY)
			if(!length(voted))
				to_chat(world, "<span class='interface'>No votes were cast. Do you all hate democracy?!</span>") // shame them
				return null

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
					to_chat(world, "<span class='info'><code>[res]</code> - [results[res]] vote\s</span>")
				else
					// Make it normal
					to_chat(world, "<span class='interface'><code>[res]</code> - [results[res]] vote\s</span>")

			if(length(winning_options) > 1)
				var/random_dictator = pick(winning_options)
				to_chat(world, "<span class='interface'><b>Its a tie between [english_list(winning_options)]. Picking <code>[random_dictator]</code> at random.</b></span>") // shame them
				return random_dictator

			// If we got here there must only be one thing in the list
			var/res = winning_options[1]

			to_chat(world, "<span class='interface'><b><code>[res]</code> won the vote.</b></span>")
			return res

		if(VOTE_COUNTING_TICKET)
			if(!length(voted))
				to_chat(world, "<span class='interface'>No votes were cast. Do you all hate democracy?!</span>") // shame them
				return null

			var/lucky_winner_ck = pick(voted)
			var/lucky_winner_vote = voted[lucky_winner_ck]
			var/lucky_mob = get_mob_by_ckey(lucky_winner_ck)
			lucky_winner_ck = safe_get_ckey(lucky_mob)  // anonymize, if requested

			// Print all results
			for(var/res in results)
				var/percentage = round((results[res] * 100 / length(voted)), 0.1)
				to_chat(world, "<span class='info'><code>[res]</code> - [results[res]] vote\s ([percentage]%)</span>")
			// And then the winner
			to_chat(world, "<span class='interface'>Reaching into the bag of votes to draw one at random...</span>")
			to_chat(world, "<span class='interface'>...and the lucky winner is <b><code>[lucky_winner_vote]</code></b>! (ticket cast by [lucky_mob] ([lucky_winner_ck]))</span>")

			if(!is_custom)
				SSblackbox.record_feedback("text", "vote_winner", 1, lucky_winner_vote, ignore_seal = TRUE)

			return lucky_winner_vote

/datum/vote/proc/announce(start_text)
	to_chat(world, {"<font color='purple'><b>[start_text]</b>
		<a href='?src=[SSvote.UID()];vote=open'>Click here or type <code>Vote</code> to place your vote.</a>
		You have [GLOB.configuration.vote.vote_time / 10] seconds to vote.</font>"})
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
/datum/vote/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.always_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "VotePanel", "VotePanel", 400, 500, master_ui, state)
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
				message_admins("<span class='boldannounce'>\[EXPLOIT]</span> User [key_name_admin(usr)] spoofed a vote in the vote panel!")

