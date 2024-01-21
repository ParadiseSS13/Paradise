/client/verb/vote()
	set category = "OOC"
	set name = "Vote"

	if(SSvote.active_vote)
		SSvote.active_vote.ui_interact(usr)
	else
		to_chat(usr, "There is no active vote")

/client/proc/start_vote()
	set category = "Admin"
	set name = "Start Vote"
	set desc = "Start a vote on the server"

	if(!check_rights(R_ADMIN))
		return

	if(SSvote.active_vote)
		to_chat(usr, "A vote is already in progress")
		return

	// Ask admins which type of vote they want to start
	var/vote_types = subtypesof(/datum/vote)
	vote_types |= "\[CUSTOM]"

	// This needs to be a map to instance it properly. I do hate it as well, dont worry.
	var/list/votemap = list()
	for(var/vtype in vote_types)
		votemap["[vtype]"] = vtype

	var/choice = input(usr, "Select a vote type", "Vote") as null|anything in vote_types

	if(choice == null)
		return

	if(choice != "\[CUSTOM]")
		// Not custom, figure it out
		var/datum/vote/votetype = votemap["[choice]"]
		SSvote.start_vote(new votetype(usr.ckey))
		return

	// Its custom, lets ask
	var/question = input(usr, "What is the vote for?") as text|null
	if(!question)
		return

	var/list/choices = list()
	for(var/i in 1 to 10)
		var/option = capitalize(input(usr, "Please enter an option or hit cancel to finish") as text|null)
		if(!option || !usr.client)
			break
		choices |= option

	var/c2 = alert(usr, "Show counts while vote is happening?", "Counts", "Yes", "No")
	var/c3 = input(usr, "Select a result calculation type", "Vote", VOTE_RESULT_TYPE_MAJORITY) as anything in list(VOTE_RESULT_TYPE_MAJORITY)

	var/datum/vote/V = new /datum/vote(usr.ckey, question, choices, TRUE)
	V.show_counts = (c2 == "Yes")
	V.vote_result_type = c3
	SSvote.start_vote(V)

