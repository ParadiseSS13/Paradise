/************************************************************************************
									Emotes
New() must call ..() to set the baseLevel for the emoteHandler search. As the commands
are set in New(), this means that the emote will pick up all the commands from the emotes
above it. If you don't want this, make the call to ..() then use commands.cut()
*************************************************************************************/

/datum/emote/airguitar
	name = "airguitar"
	desc = "Makes the mob play an air guitar"
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
	desc = "makes the mob sound an alarm"
	text = "sounds an alarm"
	selfText = "sound an alarm"
	audible = 1

/datum/emote/alarm/New()
	..()
	commands += "alarm"

/datum/emote/alarm/available(var/mob/user)
	if(isbrain(user))
		return 1

/datum/emote/alarm/createBlindMessage(var/mob/user, var/params, var/messaage)
	return "You hear an alarm"

/datum/emote/alert
	name = "alert"
	desc = "Makes the mob sound an alert"
	text = "lets out a distressed noise"
	selfText = "let out a distressed noise"
	audible = 1

/datum/emote/alert/New()
	..()
	commands += "alert"

/datum/emote/alert/available(var/mob/user)
	if(isbrain(user))
		return 1

/datum/emote/beep
	name = "beep"
	desc = "makes the mob let out a beep"
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

/datum/emote/beep/targetted
	sound = 'sound/machines/twobeep.ogg'
	cooldown = 50
	canTarget = 1
	targetMob = 1

/datum/emote/beep/targetted/available(var/mob/user)
	if(user.is_mechanical())
		return 1

/datum/emote/blink
	name = "blink"
	desc = "Makes the mob blink"
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
	desc = "Makes the mob blink rapidly"
	allowParent = 1

/datum/emote/blink/rapid/New()
	..()
	commands = new /list()
	commands += "blink_r"
	commands += "blinks_r"

/datum/emote/blink/rapid/available(var/mob/user)
	if(ishuman(user))
		return 1

/datum/emote/blink/rapid/standardMessage(var/mob/user)
	var/message = ..()
	message += " rapidly"
	return message

/datum/emote/blush
	name = "blush"
	desc = "Makes the mob blush"
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
	desc = "Makes the mob boop"
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
	desc = "Makes the mob bounce"
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
	desc = "Makes the mob bow"
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
	desc = "Makes the mob burp"
	text = "burps"
	selfText = "burp"
	audible = 1
	mimeText = "opens their mouth rather obnoxiously"
	mimeSelf = "open your mouth rather obnoxiously"
	muzzleAffected = 1
	muzzledNoise = "peculiar"

/datum/emote/burp/New()
	..()
	commands += "burp"
	commands += "burps"

/datum/emote/burp/available(var/mob/user)
	if(ishuman(user))
		return 1
	if(islarva(user) || isalienadult(user))
		return 1

/datum/emote/buzz
	name = "buzz"
	desc = "Makes the mob buzz"
	text = "buzzes"
	selfText = "buzz"
	audible = 1
	sound = 'sound/machines/buzz-sigh.ogg'
	cooldown = 50
	canTarget = 1
	targetMob = 1

/datum/emote/buzz/New()
	..()
	commands += "buzz"
	commands += "buzzes"
	commands += "buzzs"

/datum/emote/buzz/available(var/mob/user)
	if(user.is_mechanical())
		return 1

/datum/emote/chirp
	name = "chirp"
	desc = "Makes the mob chirp"
	text = "chirps"
	selfText = "chirp"
	audible = 1
	sound = 'sound/misc/nymphchirp.ogg'
	vol = 40
	cooldown = 50

/datum/emote/chirp/New()
	..()
	commands += "chirp"
	commands += "chirps"

/datum/emote/chirp/available(var/mob/user)
	if(istype(user, /mob/living/simple_animal/diona))
		return 1

/datum/emote/chirp/playSound(var/mob/user)
	if (!sound)
		return
	playsound(user, sound, vol, 1, 1)
	return 1

/datum/emote/choke
	name = "choke"
	desc = "Makes the mob choke"
	text = "chokes"
	selfText = "choke"
	audible = 1
	mimeText = "clutches"
	mimeSelf = "clutch"
	muzzleAffected = 1
	muzzledNoise = "strong"

/datum/emote/choke/New()
	..()
	commands += "choke"
	commands += "chokes"

/datum/emote/choke/available(var/mob/user)
	if(ishuman(user))
		return 1
	if(islarva(user) || isalienadult(user))
		return 1

// This has to be done here not mimeText because \his will throw a compile error
// instead of a runtime if there's not a valid target in the string *frown VB
/datum/emote/choke/mimeMessage(var/mob/user, var/list/params)
	var/message = "[user] [mimeText] \his throat desperately"
	return message

/datum/emote/chuckle
	name = "chuckle"
	desc = "chuckle"
	text = "chuckles"
	selfText = "chuckle"
	audible = 1
	mimeText = "appears to chuckle"
	mimeSelf = "appear to chuckle"
	muzzleAffected = 1

/datum/emote/chuckle/New()
	..()
	commands += "chuckle"
	commands += "chuckles"

/datum/emote/chuckle/available(var/mob/user)
	if(ishuman(user))
		return 1

/datum/emote/clap
	name = "clap"
	desc = "clap"
	text = "claps"
	selfText = "clap"
	audible = 1
	mimeText = "claps silently"
	restrained = 1

/datum/emote/clap/New()
	..()
	commands += "clap"
	commands += "claps"

/datum/emote/clap/available(var/mob/user)
	if(isrobot(user))
		return 1
	if(ishuman(user))
		return 1

/datum/emote/collapse
	name = "collapse"
	desc = "Makes the mob collapse"
	text = "collapses"
	selfText = "collapse"
	audible = 1
	mimeText = "collapses without a sound"

/datum/emote/collapse/New()
	..()
	commands += "collapse"
	commands += "collapses"

/datum/emote/collapse/available(var/mob/user)
	if(islarva(user))
		return 1
	if(ishuman(user))
		return 1

/datum/emote/collapse/doAction(var/mob/user, var/list/params)
	user.Paralyse(2)

