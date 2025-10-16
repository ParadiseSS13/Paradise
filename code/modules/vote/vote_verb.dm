/client/verb/vote()
	set category = "OOC"
	set name = "Vote"

	if(SSvote.active_vote)
		SSvote.active_vote.ui_interact(usr)
	else
		to_chat(usr, "There is no active vote")

ADMIN_VERB(start_vote, R_ADMIN, "Start Vote", "Start a vote on the server", VERB_CATEGORY_ADMIN)
	if(SSvote.active_vote)
		to_chat(user, "A vote is already in progress")
		return

	// Ask admins which type of vote they want to start
	var/vote_types = subtypesof(/datum/vote)
	vote_types |= "\[CUSTOM]"

	// This needs to be a map to instance it properly. I do hate it as well, dont worry.
	var/list/votemap = list()
	for(var/vtype in vote_types)
		votemap["[vtype]"] = vtype

	var/choice = tgui_input_list(user, "Select a vote type", "Vote", vote_types)

	if(choice == null)
		return

	if(choice != "\[CUSTOM]")
		// Not custom, figure it out
		var/datum/vote/votetype = votemap["[choice]"]
		SSvote.start_vote(new votetype(user.ckey))
		return

	// Its custom, lets ask
	var/question = tgui_input_text(user, "What is the vote for?", "Create Vote", encode = FALSE)
	if(isnull(question))
		return

	var/list/choices = list()
	for(var/i in 1 to 10)
		var/option = tgui_input_text(user, "Please enter an option or hit cancel to finish", "Create Vote", encode = FALSE)
		if(isnull(option) || !user)
			break
		choices |= option

	var/c2 = tgui_alert(user, "Show counts while vote is happening?", "Counts", list("Yes", "No"))
	var/c3 = input(user, "Select a result calculation type", "Vote", VOTE_RESULT_TYPE_MAJORITY) as anything in list(VOTE_RESULT_TYPE_MAJORITY)

	var/datum/vote/V = new /datum/vote(user.ckey, question, choices, TRUE)
	V.show_counts = (c2 == "Yes")
	V.vote_result_type = c3
	SSvote.start_vote(V)
