/*******************************************************************************************************
												Emotes
Remember, only 1 instance of each emote is made, and used by all mobs that can access it. As such, the
ONLY place you can safely set object variables during runtime is in New(). Otherwise override the emote.
The only exception to this is custom emotes, which are created as needed and only last until they are finished
VampyrBytes

*******************************************************************************************************/
#define EMOTE_COOLDOWN 20		//Time in deciseconds that the cooldown lasts
#define HEARING_RANGE 7
#define INVALID -1				//Using -1 as I can't see how a negative number could be a valid input

/datum/emote
	var/name = ""
	var/desc = ""
	var/list/commands[0]  // list of commands that trigger the emote.
	var/text = ""
	var/selfText = ""		// the version of text that you should see - eg, if text is screams, you want scream here, as You screams is bad grammer
	var/startText = ""		// if you need to put something in before [user]
	var/selfStart = 1		// whether the start text is used in what you see

	var/audible = 0
	var/mimeText = ""
	var/mimeSelf = ""		//self version of mimeText
	var/sound				// sound file
	var/vol = 50
	var/muzzleAffected = 0	// whether being muzzled affects this emote
	var/muzzledNoise = ""	// if the emote is audible and you're muzzled, this is what type of noise you make (eg weak, loud).
	var/cooldown = 0		// How long the cooldown should be on this emote. Defaults to EMOTE_COOLDOWN if not set and the emote plays a sound

	var/restrained = 0	// 1 if being restrained prevents this emote

	var/canTarget = 0		// 1 if the emote accepts a target
	var/targetMob = 0		// 0 if target can be any atom, 1 if it has to be a mob,
	var/mustTarget = 0		// 1 if the emote needs a target to work (won't get None as an option)
	var/targetText = "at" // what goes inbetween user and target
	var/takesNumber	= 0	// 1 if the emote uses a number parameter

	var/emoteSpanClass = "say"
	var/userSpanClass = "bold"
	var/baseLevel = 1
	var/allowParent = 0			// 1 if you want the parent available as well as this one


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

	if(sound && !cooldown)
		cooldown = EMOTE_COOLDOWN

	if(targetText)
		if(!findtextEx(targetText, " ", lentext(targetText)))
			targetText += " "

/datum/emote/proc/doEmote(var/mob/user, var/command = "")
	if(!istype(user))
		return
	if(cooldown)
		if(handle_emote_CD(user))
			return

	var/message = ""
	var/list/params[0]

	params = getParams(user)

	for(var/p in params)
		if(params[p] == INVALID)
			return

	if(text)
		message = createMessage(user, params)

	if(message)
		message = addExtras(user, params, message)
		. = processMessage(user, params, message)

	if(!doMime(user) && (!muzzleAffected || !isMuzzled(user)))
		if(playSound(user, params))
			. = 2

	doAction(user, params)

	for(var/obj/item/weapon/implant/I in user)
		if(I.implanted)
			I.trigger(command, user)

	return

// for things that the emote does that aren't text or sound based
/datum/emote/proc/doAction(var/mob/user, var/list/params)
	return

/datum/emote/proc/getParams(var/mob/user)
	var/list/params[0]

	if(takesNumber)
		user.set_typing_indicator(1)
		user.hud_typing = 1
		params["num"] = getNumber(user)
		user.hud_typing = 0
		user.set_typing_indicator(0)

	if(canTarget)
		user.set_typing_indicator(1)
		user.hud_typing = 1
		params["target"] = getTarget(user)
		user.hud_typing = 0
		user.set_typing_indicator(0)
	return params

// return INVALID from either of these getters if you've tested the input and it's failed
/datum/emote/proc/getNumber(var/mob/user)
	var/number = input("How many?", "Enter number") as null|num
	return number

/datum/emote/proc/getTarget(var/mob/user)
	if(user.sdisabilities & BLIND || user.blinded || user.paralysis)
		return
	var/list/targets = list()
	if(!mustTarget)
		targets += "None"
	var/target
	if(targetMob)
		target = getMobTarget(user, targets)
	else
		target = getAtomTarget(user, targets)
	if(!target)
		return INVALID
	if(target == "None")
		return
	return target

/datum/emote/proc/getMobTarget(var/mob/user, var/list/targets)
	for(var/mob/M in view(getLoc(user)))
		targets += M
	var/mob/target = input("Select target", "Target Mob") as null|anything in targets
	return target


