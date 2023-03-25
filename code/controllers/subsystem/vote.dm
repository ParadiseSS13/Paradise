SUBSYSTEM_DEF(vote)
	name = "Vote"
	wait = 10
	flags = SS_KEEP_TIMING|SS_NO_INIT
	runlevels = RUNLEVEL_LOBBY | RUNLEVELS_DEFAULT
	offline_implications = "Votes (Endround shuttle) will no longer function. Shuttle call recommended."

	/// Active vote, if any
	var/datum/vote/active_vote

/datum/controller/subsystem/vote/fire()
	if(active_vote)
		active_vote.tick()

/datum/controller/subsystem/vote/proc/start_vote(datum/vote/V)
	// This will be fun if DM ever gets concurrency
	active_vote = V
	active_vote.start()

/datum/controller/subsystem/vote/Topic(href, list/href_list)
	if(href_list["vote"] == "open")
		usr.client.vote()
