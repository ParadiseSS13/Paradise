/************************************************************************************
									Emotes
New() must call ..() to set the baseLevel for the emoteHandler search. As the commands
are set in New(), this means that the emote will pick up all the commands from the emotes
above it. If you don't want this, make the call to ..() then use commands = new /list()
*************************************************************************************/

/datum/emote/airguitar
	name = "airguitar"
	desc = "Play an air guitar"
	text = "is strumming the air and headbanging like a safari chimp."
	selfText = "are strumming the air and headbanging like a safari chimp."
	restrained = 1

/datum/emote/airguitar/New()
	..()
	commands += "airguitar"

/datum/emote/airguitar/available(var/mob/user)
	if(ishuman(user))
		return 1
	if(isrobot(user))
		return 1

/datum/emote/alarm
	name = "alarm"
	desc = "Sound an alarm"
	text = "sounds an alarm"
	selfText = "sound an alarm"
	audible = 1

/datum/emote/alarm/New()
	..()
	commands += "alarm"

/datum/emote/alarm/available(var/mob/user)
	if(isbrain(user))
		return 1

/datum/emote/alarm/createBlindMessage(var/mob/user, var/messaage)
	return "You hear an alarm"

/datum/emote/alert
	name = "alert"
	desc = "Sound an alert"
	text = "lets out a distressed noise"
	selfText = "let out a distressed noise)"
	audible = 1

/datum/emote/alert/New()
	..()
	commands += "alert"

/datum/emote/alert/available(var/mob/user)
	if(isbrain(user))
		return 1
/datum/emote/alert/createBlindMessage(var/mob/user, var/message)
	return "you hear an alert"

/datum/emote/beep
	name = "beep"
	desc = "let out a beep"
	text = "beeps"
	selfText = "beep"
	audible = 1

/datum/emote/beep/New()
	..()
	commands += "beep"
	commands += "beeps"

/datum/emote/beep/available(var/mob/user)
	if(isbrain(user))
		return 1

/datum/emote/beep/createBlindMessage(var/mob/user, var/message)
	return "You hear a beep"

/datum/emote/beep/targetted
	cooldown = 1
	sound = 'sound/machines/twobeep.ogg'
	canTarget = 1
	targetMob = 1

/datum/emote/beep/targetted/available(var/mob/user)
	if(issilicon(user))
		return 1
	if(isbot(user))
		return 1
	if(user.get_species() == "Machine")
		return 1

/datum/emote/blink
	name = "blink"
	desc = "blink"
	text = "blinks"
	selfText = "blink"

/datum/emote/blink/New()
	..()
	commands += "blink"
	commands += "blinks"

/datum/emote/blink/available(var/mob/user)
	if(ishuman(user))
		return 1
	if(isbrain(user))
		return 1

/datum/emote/blink/rapid
	name = "rapid blink"
	desc = "blink rapidly"
	allowParent = 1

/datum/emote/blink/rapid/New()
	..()
	commands = new/list()
	commands += "blink_r"
	commands += "blinks_r"

/datum/emote/blink/rapid/available(var/mob/user)
	if(ishuman(user))
		return

/datum/emote/blink/rapid/createMessage(var/mob/user, var/number)
	var/message = ..()
	message += " rapidly"
	return message

/datum/emote/blush
	name = "blush"
	desc = "blush"
	text = "blushes"
	selfText = "blush"

/datum/emote/blush/New()
	..()
	commands += "blush"
	commands += "blushes"

/datum/emote/blush/available(var/mob/user)
	if(ishuman(user))
		return 1

/datum/emote/boop
	name = "boop"
	desc = "boop"
	text = "boops"
	selfText = "boop"

/datum/emote/boop/New()
	..()
	commands += "boop"
	commands += "boops"

/datum/emote/boop/available(var/mob/user)
	if(isbrain(user))
		return 1

/datum/emote/bounce
	name = "bounce"
	desc = "bounce"
	text = "bounces in place"
	selfText = "bounce in place"

/datum/emote/bounce/New()
	..()
	commands += "bounce"
	commands += "bounces"

/datum/emote/bounce/available(var/mob/user)
	if(isslime(user))
		return 1

