/*
	Note that as with existing ai upload, this is not an interactive program.
	That means that the work is done in execute() rather than interact()
*/

/datum/file/program/upload/ai
	execute(var/datum/file/program/source)
		if(!interactable() || istype(usr,/mob/living/silicon))
			return 0
		if(!computer.net)
			to_chat(usr, "An indecipherable set of code flicks across the screen.  Nothing else happens.")
			return
		var/list/results = computer.net.get_machines