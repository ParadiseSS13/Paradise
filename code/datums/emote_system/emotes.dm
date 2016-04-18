/************************************************************************************
									Emotes
New() must call ..() to set the baseLevel for the emoteHandler search. As the commands
are set in New(), this means that the emote will pick up all the commands from the emotes
above it. If you don't want this, make the call to ..() then use commands = new /list()
*************************************************************************************/

/datum/emote/scream
	name = "scream"
	text = "screams!"
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
	text = null

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