/datum/emote/cough
	name = "cough"
	desc = "Makes the mob cough"
	text = "coughs"
	selfText = "cough"
	audible = 1
	mimeText = "appears to cough"
	mimeSelf = "appear to cough"
	muzzleAffected = 1
	muzzledNoise = "strong"

/datum/emote/cough/New()
	..()
	commands += "cough"
	commands += "coughs"

/datum/emote/cough/available(var/mob/user)
	if(ishuman(user))
		return 1

/datum/emote/cry
	name = "cry"
	desc = "Makes the mob cry"
	text = "cries"
	selfText = "cry"
	audible = 1
	mimeText = "cries silently"
	muzzleAffected = 1
	muzzledNoise = "weak"

/datum/emote/cry/New()
	..()
	commands += "cry"
	commands += "cries"

/datum/emote/cry/available(var/mob/user)
	if(ishuman(user))
		return 1

/datum/emote/dance
	name = "dance"
	desc = "makes the mob dance around happily"
	text = "dances around happily"
	selfText = "dance around happily"
	restrained = 1

/datum/emote/dance/New()
	..()
	commands += "dance"
	commands += "dances"

/datum/emote/dance/available(var/mob/user)
	if(islarva(user))
		return 1

/datum/emote/dap
	name = "dap"
	desc = "Makes the mob give daps"
	text = "gives daps"
	selfText = "give daps"
	restrained = 1
	canTarget = 1
	targetMob = 1
	targetText = "to"

/datum/emote/dap/New()
	..()
	commands += "dap"
	commands += "daps"

/datum/emote/dap/available(var/mob/user)
	if(ishuman(user))
		return 1

/datum/emote/dap/addTarget(var/mob/user, var/list/params, var/message = "")
	if(!params["target"] || params["target"] == user)
		message = "<span class = '[userSpanClass]'>[user]</span> sadly can't find anybody to give daps to, and daps \himself. Shameful."
		return message
	return ..()

/datum/emote/deathgasp
	name = "deathgasp"
	desc = "Makes the mob let out it's final gasp"
	audible = 1

/datum/emote/deathgasp/New()
	..()
	commands += "deathgasp"
	commands += "deathgasps"

/datum/emote/deathgasp/alien
	text = "lets out a waning guttural screech, green blood bubbling from its maw..."
	selfText = "let out a waning guttural screech, green blood bubbling from your maw..."

/datum/emote/deathgasp/alien/available(var/mob/user)
	if(isalienadult(user))
		return 1

// sorry, no selftext for humans as we'd have to add a var to species for it and that's yuk - VB
/datum/emote/deathgasp/human
	text = "dummytext"

/datum/emote/deathgasp/human/available(var/mob/user)
	if(ishuman(user))
		return 1

/datum/emote/deathgasp/human/standardMessage(var/mob/user, var/list/params)
	var/mob/living/carbon/human/U = user
	var/message = "<span class = '[userSpanClass]'>\The [user]</span> [U.species.death_message]"
	return message

/datum/emote/deathgasp/robot
	text = "shudders violently for a moment, then becomes motionless, its eyes slowly darkening."
	selfText = "shudder violently for a moment, then become motionless, your eyes slowly darkening."
	audible = 0

/datum/emote/drone
	name = "drone"
	desc = "Makes the mob drone and rumble"
	text = "rumbles"
	selfText = "rumble"
	audible = 1
	sound = 'sound/voice/DraskTalk.ogg'
	canTarget = 1
	targetMob = 1

/datum/emote/drone/New()
	..()
	commands += "drone"
	commands += "drones"
	commands += "rumble"
	commands += "rumbles"
	commands += "hum"
	commands += "hums"