/datum/emote/bow
	name = "bow"
	desc = "bow"
	text = "bows"
	selfText = "bow"
	canTarget = 1
	targetMob = 1
	targetText = "to"

/datum/emote/bow/New()
	..()
	commands += "bow"
	commands += "bows"

/datum/emote/bow/available(var/mob/user)
	if(isrobot(user))
		return 1
	if(ishuman(user))
		return 1

/datum/emote/bow/prevented(var/mob/user)
	. = ..()
	if(!. && user.buckled)
		return "you are buckled to something"

/datum/emote/burp
	name = "burp"
	desc = "burp"
	text = "burps"
	selfText = "burp"
	muzzledNoise = "peculiar"


/datum/emote/scream
	name = "scream"
	text = "screams!"
	selfText = "scream!"
	audible = 1
	mimeText = "acts out a scream"
	muzzledNoise = "very loud "
	cooldown = 50
	vol = 80

/datum/emote/scream/New()
	..()
	commands += "scream"
	commands += "screams"

/datum/emote/scream/available(var/mob/user)
	if(isliving(user))
		return 1

/datum/emote/scream/machine
	name = "machine scream"
	sound = 'sound/goonstation/voice/robot_scream.ogg'

/datum/emote/scream/machine/available(var/mob/user)
	if(issilicon(user))
		return 1
	if(istype(user, /mob/living/simple_animal/bot))
		return 1

/datum/emote/scream/human
	name = "human scream"

/datum/emote/scream/human/available(var/mob/user)
	if(ishuman(user))
		return 1

/datum/emote/scream/human/playSound(var/mob/user)
	var/mob/living/carbon/human/H = user
	if(H.gender == FEMALE)
		playsound(H, "[H.species.female_scream_sound]", vol, 1, 0, pitch = H.get_age_pitch())
	else
		playsound(H, "[H.species.male_scream_sound]", vol, 1, 0, pitch = H.get_age_pitch())

/datum/emote/fart
	name = "fart"
	cooldown = 50

/datum/emote/fart/New()
	..()
	commands += "fart"
	commands += "farts"

/datum/emote/fart/available(var/mob/user)
	if(ishuman(user))
		return 1

/datum/emote/fart/doAction(var/mob/user)
	// todo change this to work with superfarts
	if(TOXIC_FARTS in user.mutations)
		for(var/mob/M in range(get_turf(user),2))
			if (M.internal != null && M.wear_mask && (M.wear_mask.flags & AIRTIGHT))
				continue
			if (M == user)
				continue
			M.reagents.add_reagent("space_drugs",rand(1,10))

	if(locate(/obj/item/weapon/storage/bible) in get_turf(user))
		to_chat(viewers(user), "<span class='warning'><b>[user] farts on the Bible!</b></span>")
		to_chat(viewers(user), "<span class='notice'><b>A mysterious force smites [user]!</b></span>")
		var/datum/effect/system/spark_spread/s = new /datum/effect/system/spark_spread
		s.set_up(3, 1, user)
		s.start()
		user.gib()

/datum/emote/fart/createMessage(var/mob/user)
	var/message
	if(TOXIC_FARTS in user.mutations)
		message = "<span class = '[spanClass]'>[user] unleashes a [pick("horrible","terrible","foul","disgusting","awful")] fart."
	else
		message = "<span class = '[spanClass]'>[user] [pick("passes wind","farts")]."
	return message


/datum/emote/signal
	name = "signal"
	desc = "raise x number of fingers"
	text = "raises"
	selfText = "raise"
	canTarget = 1
	restrained = 1
	targetMob = 1
	takesNumber = 1

/datum/emote/signal/New()
	..()
	commands += "signal"
	commands += "signals"

/datum/emote/signal/available(var/mob/user)
	if(ishuman(user))
		return 1

/datum/emote/signal/getNumber(var/mob/user)
	var/number = ..()
	var/fingersAvailable = 0
	if(!user.r_hand)
		fingersAvailable += 5
	if(!user.l_hand)
		fingersAvailable += 5
	if(fingersAvailable < number)
		to_chat(user, "You don't have enough fingers free")
		return "failed"
	return number

/datum/emote/signal/paramMessage(var/mob/user, var/param)
	var/message = "[user] raises [param] finger\s"
	testing(message)
	return message