/datum/emote/proc/getAtomTarget(var/mob/user, var/list/targets)
	for(var/A in oview(getLoc(user)))
		if(ismob(A) || isobj(A) || isturf(A))
			targets += A
	var/atom/target = input("Select target", "Target") as null|anything in targets
	return target

// returns the reason the user can't currently do the emote
/datum/emote/proc/prevented(var/mob/user)
	if(user.stat == DEAD)
		return "you are dead"
	if(user.stat == UNCONSCIOUS)
		return "you are unconscious"
	if(restrained && user.restrained())
		return "you are restrained"
	if(isbrain(user))
		var/mob/living/carbon/brain/brain = user
		if(!(brain.container && istype(brain.container, /obj/item/device/mmi)))
			return "you need to be in an mmi to do this"

// return 1 if this emote can be used by this type of user
/datum/emote/proc/available(var/mob/user)
	return

/datum/emote/proc/createMessage(var/mob/user, var/list/params)
	if(!text)
		return
	var/message = ""

	if(doMime(user))
		message = mimeMessage(user, params)
		if(message)
			return message

	if(muzzleAffected && isMuzzled(user))
		message = muzzleMessage(user, params)
		return message

	if(checkForParams(params))
		message = paramMessage(user, params)
		return message

	message = standardMessage(user, params)

	return message

/datum/emote/proc/isMuzzled(var/mob/user)
	if(user.sdisabilities & MUTE || user.is_muzzled())
		return 1
	if(!isliving(user))
		return
	var/mob/living/L = user
	if(L.silent)
		return 1

/datum/emote/proc/checkForParams(var/list/params)
	for(var/p in params)
		if(p == "target")
			continue
		return 1

/datum/emote/proc/addExtras(var/mob/user, var/list/params, var/message = "")
	if(!message)
		return
	if(startText)
		message = "[startText] [message]"
	message = addPunc(message)
	message = "<span class='[emoteSpanClass]'>[message]</span>"
	return message

/datum/emote/proc/addPunc(var/message = "")
	var/regex/endingPunc = new("\[\\.!\\?\"]$")
	if(!endingPunc.Find(message))
		message += "."
	return message

/datum/emote/proc/standardMessage(var/mob/user, var/list/params)
	var/message = "<span class='[userSpanClass]'>\The [user]</span> [text]"
	if("target" in params)
		message = addTarget(user, params, message)
	return message

/datum/emote/proc/mimeMessage(var/mob/user, var/list/params)
	if(!mimeText)
		return
	if(checkForParams(params))
		return paramMimeMessage(user, params)
	var/message = "<span class='[userSpanClass]'>\The [user]</span> [mimeText]"
	if(message && "target" in params)
		message = addTarget(user, params, message)
	return message

/datum/emote/proc/muzzleMessage(var/mob/user, var/list/params)
	var/message = "<span class='[userSpanClass]'>\The [user]</span> makes a "
	if(muzzledNoise)
		message += "[muzzledNoise] "
	message += "noise"
	return message

// if the emote takes a non target parameter, set up  and return the with parameter version in here
/datum/emote/proc/paramMessage(var/mob/user, var/list/params)
	return

// as above, but for mimes when there is mimeText
/datum/emote/proc/paramMimeMessage(var/mob/user, var/list/params)
	return

/datum/emote/proc/addTarget(var/mob/user, var/list/params, var/message = "")
	if(!canTarget)
		return message
	if(!params["target"])
		return message
	if(params["target"] == user)
		message += " [targetText][getHimself(user)]"
		return message
	message += " [targetText]\the [params["target"]]"
	return message


// What you should see when you perform the emote
/datum/emote/proc/createSelfMessage(var/mob/user, var/list/params, var/message = "")
	if(!selfText)
		return message

	message = replacetext(message, text, selfText)
	message = changeTextMacros(user, message)

	if(mimeSelf)
		message = replacetext(message, mimeText, mimeSelf)

	if(startText && !selfStart)
		var/start = findtextEx(message, startText)
		var/end = start + lentext(startText) + 1
		message = copytext(message, 1, start) + copytext(message, end, lentext(message) + 1)

	message = replaceMobWithYou(user, message, user)

	return message