/datum/emote/drone/available(var/mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(H.species == "Drask")
		return 1

/datum/emote/drone/addTarget(var/mob/user, var/list/params, var/message)
	var/msg = ..()
	if(msg == message)
		return message
	message = replacetext(message, "rumbles", "drones")
	return message

/datum/emote/drone/createSelfMessage(var/mob/user, var/list/params, var/message)
	message = ..()
	message = replacetext(message, "drones", "drone")
	return message

/datum/emote/deathgasp/robot/available(var/mob/user)
	if(isrobot(user))
		return 1

/datum/emote/drool
	name = "drool"
	desc = "Makes the mob drool"
	text = "drools"
	selfText = "drool"

/datum/emote/drool/New()
	..()
	commands += "drool"
	commands += "drools"

/datum/emote/drool/available(var/mob/user)
	if(isalienadult(user) || islarva(user))
		return 1
	if(ishuman(user))
		return 1

/datum/emote/eyebrow
	name = "eyebrow"
	desc = "Makes the mob raise an eyebrow"
	text = "raises an eyebrow"
	selfText = "raise an eyebrow"

/datum/emote/eyebrow/New()
	..()
	commands += "eyebrow"

/datum/emote/eyebrow/available(var/mob/user)
	if(ishuman(user))
		return 1

/datum/emote/faint
	name = "faint"
	desc = "makes the mob faint"
	text = "faints"
	selfText = "faint"

/datum/emote/faint/New()
	..()
	commands += "faint"
	commands += "faints"

/datum/emote/faint/available(var/mob/user)
	if(ishuman(user))
		return 1

/datum/emote/faint/doAction(var/mob/user, var/list/params)
	if(!user.sleeping)
		user.sleeping += 1

/datum/emote/fart
	name = "fart"
	text = "farts"
	selfText = "fart"
	cooldown = 50
	audible = 1

/datum/emote/fart/New()
	..()
	commands += "fart"
	commands += "farts"

/datum/emote/fart/available(var/mob/user)
	if(ishuman(user))
		return 1

/datum/emote/fart/standardMessage(var/mob/user)
	var/message
	if(SUPER_FART in user.mutations)
		return			// super fart will make the message when triggered

	if(TOXIC_FARTS in user.mutations)
		message = "<span class = '[emoteSpanClass]'><span class = '[userSpanClass]'>\The [user]</span> unleashes a [pick("horrible","terrible","foul","disgusting","awful")] fart.</span>"
	else
		message = "<span class = '[emoteSpanClass]'><span class = '[userSpanClass]'>\The [user]</span> [pick("passes wind","farts")].</span>"
	return message

/datum/emote/fart/createSelfMessage(var/mob/user, var/list/params, var/message)
	message = ..()
	message = replacetext(message, "unleashes", "unleash")
	message = replacetext(message, "passes", "pass")
	return message

/datum/emote/fart/doAction(var/mob/user)
	if(TOXIC_FARTS in user.mutations)
		for(var/mob/M in range(get_turf(user),2))
			if (M.internal != null && M.wear_mask && (M.wear_mask.flags & AIRTIGHT))
				continue
			if (M == user)
				continue
			M.reagents.add_reagent("space_drugs",rand(1,10))

	if(SUPER_FART in user.mutations)
		var/mob/living/U = user
		for(var/datum/action/spell_action/spell in U.actions)
			if (spell.name == "Super Fart")
				spell.Trigger()
				break

	if(locate(/obj/item/weapon/storage/bible) in get_turf(user))
		if(SUPER_FART in user.mutations)
			sleep(30)			// need to wait for them to finish the super fart before gibbing them

		to_chat(viewers(user), "<span class='warning'><b>[user] farted on the Bible!</b></span>")
		to_chat(viewers(user), "<span class='notice'><b>A mysterious force smites [user]!</b></span>")
		var/datum/effect/system/spark_spread/s = new /datum/effect/system/spark_spread
		s.set_up(3, 1, user)
		s.start()
		user.gib()

/datum/emote/flap
	name = "flap"
	desc = "Makes the mob flap their wings"
	text = "flaps"
	selfText = "flap"
	restrained = 1
	audible = 1

/datum/emote/flap/New()
	..()
	commands += "flap"
	commands += "flaps"

/datum/emote/flap/available(var/mob/user)
	if(ishuman(user))
		return 1
	if(isrobot(user))
		return 1

/datum/emote/flap/standardMessage(var/mob/user, var/list/params)
	var/message = "<span class = '[userSpanClass]'>\The [user]</span> [text] \his wings"
	return message

/datum/emote/flap/angry
	name = "angry flap"
	desc = "makes the mob flap their wings angrily"
	allowParent = 1

/datum/emote/flap/angry/New()
	..()
	commands = new /list()
	commands += "a_flap"
	commands += "a_flaps"

/datum/emote/flap/angry/standardMessage(var/mob/user)
	var/message = ..()
	message += " angrily"
	return message

/datum/emote/flash
	name = "flash"
	desc = "Makes the lights on the mob flash quickly"
	text = "flash quickly"
	selfText = "flash quickly"
	startText = "The lights on"

/datum/emote/flash/New()
	..()
	commands += "flash"
	commands += "flashes"

/datum/emote/flash/available(var/mob/user)
	if(isbrain(user))
		return 1

/datum/emote/flip
	name = "flip"
	desc = "Makes the mob flip, possibly in the direction of someone"
	text = "flips"
	selfText = "flip"
	canTarget = 1
	targetMob = 1
	targetText = "in"

/datum/emote/flip/New()
	..()
	commands += "flip"
	commands += "flips"

/datum/emote/flip/available(var/mob/user)
	if(isrobot(user))
		return 1

/datum/emote/flip/prevented(var/mob/user)
	. = ..()
	if(!. && user.buckled)
		return "you are buckled to something"

/datum/emote/flip/createMessage(var/mob/user, var/list/params)
	var/message = ""
	if(user.lying || user.weakened)
		message = "<span class = '[userSpanClass]'>\The [user]</span> flops and flails around on the floor."
	else
		message = ..()
	return message

/datum/emote/flip/addTarget(var/mob/user, var/list/params, var/message)
	message = ..()
	if(params["target"])
		message += "'s general direction"
	return message

/datum/emote/flip/createSelfMessage(var/mob/user, var/list/params, var/message)
	message = ..()
	message = replacetext(message, "flops", "flop")
	message = replacetext(message, "flails", "flail")
	return message

/datum/emote/flip/doAction(var/mob/user, var/list/params, var/message)
	if(user.lying || user.weakened)
		return
	user.SpinAnimation(5,1)

/datum/emote/flip/flipOver
	desc = "Makes the mob flip, possibly in the direction of, or even over someone"

/datum/emote/flip/flipOver/available(var/mob/user)
	if(ishuman(user))
		return 1

/datum/emote/flip/flipOver/createMessage(var/mob/user, var/params)
	var/message = ""
	var/obj/item/weapon/grab/G = user.get_active_hand()
	if(istype(G) && G.affecting && !G.affecting.buckled)
		params["target"] = G.affecting
		message = "<span class = '[userSpanClass]'>\The [user]</span> [text] over [params["target"]]!"
		return message
	return ..()

/datum/emote/flip/flipOver/doAction(var/mob/user, var/params, var/message)
	var/obj/item/weapon/grab/G = user.get_active_hand()
	if(G == params["target"])
		var/turf/oldloc = user.loc
		var/turf/newloc = G.affecting.loc
		if(isturf(oldloc) && isturf(newloc))
			user.SpinAnimation(5,1)
			user.forceMove(newloc)
			G.affecting.forceMove(oldloc)
			return
	..()

/datum/emote/frown
	name = "frown"
	desc = "Makes the mob frown"
	text = "frowns"
	selfText = "frown"

/datum/emote/frown/New()
	..()
	commands += "frown"
	commands += "frowns"

/datum/emote/frown/available(var/mob/user)
	if(ishuman(user))
		return 1

/datum/emote/gasp
	name = "gasp"
	desc = "Makes the mob gasp"
	text = "gasps"
	selfText = "gasp"
	audible = 1
	mimeText = "appears to be gasping"
	mimeSelf = "appear to be gasping"
	muzzleAffected = 1
	muzzledNoise = "weak"

/datum/emote/gasp/New()
	..()
	commands += "gasp"
	commands += "gasps"

/datum/emote/gasp/available(var/mob/user)
	if(isalienadult(user) || islarva(user))
		return 1
	if(ishuman(user))
		return 1

/datum/emote/giggle
	name = "giggle"
	desc = "Makes the mob giggle"
	text = "giggles"
	selfText = "giggle"
	audible = 1
	mimeText = "giggles silently"
	muzzleAffected = 1

/datum/emote/giggle/New()
	..()
	commands += "giggle"
	commands += "giggles"

/datum/emote/giggle/available(var/mob/user)
	if(ishuman(user))
		return 1

/datum/emote/glare
	name = "glare"
	desc = "Makes the mob glare"
	text = "glares"
	selfText = "glare"
	canTarget = 1
	targetMob = 1

/datum/emote/glare/New()
	..()
	commands += "glare"
	commands += "glares"

/datum/emote/glare/available(var/mob/user)
	if(ishuman(user))
		return 1
	if(isrobot(user))
		return 1

/datum/emote/gnarl
	name = "gnarl"
	desc = "Makes the mob grarl and show its teeth"
	text = "gnarls and shows its teeth"
	selfText = "gnarl and show your teeth"
	audible = 1
	muzzleAffected = 1

/datum/emote/gnarl/New()
	..()
	commands += "gnarl"
	commands += "gnarls"

/datum/emote/gnarl/available(var/mob/user)
	if(islarva(user))
		return 1

/datum/emote/grin
	name = "grin"
	desc = "Makes the mob grin"
	text = "grins"
	selfText = "grin"

/datum/emote/grin/New()
	..()
	commands += "grin"
	commands += "grins"

/datum/emote/grin/available(var/mob/user)
	if(ishuman(user))
		return 1

/datum/emote/groan
	name = "groan"
	desc = "Makes the mob groan"
	text = "groans"
	selfText = "groan"
	audible = 1
	mimeText = "appears to groan"
	mimeSelf = "appear to groan"
	muzzleAffected = 1

/datum/emote/groan/New()
	..()
	commands += "groan"
	commands += "groans"

/datum/emote/available(var/mob/user)
	if(ishuman(user))
		return 1

/datum/emote/grumble
	name = "grumble"
	desc = "Makes the mob grumble"
	text = "grumbles"
	selfText = "grumble"
	audible = 1
	mimeText = "grumbles"
	muzzleAffected = 1

/datum/emote/grumble/New()
	..()
	commands += "grumble"
	commands += "grumbles"

/datum/emote/grumble/available(var/mob/user)
	if(ishuman(user))
		return 1

/datum/emote/halt
	name = "halt"
	desc = "Makes the mob sound a halt warning. Only available with a security module"
	text = "'s speakers skreech, \"Halt! Security!\"."
	selfText = " speakers skreech, \"Halt! Security!\"."
	audible = 1
	sound = 'sound/voice/halt.ogg'

/datum/emote/halt/New()
	..()
	commands += "halt"

/datum/emote/halt/available(var/mob/user)
	if(isrobot(user))
		return 1

/datum/emote/halt/prevented(var/mob/user)
	. = ..()
	if(.)
		return
	var/mob/living/silicon/robot/U = user
	if (!(istype(U.module, /obj/item/weapon/robot_module/security)))
		return "you are not security"

/datum/emote/halt/standardMessage(var/mob/user)
	var/message = "<span class = '[userSpanClass]'>\The [user]</span>[text]"
	return message

/datum/emote/handshake
	name = "handshake"
	desc = "Makes the mob shake hands with a target"
	text = "shakes hands"
	selfText = "shake hands"
	canTarget = 1
	targetMob = 1
	targetText = "with"
	restrained = 1

/datum/emote/handshake/New()
	..()
	commands += "handshake"

/datum/emote/handshake/prevented(var/mob/user)
	. = ..()
	if(!. && user.r_hand)
		return "you need your right hand free"

/datum/emote/handshake/getMobTarget(var/mob/user)
	var/mob/target = ..()
	if(!target)
		to_chat(user, "You need someone to shake hands with")
		return "invalid"

/datum/emote/handshake/addTarget(var/mob/user, var/list/params, var/message)
	var/mob/target = params["target"]
	if(target.r_hand)
		message = "<span class = '[userSpanClass]'>\The [user] holds out his hand to [params["target"]]"
		return message
	return ..()

/datum/emote/hiss
	name = "hiss"
	desc = "Makes the mob hiss"
	text = "hisses"
	selfText = "hiss"
	audible = 1

/datum/emote/hiss/New()
	..()
	commands += "hiss"
	commands += "hisses"

/datum/emote/hiss/available(var/mob/user)
	if(isalienadult(user) || islarva(user))
		return 1

/datum/emote/hug
	name = "hug"
	desc = "Makes the mob hug a target or themselves"
	text = "hugs"
	selfText = "hug"
	canTarget = 1
	targetMob = 1

/datum/emote/hug/New()
	..()
	commands += "hug"
	commands += "hugs"

/datum/emote/hug/available(var/mob/user)
	if(ishuman(user))
		return 1

/datum/emote/hug/getTarget(var/mob/user)
	var/mob/target = input("Select target", "Target Mob") as null|mob in view(1)
	if(target)
		return target
	return user

/datum/emote/jiggle
	name = "jiggle"
	desc = "Makes the mob jiggle"
	text = "jiggles"
	selfText = "jiggle"

/datum/emote/jiggle/New()
	..()
	commands += "jiggle"
	commands += "jiggles"

/datum/emote/jiggle/available(var/mob/user)
	if(isslime(user))
		return 1

/datum/emote/johnny
	name = "johnny"
	desc = "Yeah, just try it"
	text = "takes a drag from a cigarette and blows their name out in smoke."
	selfText = "take a drag from a cigarette and blow their name out in smoke."
	audible = 1
	mimeText = "takes a drag from a cigarette and blows"
	mimeSelf = "take a drag from a cigarette and blow"
	canTarget = 1
	targetMob = 1
	targetText = ""

/datum/emote/johnny/New()
	..()
	commands += "johnny"

/datum/emote/johnny/available(var/mob/user)
	if(ishuman(user))
		return 1

/datum/emote/johnny/getTarget(var/mob/user)
	var/mob/target = ..()
	if(target && target != user)
		return target
	to_chat(user, "You need a target that isn't yourself")
	return "invalid"

/datum/emote/johnny/createMessage(var/mob/user, var/params)
	if(doMime(user))
		return ..()
	var/message = "\The [user] says \"[params["target"]], please. They had a family.\" [user] [text]"
	return message

/datum/emote/johnny/createSelfMessage(var/mob/user, var/list/params, var/message = "")
	message = ..()
	message = replacetext(message, "says", "say")
	return message

/datum/emote/johnny/createDeafMessage(var/mob/user, vap/list/params, var/message)
	message = "\The [user] says something, then [text]"
	return message

/datum/emote/johnny/replaceMobWithYou(var/mob/M, var/message, var/mob/user)
	if(user && M != user)
		return message
	return ..()

/datum/emote/jump
	name = "jump"
	desc = "Makes the mob jump"
	text = "jumps"
	selfText = "jump"

/datum/emote/jump/New()
	..()
	commands += "jump"
	commands += "jumps"

/datum/emote/jump/available(var/mob/user)
	if(islarva(user))
		return 1

/datum/emote/laugh
	name = "laugh"
	desc = "Makes the mob laugh"
	text = "laughs"
	selfText = "laugh"
	audible = 1
	mimeText = "acts out a laugh"
	mimeSelf = "act out a laugh"
	muzzleAffected = 1

/datum/emote/laugh/New()
	..()
	commands += "laugh"
	commands += "laughs"

/datum/emote/laugh/available(var/mob/user)
	if(ishuman(user))
		return 1

/datum/emote/law
	name = "law"
	desc = "Makes the mob prove it is the law"
	text = "shows its legal authorization barcode."
	selfText = "show your legal authorization barcode."
	audible = 1
	sound = 'sound/voice/biamthelaw.ogg'

/datum/emote/law/New()
	..()
	commands += "law"

/datum/emote/law/available(var/mob/user)
	if(isrobot(user))
		return 1

/datum/emote/law/prevented(var/mob/user)
	. = ..()
	if(.)
		return
	var/mob/living/silicon/robot/U = user
	if (!(istype(U.module, /obj/item/weapon/robot_module/security)))
		return "You are not THE LAW, pal."

/datum/emote/light
	name = "light"
	desc = "makes the mob light up"
	text = "lights up for a bit, then stops."
	selfText = "light up for a bit, then stop."

/datum/emote/light/New()
	..()
	commands += "light"
	commands += "lights"

/datum/emote/light/available(var/mob/user)
	if(isslime(user))
		return 1

/datum/emote/look
	name = "look"
	desc = "Makes the mob look"
	text = "looks"
	selfText = "look"
	canTarget = 1
	targetMob = 1

/datum/emote/look/New()
	..()
	commands += "look"
	commands += "looks"

/datum/emote/look/available(var/mob/user)
	if(ishuman(user))
		return 1
	if(isrobot(user))
		return 1

/datum/emote/moan
	name = "moan"
	desc = "Makes the mob moan"
	text = "moans"
	selfText = "moan"
	audible = 1

/datum/emote/moan/New()
	..()
	commands += "moan"
	commands += "moans"

/datum/emote/moan/available(var/mob/user)
	if(isslime(user))
		return 1
	if(islarva(user))
		return 1

/datum/emote/mumble
	name = "mumble"
	desc = "Makes the mob mumble"
	text = "mumbles"
	selfText = "mumble"
	audible = 1
	mimeText = "mumbles"

/datum/emote/mumble/New()
	..()
	commands += "mumble"
	commands += "mumbles"

/datum/emote/mumble/available(var/mob/user)
	if(ishuman(user))
		return 1

/datum/emote/no
	name = "no"
	desc = "Makes the mob let out a negative blip"
	text = "emits a negative blip"
	selfText = "emit a negative blip"
	audible = 1
	sound = 'sound/machines/synth_no.ogg'

/datum/emote/no/New()
	..()
	commands += "no"

/datum/emote/no/available(var/mob/user)
	if(user.is_mechanical())
		return 1

/datum/emote/nod
	name = "nod"
	desc = "Makes the mob nod"
	text = "nods"
	selfText = "nod"

/datum/emote/nod/New()
	..()
	commands += "nod"
	commands += "nods"

/datum/emote/nod/available(var/mob/user)
	if(islarva(user))
		return 1
	if(isrobot(user))
		return 1
	if(ishuman(user))
		return 1

/datum/emote/notice
	name = "notice"
	desc = "Makes the mob play a loud tone"
	text = "plays a loud tone"
	selfText = "play a loud tone"
	audible = 1

/datum/emote/notice/New()
	..()
	commands += "notice"

/datum/emote/notice/available(var/mob/user)
	if(isbrain(user))
		return 1

/datum/emote/pale
	name = "pale"
	desc = "Makes the mob go pale"
	text = "goes pale for a second."
	selfText = "go pale for a second"

/datum/emote/pale/New()
	..()
	commands += "pale"
	commands += "pales"

/datum/emote/pale/available(var/mob/user)
	if(ishuman(user))
		return 1

/datum/emote/ping
	name = "ping"
	desc = "Makes the mob ping"
	text = "pings"
	selfText = "ping"
	audible = 1
	sound = 'sound/machines/ping.ogg'
	canTarget = 1
	targetMob = 1

/datum/emote/ping/New()
	..()
	commands += "ping"
	commands += "pings"

/datum/emote/ping/available(var/mob/user)
	if(user.is_mechanical())
		return 1

/datum/emote/point
	name = "point"
	desc = "Makes the mob point"
	text = "points"
	selfText = "point"
	canTarget = 1

/datum/emote/point/New()
	..()
	commands += "point"
	commands += "points"

/datum/emote/point/available(var/mob/user)
	if(ishuman(user))
		return 1

/datum/emote/point/createMessage(var/mob/user, var/list/params)
	if(params["target"])
		return
	return ..()

/datum/emote/point/doAction(var/mob/user, var/list/params)
	if(!params["target"])
		return
	user.pointed(params["target"])

/datum/emote/quiver
	name = "quiver"
	desc = "Makes the mob quiver"
	text = "quivers"
	selfText = "quiver"

/datum/emote/quiver/New()
	..()
	commands += "quiver"
	commands += "quivers"

/datum/emote/quiver/available(var/mob/user)
	if(ishuman(user))
		return 1

/datum/emote/raise
	name = "raise"
	desc = "Makes the mob raise a hand"
	text = "raises a hand"
	selfText = "raise a hand"
	restrained = 1

/datum/emote/raise/New(var/mob/user)
	..()
	commands += "raise"
	commands += "raises"

/datum/emote/raise/available(var/mob/user)
	if(ishuman(user))
		return 1

/datum/emote/roar
	name = "roar"
	desc = "Makes the mob roar"
	text = "roars"
	selfText = "roar"
	audible = 1
	muzzleAffected = 1
	muzzledNoise = "loud"

/datum/emote/roar/New()
	..()
	commands += "roar"
	commands += "roars"

/datum/emote/roar/available(var/mob/user)
	if(isalienadult(user))
		return 1

/datum/emote/roll
	name = "roll"
	desc = "Makes the mob roll"
	text = "rolls"
	selfText = "roll"

/datum/emote/roll/New()
	..()
	commands += "roll"
	commands += "rolls"

/datum/emote/roll/available(var/mob/user)
	if(islarva(user))
		return 1

/datum/emote/salute
	name = "salute"
	desc = "Makes the mob salute"
	text = "salutes"
	selfText = "salute"
	canTarget = 1
	targetMob = 1
	targetText = "to"

/datum/emote/salute/New()
	..()
	commands += "salute"
	commands += "salutes"

/datum/emote/salute/available(var/mob/user)
	if(ishuman(user))
		return 1
	if(isrobot(user))
		return 1

/datum/emote/salute/prevented(var/mob/user)
	. = ..()
	if(!. && user.buckled)
		return "you are buckled to something"

/datum/emote/scratch
	name = "scratch"
	desc = "Makes the mob scratch"
	text = "scratches"
	selfText = "scratch"
	restrained = 1

/datum/emote/scratch/New()
	..()
	commands += "scratch"
	commands += "scratches"

/datum/emote/scratch/available(var/mob/user)
	if(islarva(user) || isalienadult(user))
		return 1

/datum/emote/scream
	name = "scream"
	audible = 1
	mimeText = "acts out a scream"
	muzzledNoise = "very loud"
	cooldown = 50
	vol = 80

/datum/emote/scream/New()
	..()
	commands += "scream"
	commands += "screams"

/datum/emote/scream/machine
	name = "machine scream"
	sound = 'sound/goonstation/voice/robot_scream.ogg'

/datum/emote/scream/machine/available(var/mob/user)
	if(user.is_mechanical())
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
	return 1

/datum/emote/scretch
	name = "scretch"
	desc = "makes the mob scretch"  //whatever that is!
	text = "scretches"
	selfText = "scretch"
	audible = 1
	muzzleAffected = 1

/datum/emote/scretch/New()
	..()
	commands += "scretch"
	commands += "scretches"

/datum/emote/scretch/available(var/mob/user)
	if(isalienadult(user) || islarva(user))
		return 1

/datum/emote/shake
	name = "shake"
	desc = "Makes the mob shake its head"
	text = "shakes"
	selfText = "shake"

/datum/emote/shake/New()
	..()
	commands += "shake"
	commands += "shakes"

/datum/emote/shake/available(var/mob/user)
	if(islarva(user))
		return 1
	if(ishuman(user))
		return 1

/datum/emote/shake/standardMessage(var/mob/user)
	var/message = ..()
	message += " [getHis(user)] head"
	return message

/datum/emote/shiver
	name = "shiver"
	desc = "Makes the mob shiver"
	text = "shivers"
	selfText = "shiver"
	audible = 1
	mimeText = "shivers"

/datum/emote/shiver/New()
	..()
	commands += "shiver"
	commands += "shivers"

/datum/emote/shiver/available(var/mob/user)
	if(isalienadult(user) || islarva(user))
		return 1
	if(isslime(user))
		return 1
	if(ishuman(user))
		return 1

/datum/emote/shrug
	name = "shrug"
	desc = "Makes the mob shrug"
	text = "shrugs"
	selfText = "shrug"

/datum/emote/shrug/New()
	..()
	commands += "shrug"
	commands += "shrugs"

/datum/emote/shrug/available(var/mob/user)
	if(ishuman(user))
		return 1

/datum/emote/sigh
	name = "sigh"
	desc = "Makes the mob sigh"
	text = "sighs"
	selfText = "sigh"
	audible = 1
	mimeText = "sighs"
	muzzleAffected = 1
	muzzledNoise = "weak"

/datum/emote/sigh/New()
	..()
	commands += "sigh"
	commands += "sighs"

/datum/emote/sigh/available(var/mob/user)
	if(ishuman(user))
		return 1

/datum/emote/sign
	name = "sign"
	desc = "Makes the mob sign a number"
	text = "signs"
	selfText = "sign"
	restrained = 1
	takesNumber = 1

/datum/emote/sign/New()
	..()
	commands += "sign"
	commands += "signs"

/datum/emote/sign/available(var/mob/user)
	if(isalienadult(user) || islarva(user))
		return 1

/datum/emote/sign/getNumber(var/mob/user)
	var/number = ..()
	if(number == null)
		to_chat(user, "You need a number to sign")
		return "invalid"
	return number

/datum/emote/sign/paramMessage(var/mob/user, var/list/params)
	var/message = "<span class = '[userSpanClass]'>\The [user]</span> [text] [params["num"]]"
	return message

/datum/emote/sign/fingers
	desc = "Makes the mob raise a number of fingers"
	text = "raises"
	selfText = "raise"

/datum/emote/sign/fingers/available(var/mob/user)
	if(ishuman(user))
		return 1

/datum/emote/sign/fingers/getNumber(var/mob/user)
	var/number = ..()
	if(number == "invalid")
		return "invalid"
	var/fingersAvailable = 0
	if(!user.r_hand)
		fingersAvailable += 5
	if(!user.l_hand)
		fingersAvailable += 5
	if(fingersAvailable < number)
		to_chat(user, "You don't have enough fingers free")
		return "invalid"
	return number

/datum/emote/sign/fingers/paramMessage(var/mob/user, var/list/params)
	var/message = "<span class = '[userSpanClass]'>\The [user]</span> [text] [params["num"]] finger\s"	// no, we can't just add " finger\s" to the parent version because the text macro won't work then :( VB
	return message

/datum/emote/slap
	name = "slap"
	desc = "makes the mob slap someone"
	text = "slaps"
	selfText = "slap"
	audible = 1
	sound = 'sound/effects/snap.ogg'
	canTarget = 1
	targetMob = 1
	targetText = ""

/datum/emote/slap/New()
	..()
	commands += "slap"
	commands += "slaps"

/datum/emote/slap/available(var/mob/user)
	if(ishuman(user))
		return 1

/datum/emote/slap/getMobTarget(var/mob/user)
	var/mob/target = input("Select target", "Target Mob") as null|mob in view(1)
	if(!target)
		target = user
	return target

/datum/emote/slap/doAction(var/mob/user, var/list/params)
	if(user == params["target"])
		var/mob/living/U = user
		U.adjustFireLoss(4)

/datum/emote/smile
	name = "smile"
	desc = "Makes the mob smile"
	text = "smiles"
	selfText = "smile"

/datum/emote/smile/New()
	..()
	commands += "smile"
	commands += "smiles"

/datum/emote/smile/available(var/mob/user)
	if(ishuman(user))
		return 1

/datum/emote/snap
	name = "snap"
	desc = "Makes the mob snap it's fingers"
	text = "snaps"
	selfText = "snap"
	audible = 1
	sound = 'sound/effects/fingersnap.ogg'

/datum/emote/snap/New()
	..()
	commands += "snap"
	commands += "snaps"

/datum/emote/snap/available(var/mob/user)
	if(ishuman(user))
		return 1

/datum/emote/snap/prevented(var/mob/user)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/human/H = user
	var/obj/item/organ/external/L = H.get_organ("l_hand")
	var/obj/item/organ/external/R = H.get_organ("r_hand")
	var/left_hand_good = 0
	var/right_hand_good = 0
	if(L && (!(L.status & ORGAN_DESTROYED)) && (!(L.status & ORGAN_SPLINTED)) && (!(L.status & ORGAN_BROKEN)))
		left_hand_good = 1
	if(R && (!(R.status & ORGAN_DESTROYED)) && (!(R.status & ORGAN_SPLINTED)) && (!(R.status & ORGAN_BROKEN)))
		right_hand_good = 1

	if (!left_hand_good && !right_hand_good)
		return "You need at least one hand in good working order to snap your fingers."

/datum/emote/snap/standardMessage(var/mob/user, var/list/params)
	var/message = ..()
	message += " [getHis(user)] fingers"
	params["prob"] = prob(5)
	if(!params["prob"])
		return message
	message += " right off!"

/datum/emote/snap/playSound(var/mob/user, var/list/params)
	if(params["prob"])
		playsound(user.loc, 'sound/effects/snap.ogg', 50, 1)
		return 1
	return ..()

/datum/emote/sneeze
	name = "sneeze"
	desc = "Makes the mob sneezze"
	text = "sneezes"
	selfText = "sneeze"
	audible = 1
	mimeText = "sneeze"
	muzzleAffected = 1
	muzzledNoise = "strange"

/datum/emote/sneeze/New()
	..()
	commands += "sneeze"
	commands += "sneezes"

/datum/emote/sneeze/available(var/mob/user)
	if(ishuman(user))
		return 1

/datum/emote/sniff
	name = "sniff"
	desc = "Makes the mob sniff"
	text = "sniffs"
	selfText = "sniff"
	audible = 1
	mimeText = "sniffs"

/datum/emote/sniff/New()
	..()
	commands += "sniff"
	commands += "sniffs"

/datum/emote/sniff/available(var/mob/user)
	if(ishuman(user))
		return 1

/datum/emote/snore
	name = "snore"
	desc = "Makes the mob snore"
	text = "snores"
	selfText = "snore"
	audible = 1
	mimeText = "sleeps soundly"
	mimeSelf = "sleep soundly"
	muzzleAffected = 1

/datum/emote/snore/New()
	..()
	commands += "snore"
	commands += "snores"

/datum/emote/snore/available(var/mob/user)
	if(ishuman(user))
		return 1

/datum/emote/squish
	name = "squish"
	desc = "Makes the mob squish"
	text = "squishes"
	selfText = "squish"
	audible = 1
	sound = 'sound/effects/slime_squish.ogg'
	canTarget = 1
	targetMob = 1

/datum/emote/squish/New()
	..()
	commands += "squish"
	commands += "squishes"

/datum/emote/available(var/mob/user)
	if(isslime(user))
		return 1
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.species.name == "Slime People")	//Only Slime People can squish
			return 1
		for(var/obj/item/organ/external/L in H.organs) // if your limbs are squishy you can squish too!
			if(L.dna.species =="Slime People")
				return 1

