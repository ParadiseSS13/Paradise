SUBSYSTEM_DEF(credits)
	name = "Credits"
	runlevels = RUNLEVEL_POSTGAME
	flags = SS_NO_FIRE

	var/datum/credits/end_titles
	var/title_music = ""

	var/credit_roll_speed = 22 SECONDS
	var/credit_spawn_speed = 2 SECONDS
	var/credit_animate_height

/datum/controller/subsystem/credits/Initialize()
	credit_animate_height = 16 * world.icon_size

/datum/controller/subsystem/credits/proc/roll_credits_for_clients(list/clients)
	end_titles = new /datum/credits/default()

	end_titles.roll_credits_for_clients(clients)

/datum/controller/subsystem/credits/proc/clear_credits(client/client)
	if(!client)
		return

	for(var/credit in client.credits)
		QDEL_NULL(credit)
