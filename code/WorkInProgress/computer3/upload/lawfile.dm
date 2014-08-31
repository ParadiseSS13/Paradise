/*
	Computer3 law changes:

	* Laws are a file type
	* Connecting to the AI requires a network connection
	* Connecting to a borg requires a radio or network.

*/

/datum/file/ai_law
	var/list/hacklaws = null
	var/zerolaw = null
	var/list/corelaws = null
	var/list/auxlaws = null

	var/configurable = 0

	// override this when you need to be able to alter the parameters of the lawset
	proc/configure()
		return

	execute(var/datum/file/program/source)
		if(istype(usr,/mob/living/silicon))
			return
		if(istype(source,/datum/file/program/ntos))
			if(configurable)
				configure()
			return
		if(istype(source,/datum/file/program/upload/ai))