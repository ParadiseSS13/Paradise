/*******************************************************************************************************
												Emotes
Remember, only 1 instance of each emote is made, and used by all mobs that can access it. As such, the
ONLY place you can safely set object variables during runtime is in New(). Otherwise override the emote.
The only exception to this is custom emotes, which are created as needed and only last until they are finished
VampyrBytes

*******************************************************************************************************/

/datum/emote
	var/name = ""
	var/desc = ""
	var/list/commands[0]  // commands that trigger the emote. Set these in New()
	var/text = ""
	var/selfText = ""		// the version of text that you should see - eg, if text is screams, you want scream here, as You screams is bad grammer
	var/startText = ""		// if you need to put something in before [user]. Should end with a space
	var/mimeText = ""
	var/sound				// sound file
	var/vol = 50
	var/audible = 0
	var/muzzledNoise = ""	// if the emote is audible and you're muzzled, this is what type of noise you make (eg weak, loud). End with a space
	var/restrained = ""		// 1 if being restrained prevents this emote
	var/cooldown = 0

	var/canTarget = 0		// 1 if the emote accepts a target
	var/targetMob = 0		// 0 if target can be any atom, 1 if it has to be a mob,
	var/targetText = "at" // what goes inbetween user and target
	var/takesNumber	= 0	// 1 if the emote uses a number parameter

	var/spanClass = "notice"
	var/baseLevel = 1
	var/baseSet = 0


/datum/emote/New()
	var/pathString = "[type]"
	var/count = 0
	for(var/i in 1 to lentext(pathString))
		var/char = copytext(pathString, i, i+1)
		if(char == "/")
			count++
			if(count == 4)
				baseLevel = 0
				break

/datum/emote/proc/doEmote(var/mob/user)
	if(!istype(user))
		return 0
	if(cooldown)
		if(handle_emote_CD(user))
			return 0

	var/number
	var/target

	if(takesNumber)
		number = getNumber(user)

	if(canTarget)
		target = getTarget(user)

	if(number == "failed" || target == "failed")	// If you need to test the input, override the appopriate get proc, call the parent,
		return									// then test it. If it fails, tell the user why, then return "failed" to halt the emote

	var/message = createMessage(user, number)

	if(canTarget && message)
		message = addTarget(user, target, message)

	if(message)
		message += "</span>"
		outputMessage(user, message)

	if(audible)
		if(!(user.mind && user.mind.miming))
			playSound(user, vol)

	doAction(user, target, number)
	return 1

// for things that the emote does that aren't text or sound based
/datum/emote/proc/doAction(var/mob/user, var/atom/target, var/number)
	return

/datum/emote/proc/getNumber(var/mob/user)
	var/number = input("How many") as null|num
	return number

/datum/emote/proc/getTarget(var/mob/user)
	if(targetMob)
		return getMobTarget()
	return getAtomTarget()

/datum/emote/proc/getMobTarget()
	var/mob/target = input("Select target", "Target Mob") as null|mob in view()
	return target

/datum/emote/proc/getAtomTarget()
	var/atom/target = input("Select target", "Target") as null|mob|obj|turf in oview()
	return target

// returns the reason the user can't currently do the emote
/datum/emote/proc/prevented(var/mob/user)
	if(user.stat == DEAD)
		return "you are dead"
	if(restrained && user.restrained())
		return "you are restrained"

// return 1 if this emote can be used by this type of user
/datum/emote/proc/available(var/mob/user)
	return

/datum/emote/proc/createMessage(var/mob/user, var/number)
	if(!text)
		return
	var/message
	if(takesNumber && number)
		message = getParamMessage(user, number)
	else if(audible && user.mind && user.mind.miming)
		message = mimeMessage(user)
	else if(audible && user.is_muzzled())
		message = muzzleMessage(user)
	else
		message = "[user] [text]"
	if(startText)
		message = "[startText] [message]"
	message = "<span class = '[spanClass]'>[message]"
	return message

/datum/emote/proc/mimeMessage(var/mob/user)
	if(!mimeText)
		return

	var/message = "[user] [mimeText]"
	return message

/datum/emote/proc/muzzleMessage(var/mob/user)
	var/message = "[user] makes a "
	if(muzzledNoise)
		message += "[muzzledNoise] "
	message += "noise"
	return message

/datum/emote/proc/getParamMessage(var/mob/user, var/param)
	var/message
	if(audible && user.mind && user.mind.miming)
		message = paramMimeMessage(user, param)
	else if (audible && user.is_muzzled())
		message = muzzleMessage(user)
	else
		message = paramMessage(user, param)
	return message