/datum/emote/proc/replaceMobWithYou(var/mob/M, var/message = "", var/mob/user)	// user passed in in case an override needs to do something different if M != user (see johnny) VB

	message = replacetext(message, "\The [M]", "You")
	message = replacetext(message, "\the [M]", "you")

	return message

/datum/emote/proc/processMessage(var/mob/user, var/list/params, var/message = "")
	var/visualOrAudible = audible + 1
	if(doMime(user))
		visualOrAudible = 1

	log_emote("[user.name]/[user.key] : [message]")
	sendToDead(user, message)
	for(var/mob/M in getRecipients(getLoc(user, message), visualOrAudible))
		var/msg = ""

		if(M==user)
			msg = createSelfMessage(user, params, message)
			if(msg)
				outputMessage(M, msg, user)
				continue

		if(M.stat == UNCONSCIOUS || (M.sleeping && M.stat != DEAD))
			if(!visualOrAudible == 2)
				continue
			msg = "<span class='italics'>... You can almost hear someone talking ...</span>"
			outputMessage(M, msg, user)
			continue

		if(M.sdisabilities & DEAF || M.ear_deaf)
			if(M.sdisabilities & BLIND || M.blinded || M.paralysis)
				continue
			if(!(M in getRecipients(user, 1)) || M.see_invisible < user.invisibility)
				continue

			msg = createDeafMessage(user, params, message)
			if(!msg && visualOrAudible == 2)
				continue
			if(msg)
				outputMessage(M, msg, user)
				continue

		if(M.sdisabilities & BLIND || M.blinded || M.paralysis || (M.see_invisible < user.invisibility && visualOrAudible == 2))
			if(!(M in getRecipients(user, 2)))
				continue

			msg = createBlindMessage(user, params, message)
			if(!msg && visualOrAudible == 1)
				continue
			if(msg)
				outputMessage(M, msg, user)
				continue

		if(M.see_invisible < user.invisibility && visualOrAudible == 1)
			continue

		msg = message
		outputMessage(M, msg, user)

	if(visualOrAudible == 2)
		handleListeningObjects(user, message)

	return visualOrAudible

/datum/emote/proc/outputMessage(var/mob/M, var/msg = "", var/mob/user)
	msg = replaceMobWithYou(M, msg, user)
	to_chat(M, msg)

/datum/emote/proc/getLoc(var/mob/user, var/message = "")
	var/loc = checkForHolopad(user, message)
	if(loc)
		return loc
	return user

/datum/emote/proc/checkForHolopad(var/mob/user, var/message = "")
	if(!isAI(user))
		return
	var/mob/living/silicon/ai/AI = user
	var/obj/machinery/hologram/holopad/T = AI.holo
	if(!(T && T.hologram && T.master == AI))
		return
	if(message)
		to_chat(AI, "<span class='game say'>Holopad action relayed, <span class='message'>[message]</span></span>")
	return T

/datum/emote/proc/handleListeningObjects(var/mob/user, var/message = "")
	// based on say code
	var/omsg = replacetext(message, "<B>[user]</B> ", "")
	var/list/listening_obj = new
	for(var/atom/movable/A in view(HEARING_RANGE, user))
		if(istype(A, /mob))
			var/mob/M = A
			for(var/obj/O in M.contents)
				listening_obj |= O
		else if(istype(A, /obj))
			var/obj/O = A
			listening_obj |= O
	for(var/obj/O in listening_obj)
		O.hear_message(user, omsg)

/datum/emote/proc/getRecipients(var/location, var/visualOrAudible)
	if(visualOrAudible == 1)
		return viewers(location)
	return get_mobs_in_view(HEARING_RANGE, location)

// set up different messages for blind people here. Empty will mean no message for
//non-audible emotes and the standard message for audible ones
/datum/emote/proc/createBlindMessage(var/mob/user, var/list/params, var/message)
	if(audible && selfText)
		message = "<span class='[userSpanClass]'>You</span> hear someone [selfText]"
		message = addExtras(message)
	return message

// set up different messages for deaf people here. Empty will mean no message for
// audible emotes and standard for non-audible ones
/datum/emote/proc/createDeafMessage(var/mob/user, var/list/params, var/message)
	message = mimeMessage(user, params)
	message = addExtras(message)
	return message

