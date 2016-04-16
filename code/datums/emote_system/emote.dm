/*******************************************************************************************************
												Emotes
Remember, only 1 instance of each emote is made, and used by all mobs that can access it. As such, the
ONLY place you can safely set object variables during runtime is in New(). Otherwise override the emote.
The only exception to this is custom emotes, which are created as needed and only last until they are finished
VampyrBytes

*******************************************************************************************************/

/datum/emote
	var/name = ""
	var/list/commands[0]  // commands that trigger the emote. Set these in New()
	var/text = ""
	var/startText = ""		// if you need to put something in before [user]. Should end with a space
	var/mimeText = ""
	var/sound				// sound file
	var/vol = 50
	var/audible = 0
	var/muzzledNoise = ""	// if the emote is audible and you're muzzled, this is what type of noise you make (eg weak, loud). End with a space
	var/restrained = ""		// 1 if being restrained prevents this emote
	var/cooldown = 0

	var/canTarget = 0		// 1 if the emote accepts a target			Emotes only recieve 1 parameter, so its either or with these 2
	var/takesParam	= 0	// 1 if the emote uses a non target parameter

	var/targetMob = 0		// 0 if target can be any atom, 1 if it has to be a mob
	var/targetText = "at" // what goes inbetween user and target
	var/spanClass = "notice"
	var/baseLevel = 1
	var/baseSet = 0


/datum/emote/New()
	var/pathString = "[type]"
	var/count
	for(var/i in 1 to lentext(pathString))
		var/char = copytext(pathString, i, i+1)
		if(char == "/")
			count++
			if(count == 4)
				baseLevel = 0
				break

/datum/emote/proc/doEmote(var/mob/user, var/param)
	if(cooldown)
		if(handle_emote_CD(user))
			return 0

	var/message = createMessage(user, param)

	if(canTarget && param)
		param = getTarget(user, param)

	if(message)
		message = addTarget(user, param, message)
		message += "</span>"
		outputMessage(user, message)

	if(audible)
		if(!(user.mind && user.mind.miming))
			playSound(user, vol)

	doAction(user, param)
	return 1

// for things that the emote does that aren't text or sound based
/datum/emote/proc/doAction(var/mob/user, var/param)
	return

// returns the reason the user can't currently do the emote
/datum/emote/proc/prevented(var/mob/user)
	if(user.stat == DEAD)
		return "you are dead"
	if(restrained && user.restrained())
		return "you are restrained"

// return 1 if this emote can be used by this type of user
/datum/emote/proc/available(var/mob/user)
	return

/datum/emote/proc/createMessage(var/mob/user, var/param)
	if(!text)
		return
	var/message
	if(audible && user.mind && user.mind.miming)
		message = mimeMessage(user)
	else if(audible && user.is_muzzled())
		message = muzzleMessage(user)
	else if(takesParam && param)
		message = paramMessage(user, param)
	else
		message = "<span class = '[spanClass]'>[startText + " "][user] [text]"
	return message

/datum/emote/proc/mimeMessage(var/mob/user)
	if(!mimeText)
		return

	var/message = "<span class = '[spanClass]'>[startText + " "][user] [mimeText]"
	return message

/datum/emote/proc/muzzleMessage(var/mob/user)
	var/message = "<span class = '[spanClass]'>makes a [muzzledNoise + " "]noise"
	return message

// if the emote takes a non target parameter, set up  and return the with parameter version in here
/datum/emote/proc/paramMessage(var/mob/user, var/param)
	return

/datum/emote/proc/addTarget(var/mob/user, var/target, var/message)
	if(!canTarget)
		return message
	target = getTarget(user, target)
	if(!target)
		return message
	if(ismob(target))
		message += " [targetText] [target]"
	else
		message += " [targetText] \the [target]"
	return message

/datum/emote/proc/getTarget(var/mob/user, var/target)
	if(!target)
		return
	if(targetMob)
		return getMobTarget(user, target)
	else
		return getAtomTarget(user, target)

/datum/emote/proc/getMobTarget(var/mob/user, var/target)
	for (var/mob/M in view(null, user))
		if (target == M.name)
			return M

/datum/emote/proc/getAtomTarget(var/mob/user, var/target)
	if (target)
		for (var/atom/A as mob|obj|turf in view(null, user))
			if (target == A.name)
				return A

/datum/emote/proc/outputMessage(var/mob/user, var/message)
	if(!message)
		return
	log_emote("[user.name]/[user.key] : [message]")
	if(audible)
		user.audible_message(message)
	else
		user.visible_message(message)
	sendToDead(message)

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

/**************************************************************************************************************************
												Custom Emotes
As these are made as needed, they aren't searched for the appropriate one. As such, you need to specify conditions for which
one is used in /datum/emote_handler/customEmote(). As the checks for the type are done there, you chouldn't need to override
available, but if you do, make sure you return ..() so the check for use_me is still done - VampyrBytes

***************************************************************************************************************************/

/datum/emote/custom
	name = "Custom emote"
	baseLevel = 0

/datum/emote/custom/New(var/mob/user, var/message, var/isAudible)
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

/datum/emote/custom/ghost/outputMessage(var/mob/user, var/message)
	if(!message)
		return
	log_emote("Ghost/[user.key] : [message]")
	sendToDead(message)