// if the emote takes a non target parameter, set up  and return the with parameter version in here
/datum/emote/proc/paramMessage(var/mob/user, var/param)
	return

// as above, but for mimes trying to do audible messages
/datum/emote/proc/paramMimeMessage(var/mob/user, var/param)
	return

/datum/emote/proc/addTarget(var/mob/user, var/atom/target, var/message = "")
	if(!canTarget)
		return message
	if(!target)
		return message
	if(ismob(target))
		message += " [targetText] [target]"
	else
		message += " [targetText] \the [target]"
	return message

// What you should see when you perform the emote
/datum/emote/proc/createSelfMessage(var/mob/user, var/message = "")
	var/selfMessage
	if(startText)
		selfMessage = replacetext(message, "[user]", "you")
	else
		selfMessage = replacetext(message, "[user]", "You")
	if(selfText)
		selfMessage = replacetext(selfMessage, text, selfText)
	return selfMessage

/datum/emote/proc/outputMessage(var/mob/user, var/message = "")
	if(!message)
		return
	log_emote("[user.name]/[user.key] : [message]")
	if(audible)
		audible_message(message, user)
	else
		visible_message(message, user)
	sendToDead(message)

/datum/emote/proc/visible_message(var/message = "", var/mob/user)
	var/selfMessage = createSelfMessage(user, message)
	for(var/mob/M in viewers(user))
		if(M.see_invisible < user.invisibility)
			continue //can't view the invisible
		var/msg = message
		if(selfMessage && M==user)
			msg = selfMessage
		if(M.sdisabilities & BLIND || M.blinded || M.paralysis)
			if(M.sdisabilities & DEAF || M.ear_deaf)
				continue
			msg = createBlindMessage(message, user)
			if(msg)
				outputAudibleMessage(msg, M, user, 1)
		else
			outputVisibleMessage(msg, M, user)

/datum/emote/proc/audible_message(var/message = "", var/mob/user)
	var/selfMessage = createSelfMessage(user, message)
	for(var/mob/M in get_mobs_in_view(7, user))
		var/msg = message
		if(selfMessage && M==src)
			msg = selfMessage
		if(M.sdisabilities & DEAF || M.ear_deaf)
			if(M.sdisabilities & BLIND || M.blinded || M.paralysis)
				continue
			msg = createDeafMessage(user, message)
			if(msg)
				outputVisibleMessage(msg, M, user, 1)
		else
			outputAudibleMessage(msg, M, user)

/datum/emote/proc/outputVisibleMessage(var/message, var/mob/recipient, var/mob/user, var/retest = 0)
	if(retest)
		if(!user)
			return
		var/found = 0
		for(var/mob/M in viewers(user))
			if(M == recipient)
				found = 1
				if(recipient.see_invisible < user.invisibility)
					return
				break
		if(!found)
			return
	if(recipient.sdisabilities & DEAF || recipient.ear_deaf)
		var/msg = createDeafMessage(user, message)
		if(msg)
			message = msg
	if(recipient.stat == UNCONSCIOUS || (recipient.sleeping > 0 && recipient.stat != 2))
		to_chat(recipient, "<I>... You can almost hear someone talking ...</I>")
	else
		to_chat(recipient, message)

/datum/emote/proc/outputAudibleMessage(var/message = "", var/mob/recipient, var/mob/user, var/retest = 0)
	if(retest)
		if(!user)
			return
		var/found = 0
		for(var/mob/M in get_mobs_in_view(7, user))
			if(M == recipient)
				found = 1
				break
		if(!found)
			return
	if(recipient.sdisabilities & BLIND || recipient.blinded || recipient.paralysis)
		var/msg = createBlindMessage(user, message)
		if(msg)
			message = msg
	if(recipient.stat == UNCONSCIOUS || (recipient.sleeping > 0 && recipient.stat != 2))
		to_chat(recipient, "<I>... You can almost hear someone talking ...</I>")
	else
		to_chat(recipient, message)

// set up different messages for blind people here. Empty will mean no message for
//non-audible emotes and the standard message for audible ones
/datum/emote/proc/createBlindMessage(var/mob/user, var/message)
	return

// set up different messages for deaf people here. Empty will mean no message for
// audible emotes and standard for non-audible ones
/datum/emote/proc/createDeafMessage(var/mob/user, var/message)
	return