/datum/emote/proc/sendToDead(var/mob/user, var/message = "", var/ghostEmote)
	for(var/mob/M in dead_mob_list)
		if(!M.client || istype(M, /mob/new_player))
			continue //skip monkeys, leavers and new players
		if(M.stat == DEAD)
			if(ghostEmote && ((M.client.prefs.toggles & CHAT_GHOSTSIGHT) || (M in viewers(user))))
				M.show_message(message)
			else if((M.client.prefs.toggles & CHAT_GHOSTSIGHT) && !(M in viewers(user)))
				M.show_message(message)

/datum/emote/proc/playSound(var/mob/user, var/list/params)
	if(!sound)
		return
	playsound(user, sound, vol)
	return 1

/datum/emote/proc/doMime(var/mob/user)
	if(mimeText && user.mind && user.mind.miming)
		return 1

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

/datum/emote/proc/changeTextMacros(var/mob/user, var/message = "")
	message = swapHisToYour(user, message)
	message = swapHimselfToYourself(user, message)
	return message

/datum/emote/proc/getHis(var/mob/user)
	var/his = "[user]\his"
	his = copytext(his, lentext("[user]") + 1)
	return his

/datum/emote/proc/swapHisToYour(var/mob/user, var/message = "")
	var/his = getHis(user)
	message = replacetext(message, " [his] ", " your ")
	return message

/datum/emote/proc/getHimself(var/mob/user)
	var/himself = "[user]\himself"
	himself = copytext(himself, lentext("[user]") + 1)
	return himself

/datum/emote/proc/swapHimselfToYourself(var/mob/user, var/message)
	var/himself = getHimself(user)
	message = replacetext(message, "[himself]", "yourself")
	return message

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
	name = "[emote]"
	loc = user
	user.verbs += new/obj/emoteVerb/proc/runEmote(src, emote.commands[1], emote.desc)

/obj/emoteVerb/proc/runEmote()
	set src = usr.contents
	set category = "Emotes"
	return usr.emoteHandler.runEmote(emote.commands[1])

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

/obj/emoteVerb/custom/runEmote()
	set src = usr.contents
	set category = "Emotes"
	return usr.emoteHandler.runEmote("me")



/**************************************************************************************************************************
												Custom Emotes
As these are made as needed, they aren't searched for the appropriate one. As such, you need to specify conditions for which
one is used in /datum/emote_handler/customEmote().

***************************************************************************************************************************/

/datum/emote/custom
	name = "Custom emote"
	baseLevel = 0

/datum/emote/custom/New(var/mob/user, var/message = "", var/isAudible)
	if(!message)
		message = getMessage(user)
	text = message
	audible = isAudible

/datum/emote/custom/proc/getMessage(var/mob/user)
//	user.set_typing_indicator(1)
//	user.hud_typing = 1
	var/input = copytext(input(user,"What do you want to emote?", "Custom emote") as text|null,1,MAX_MESSAGE_LEN)
//	user.hud_typing = 0
//	user.set_typing_indicator(0)
	input = trim_strip_html_properly(input)
	return input

/datum/emote/custom/available(var/mob/user)
	return 1

/datum/emote/custom/prevented(var/mob/user)
	if(!user.use_me)
		return "you are prevented from using custom emotes"

// Yeah, no
/datum/emote/custom/createSelfMessage(var/mob/user, var/list/params, var/message = "")
	return

/datum/emote/custom/replaceMobWithYou(var/mob/M, var/message = "", var/mob/user)
	return message

/datum/emote/custom/ghost
	name = "Ghost emote"
	startText = "<span class='prefix'>DEAD: </span>"
	emoteSpanClass = "game deadsay"

/datum/emote/custom/ghost/prevented(var/mob/user)
	. = ..()
	if(.)
		return
	if(user.client.prefs.muted & MUTE_DEADCHAT)
		return "you are muted from deadchat"
	if(!(user.client.prefs.toggles & CHAT_DEAD))
		return "you have deadchat muted"
	if(!user.client.holder)
		if(!config.dsay_allowed)
			return "deadchat is globally muted"

/datum/emote/custom/ghost/getMessage(var/mob/user)
	var/input = copytext(input(user,"What do you want to emote?", "Custom emote") as text|null,1,MAX_MESSAGE_LEN)
	input = trim_strip_html_properly(input)
	return input

/datum/emote/custom/ghost/processMessage(var/mob/user, var/list/params, var/message = "")
	if(!message)
		return
	log_emote("Ghost/[user.key] : [message]")
	sendToDead(user, message, ghostEmote = 1)

