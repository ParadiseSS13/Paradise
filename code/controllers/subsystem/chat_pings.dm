SUBSYSTEM_DEF(chat_pings)
	name = "Chat Pings"
	flags = SS_NO_INIT
	runlevels = RUNLEVEL_INIT | RUNLEVEL_LOBBY | RUNLEVEL_SETUP | RUNLEVEL_GAME | RUNLEVEL_POSTGAME // ALL OF THEM
	wait = 30 SECONDS // Chat pings every 30 seconds
	/// List of all held chat datums
	var/list/datum/chatOutput/chat_datums = list() // Do NOT put this in Initialize(). You will cause issues.

/datum/controller/subsystem/chat_pings/fire(resumed)
	for(var/datum/chatOutput/CO as anything in chat_datums)
		CO.updatePing()
		if(MC_TICK_CHECK)
			return

/datum/controller/subsystem/chat_pings/stat_entry()
	..("P: [length(chat_datums)]")