/datum/emote/proc/sendToDead(message)
	for(var/mob/M in dead_mob_list)
		if(!M.client || istype(M, /mob/new_player))
			continue //skip monkeys, leavers and new players
		if(M.stat == DEAD && (M.client.prefs.toggles & CHAT_GHOSTSIGHT) && !(M in viewers(src,null)))
			M.show_message(message)

/datum/emote/proc/playSound(var/mob/user)
	if(sound)
		playsound(user, sound, vol)

//Emote Cooldown System (it's so simple!)
/datum/emote/proc/handle_emote_CD(var/mob/user)
	if(user.emote_cd == 2) return 1			// Cooldown emotes were disabled by an admin, prevent use
	if(user.emote_cd == 1) return 1		// Already on CD, prevent use

	user.emote_cd = 1		// Starting cooldown
	spawn(cooldown)
		if(user.emote_cd == 2) return 1		// Don't reset if cooldown emotes were disabled by an admin during the cooldown
		user.emote_cd = 0				// Cooldown complete, ready for more!

	return 0		// Proceed with emote
//--FalseIncarnate


/******************************************************************************************
								Emote Verbs
******************************************************************************************/

/datum/emote/proc/addVerbs(var/mob/user)
	if(!istype(user))
		return
	new /obj/emoteVerb(user, src, commands)

// Dummy object to allow access to the verb, needed as verbs require a valid loc for setting the src
/obj/emoteVerb
	var/datum/emote/emote
	var/mob/owner

/obj/emoteVerb/New(var/mob/user, var/datum/emote/toAccess)
	if(!(istype(user)))
		return
	if(!(istype(toAccess)))
		return
	if(!toAccess.commands)
		return
	owner = user
	emote = toAccess
	name = emote.name
	loc = user
	user.verbs += new/obj/emoteVerb/proc/runEmote(src, emote.commands[1], emote.desc)

/obj/emoteVerb/proc/runEmote()
	set src = usr.contents
	set category = "Emotes"
	usr.emoteHandler.runEmote(emote.commands[1])

/obj/emoteVerb/Destroy()
	owner.verbs -= new/obj/emoteVerb/proc/runEmote(src, emote.commands[1])
	..()

/obj/emoteVerb/custom

obj/emoteVerb/custom/New(var/mob/user)
	if(!(istype(user)))
		return
	owner = user
	name = "custom"
	user.verbs += new/obj/emoteVerb/proc/runEmote(src, "custom", "Make your own emote")

/obj/emoteVerb/custom/runEmote(message as text, audible as num)
	set src = usr.contents
	set category = "Emotes"
	usr.emoteHandler.runEmote("me", null, message, audible)


/**************************************************************************************************************************
												Custom Emotes
As these are made as needed, they aren't searched for the appropriate one. As such, you need to specify conditions for which
one is used in /datum/emote_handler/customEmote(). As the checks for the type are done there, you chouldn't need to override
available, but if you do, make sure you return ..() so the check for use_me is still done - VampyrBytes

***************************************************************************************************************************/

/datum/emote/custom
	name = "Custom emote"
	baseLevel = 0

/datum/emote/custom/New(var/mob/user, var/message = "", var/isAudible)
	if(!message)
		message = getMessage(user)
	text = message
	audible = isAudible
	if(user.mind && user.mind.miming)
		audible = 0

/datum/emote/custom/proc/getMessage(var/mob/user)
	var/input = sanitize(copytext(input(user,"Choose an emote to display.") as text|null,1,MAX_MESSAGE_LEN))
	return input

/datum/emote/custom/available(var/mob/user)
	if(user.use_me)
		return 1

// Yeah, no
/datum/emote/custom/createSelfMessage(var/mob/user, var/message = "")
	return message

/datum/emote/custom/ghost
	name = "Ghost emote"
	startText = "<span class='prefix'>DEAD: </span>"
	spanClass = "game deadsay"

/datum/emote/custom/ghost/prevented(var/mob/user)
	if(user.client.prefs.muted & MUTE_DEADCHAT)
		return "you are muted from deadchat"
	if(!(user.client.prefs.toggles & CHAT_DEAD))
		return "you have deadchat muted"
	if(!user.client.holder)
		if(!config.dsay_allowed)
			return "deadchat is globally muted"

/datum/emote/custom/ghost/outputMessage(var/mob/user, var/message = "")
	if(!message)
		return
	log_emote("Ghost/[user.key] : [message]")
	sendToDead(message)

