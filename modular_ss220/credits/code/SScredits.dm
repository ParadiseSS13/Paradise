SUBSYSTEM_DEF(credits)
	name = "Credits"
	runlevels = RUNLEVEL_POSTGAME
	flags = SS_NO_FIRE

	var/datum/cinematic/credits/current_cinematic

	var/datum/credits/end_titles
	var/title_music = ""

	var/credit_roll_speed = 22 SECONDS
	var/credit_spawn_speed = 2 SECONDS
	var/credit_animate_height

/datum/controller/subsystem/credits/Initialize()
	credit_animate_height = 16 * world.icon_size

/datum/controller/subsystem/credits/proc/play_credits_cinematic()
	var/cinematic_type

	if(NEW_YEAR in SSholiday.holidays)
		end_titles = new /datum/credits/new_year()
		cinematic_type = /datum/cinematic/credits/new_year
	else if(HALLOWEEN in SSholiday.holidays)
		end_titles = new /datum/credits/halloween()
		cinematic_type = /datum/cinematic/credits/halloween
	else if(APRIL_FOOLS in SSholiday.holidays)
		end_titles = new /datum/credits/aprils_fool()
		cinematic_type = /datum/cinematic/credits
	else
		end_titles = new /datum/credits/default()
		cinematic_type = /datum/cinematic/credits

	title_music = end_titles.soundtrack

	current_cinematic = play_cinematic(cinematic_type, world)

/datum/controller/subsystem/credits/proc/roll_credits_for_clients(list/client/clients)
	end_titles.roll_credits_for_clients(clients)

/datum/controller/subsystem/credits/proc/clear_credits(client/client)
	if(!client?.credits)
		return

	for(var/credit in client.credits)
		client.screen -= credit

	client.credits.Cut()
