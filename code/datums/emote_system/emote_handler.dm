/datum/emoteHandler
	var/mob/owner
	var/list/commands

/datum/emoteHandler/New(var/mob/user)
	owner = user
	setupCommands()

/datum/emoteHandler/proc/setupCommands()
	commands = new/list()
	for(var/e in emotes)
		var/datum/emote/emote = e
		if(emote.baseLevel)
			var/datum/emote/found = searchTree(emote)
			if(found)
				for(var/command in found.commands)
					commands[command] = found

/datum/emoteHandler/proc/runEmote(var/command, var/param, var/message, var/audible) // message and audible only used in custom emotes
	if(!command)
		return 0
	if(command == "help")
		showCommands()
		return 1

	var/datum/emote/emote
	if(command == "me")
		emote = customEmote(message, audible)
		if(!emote)
			return 0
	if(!commands[command] && !(command == "me"))
		to_chat(owner, "<span class = 'notice'>Unknown emote, please check *help for emotes available to your character</span>")
		return 0
	if(!emote)
		emote = commands[command]
	if(!emote.available(owner))	// something's changed, remake the commands list, then try again to see if they've got a different version
		setupCommands()
		return runEmote(command, param, message)

	var/prevented = emote.prevented(owner)
	if(prevented)
		to_chat(owner, "<span class = 'notice'>You can't do that because [prevented]!</span>")
		return 0
	return emote.doEmote(owner)

/datum/emoteHandler/proc/showCommands()
	var/emoteList = "Available emotes are "
	var/commandAdded = 0
	for (var/c in commands)
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
		var/datum/emote/em = new t		// not keen on this, but it's this or loop through the emotes list and the
		found = searchTree(em)			// thought of a nested for loop in a recursive proc makes me want to *cry - VB
		if(found)
			return (found)
	if(emote.available(owner))
		return emote

/datum/emoteHandler/proc/customEmote(var/custom, var/audible)
	var/datum/emote/custom/emote
	if(isobserver(owner))
		emote = new /datum/emote/custom/ghost
	else
		emote = new /datum/emote/custom(owner, custom, audible)
	if (emote.available(owner))
		return emote