/datum/emote/stare
	name = "stare"
	desc = "Makes the mob stare"
	text = "stares"
	selfText = "stare"
	canTarget = 1
	targetMob = 1

/datum/emote/stare/New()
	..()
	commands += "stare"
	commands += "stares"

/datum/emote/stare/available(var/mob/user)
	if(ishuman(user))
		return 1
	if(isrobot(user))
		return 1

/datum/emote/sulk
	name = "sulk"
	desc = "Makes the mob sulk"
	text = "sulks down sadly"
	selfText = "sulk down sadly"

/datum/emote/sulk/New()
	..()
	commands += "sulk"
	commands += "sulks"

/datum/emote/sulk/available(var/mob/user)
	if(islarva(user))
		return 1

/datum/emote/sway
	name = "sway"
	desc = "Makes the mob sway"
	text = "sways around dizzily"
	selfText = "sway around dizzily"

/datum/emote/sway/New()
	..()
	commands += "sway"
	commands += "sways"

/datum/emote/sway/available(var/mob/user)
	if(islarva(user))
		return 1
	if(isslime(user))
		return 1

/datum/emote/tail
	name = "tail"
	desc = "Makes the mob wave it's tail"
	text = "waves it's tail"
	selfText = "wave your tail"

/datum/emote/tail/New()
	..()
	commands += "tail"

