/datum/emoteHandler
	var/mob/owner
	var/list/commands

/datum/emoteHandler/New(var/mob/user)
	owner = user
	setupCommands()

/datum/emoteHandler/proc/setupCommands(var/reset = 0)
	spawn(0)			// needed so at mob creation species is set before emotes are allocated
		if(reset)
			deleteEmoteVerbs()
		commands = new/list()
		for(var/e in emotes)
			var/datum/emote/emote = e
			if(emote.baseLevel || emote.allowParent)
				var/datum/emote/found = searchTree(emote)
				if(found)
					for(var/command in found.commands)
						commands[lowertext(command)] = found
					found.addVerbs(owner)

/datum/emoteHandler/proc/deleteEmoteVerbs()
	for(var/obj/emoteVerb/E in owner.contents)
		qdel(E)

/datum/emoteHandler/proc/runEmote(var/command = "", var/message = "", var/audible = 0) // message and audible only used in custom emotes
	if(!command)
		return 0
	if(command == "help")
		showCommands()
		return 1

	var/datum/emote/emote

	if(copytext(command, 1, 3) == "me" && !message && lentext(command) >= 4)
		message = copytext(command, 4)
		command = "me"

	if(command == "me")
		emote = customEmote(message, audible)
		if(!emote)
			return 0

	if(!commands[command] && !(command == "me"))
		to_chat(owner, "<span class='notice'>Unknown emote, please check *help for emotes available to your character</span>")
		return 0

	if(!emote)
		emote = commands[command]

	if(!emote.available(owner))	// something's changed, remake the commands list, then try again to see if they've got a different version
		setupCommands()
		return runEmote(command, message, audible)

	var/prevented = emote.prevented(owner)
	if(prevented)
		to_chat(owner, "<span class='notice'>You can't do that because [prevented]!</span>")
		return 0
	return emote.doEmote(owner, command)

/datum/emoteHandler/proc/showCommands()
	var/emoteList = "Available emotes are "
	var/commandAdded = 0
	for(var/c in commands)
		if(commandAdded)
			emoteList += ", "
		emoteList += c
		commandAdded = 1

	to_chat(owner, emoteList)

// recursive search of subtypes - starts checking at the lowest level and breaks out if it finds one that can be done
/datum/emoteHandler/proc/searchTree(var/datum/emote/emote)
	var/list/subtypes = subtypesof(emote.type)
	var/datum/emote/found
	for(var/t in subtypes)
		var/datum/emote/em = new t
		if(em.allowParent)
			continue
		found = searchTree(em)
		if(found)
			return (found)
	if(emote.available(owner))
		return emote

/datum/emoteHandler/proc/customEmote(var/custom, var/audible)
	if(isobserver(owner))
		return new /datum/emote/custom/ghost(owner, custom, audible)
	return new /datum/emote/custom(owner, custom, audible)
