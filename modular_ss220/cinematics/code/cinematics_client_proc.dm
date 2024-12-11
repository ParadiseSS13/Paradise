/client/proc/cinematic_new()
	set name = "Cinematic (NEW)"
	set category = "Event"
	set desc = "Shows a cinematic." // Intended for testing but I thought it might be nice for events on the rare occasion Feel free to comment it out if it's not wanted.
	set hidden = TRUE

	if(!SSticker)
		return
	if(!check_rights(R_MAINTAINER))
		return

	var/datum/cinematic/choice = input(usr, "Choose a cinematic to play to everyone in the server.", "Choose Cinematic") in sortTim(subtypesof(/datum/cinematic), GLOBAL_PROC_REF(cmp_typepaths_asc))
	if(!choice || !ispath(choice, /datum/cinematic))
		return

	play_cinematic(choice, world)

/client/proc/cinematic_leave()
	set name = "Прекратить смотреть синематик"
	set category = "OOC"
	set desc = "Отключить проигрывание синематика."

	verbs -= /client/proc/cinematic_leave

	if(!mob.screens["cinematic"])
		return

	SEND_SIGNAL(src, COMSIG_CINEMATIC_WATCHER_LEAVES)