/datum/emote/tail/available(var/mob/user)
	if(islarva(user) || isalienadult(user))
		return 1

/datum/emote/tail/wag
	name = "wag"
	desc = "Makes the mob start wagging its tail"
	text = "starts"
	selfText = "start"

/datum/emote/tail/wag/New()
	..()
	commands = new /list()
	commands += "wag"
	commands += "wags"

/datum/emote/tail/wag/available(var/mob/user)
	if(ishuman(user))
		return 1

/datum/emote/tail/wag/prevented(var/mob/user)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/human/H = user
	if(H.species.bodyflags & TAIL_WAGGING)
		if(H.wear_suit && (H.wear_suit.flags_inv & HIDETAIL || istype(H.wear_suit, /obj/item/clothing/suit/space)))
			return "your clothing is stopping you wag your tail"
		return
	if(!H.body_accessory)
		return "you have no tail to wag!"
	if(!H.body_accessory.try_restrictions())
		return "your clothing is stopping you wag your tail"

/datum/emote/tail/wag/standardMessage(var/mob/user, var/list/params)
	var/message = ..()
	message += " wagging [getHis(user)] tail"
	return message

/datum/emote/tail/wag/doAction(var/mob/user, var/list/params)
	var/mob/living/carbon/human/H = user
	H.start_tail_wagging(1)

/datum/emote/tail/wag/stop
	name = "swag"
	desc = "Makes the mob stop wagging its tail"
	text = "stops"
	selfText = "stop"
	allowParent = 1

/datum/emote/tail/wag/stop/New()
	..()
	commands = new /list()
	commands += "swag"
	commands += "swags"

// seemingly no way to tell if a mob is wagging it's tail! VB
/datum/emote/tail/wag/stop/available(var/mob/user)
	var/mob/living/carbon/human/H = user
	if(!H.species.bodyflags & TAIL_WAGGING && !H.body_accessory)
		return "you can't stop wagging a tail you don't have!"

/datum/emote/tail/wag/stop/doAction(var/mob/user, var/list/params)
	var/mob/living/carbon/human/H = user
	H.stop_tail_wagging(1)

/datum/emote/tremble
	name = "tremble"
	desc = "Makes the mob tremble"
	text = "trembles"
	selfText = "tremble"

/datum/emote/tremble/New()
	..()
	commands += "tremble"
	commands += "trembles"

/datum/emote/tremble/available(var/mob/user)
	if(ishuman(user))
		return 1

/datum/emote/twitch_s
	name = "twitch_s"
	desc = "Makes the mob twitch"
	text = "twitches"
	selfText = "twitch"

/datum/emote/twitch_s/New()
	..()
	commands += "twitch_s"
	commands += "twitches_s"

/datum/emote/twitch_s/available(var/mob/user)
	if(ishuman(user))
		return 1
	if(isrobot(user))
		return 1

/datum/emote/twitch_s/twitch
	name = "twitch"
	desc = "Makes the mob twitch violently"
	allowParent = 1

/datum/emote/twitch_s/twitch/New()
	..()
	commands = new /list()
	commands += "twitch"
	commands += "twitches"

/datum/emote/twitch_s/twitch/available(var/mob/user)
	if(isslime(user))
		return 1
	if(islarva(user))
		return 1
	return ..()

/datum/emote/twitch_s/twitch/standardMessage(var/mob/user, var/list/params)
	var/message = ..()
	message += " violently"
	return message

/datum/emote/vibrate
	name = "vibrate"
	desc = "Makes the mob vibrate"
	text = "vibrates"
	selfText = "vibrate"

/datum/emote/vibrate/New()
	..()
	commands += "vibrate"
	commands += "vibrates"

/datum/emote/vibrate/available(var/mob/user)
	if(isslime(user))
		return 1

/datum/emote/wave
	name = "wave"
	desc = "Makes the mob wave"
	text = "waves"
	selfText = "wave"

/datum/emote/wave/New()
	..()
	commands += "wave"
	commands += "waves"

/datum/emote/wave/available(var/mob/user)
	if(ishuman(user))
		return 1

/datum/emote/whimper
	name = "whimper"
	desc = "Makes the mob whimper"
	text = "whimpers"
	selfText = "whimper"
	audible = 1
	mimeText = "appears hurt"
	mimeSelf = "appear hurt"
	muzzleAffected = 1

/datum/emote/whimper/New()
	..()
	commands += "whimper"
	commands += "whimpers"

/datum/emote/whimper/available(var/mob/user)
	if(islarva(user) || isalienadult(user))
		return 1
	if(ishuman(user))
		return 1

/datum/emote/whistle
	name = "whistle"
	desc = "Makes the mob whistle"
	text = "whistles"
	selfText = "whistle"
	audible = 1

/datum/emote/whistle/New()
	..()
	commands += "whistle"
	commands += "whistles"

/datum/emote/whistle/available(var/mob/user)
	if(isbrain(user))
		return 1

/datum/emote/wink
	name = "wink"
	desc = "Makes the mob wink"
	text = "winks"
	desc = "wink"

/datum/emote/wink/New()
	..()
	commands += "wink"
	commands += "winks"

/datum/emote/wink/available(var/mob/user)
	if(ishuman(user))
		return 1

/datum/emote/yawn
	name = "yawn"
	desc = "makes the mob yawn"
	text = "yawns"
	selfText = "yawn"
	audible = 1
	mimeText = "yawns"
	muzzleAffected = 1

/datum/emote/yawn/New()
	..()
	commands += "yawn"
	commands += "yawns"

/datum/emote/yawn/available(var/mob/user)
	if(ishuman(user))
		return 1

/datum/emote/yes
	name = "yes"
	desc = "Makes the mob let out an affirmative beep"
	text = "lets out an affirmative beep"
	selfText = "let out an affirmative beep"
	audible = 1
	sound = 'sound/machines/synth_yes.ogg'
	canTarget = 1
	targetMob = 1

/datum/emote/yes/New()
	..()
	commands += "yes"

/datum/emote/yes/available(var/mob/user)
	if(user.is_mechanical())
		return 1