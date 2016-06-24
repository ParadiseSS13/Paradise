
/datum/emote/airguitar
	name = "airguitar"
	desc = "Makes the mob play an air guitar"
	commands = list("airguitar")
	text = "is strumming the air and headbanging like a safari chimp"
	selfText = "are strumming the air and headbanging like a safari chimp"
	restrained = 1

/datum/emote/airguitar/available(var/mob/user)
	if(ishuman(user))
		return 1
	if(isrobot(user))
		return 1

/datum/emote/alarm
	name = "alarm"
	desc = "makes the mob sound an alarm"
	commands = list("alarm")
	text = "sounds an alarm"
	selfText = "sound an alarm"
	audible = 1

/datum/emote/alarm/available(var/mob/user)
	if(isbrain(user))
		return 1

/datum/emote/alarm/createBlindMessage(var/mob/user, var/params, var/messaage)
	return "You hear an alarm"

/datum/emote/alert
	name = "alert"
	desc = "Makes the mob sound an alert"
	commands = list("alert")
	text = "lets out a distressed noise"
	selfText = "let out a distressed noise"
	audible = 1

/datum/emote/alert/available(var/mob/user)
	if(isbrain(user))
		return 1

/datum/emote/beep
	name = "beep"
	desc = "makes the mob let out a beep"
	commands = list("beep")
	text = "beeps"
	selfText = "beep"
	audible = 1

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
	commands = list("blink", "blinks")
	text = "blinks"
	selfText = "blink"

/datum/emote/blink/available(var/mob/user)
	if(ishuman(user))
		return 1
	if(isbrain(user))
		return 1

/datum/emote/blink/rapid
	name = "rapid blink"
	desc = "Makes the mob blink rapidly"
	commands = list("blink_r", "blinks_r")
	allowParent = 1

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
	commands = list("blush", "blushes")
	text = "blushes"
	selfText = "blush"

/datum/emote/blush/available(var/mob/user)
	if(ishuman(user))
		return 1

/datum/emote/boop
	name = "boop"
	desc = "Makes the mob boop"
	commands = list("boop", "boops")
	text = "boops"
	selfText = "boop"

/datum/emote/boop/available(var/mob/user)
	if(isbrain(user))
		return 1

/datum/emote/bounce
	name = "bounce"
	desc = "Makes the mob bounce"
	commands = list("bounce", "bounces")
	text = "bounces in place"
	selfText = "bounce in place"

/datum/emote/bounce/available(var/mob/user)
	if(isslime(user))
		return 1

/datum/emote/bow
	name = "bow"
	desc = "Makes the mob bow"
	commands = list("bow", "bows")
	text = "bows"
	selfText = "bow"
	canTarget = 1
	targetMob = 1
	targetText = "to"

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
	commands = list("burp", "burps")
	text = "burps"
	selfText = "burp"
	audible = 1
	mimeText = "opens their mouth rather obnoxiously"
	mimeSelf = "open your mouth rather obnoxiously"
	muzzleAffected = 1
	muzzledNoise = "peculiar"

/datum/emote/burp/available(var/mob/user)
	if(ishuman(user))
		return 1
	if(islarva(user) || isalienadult(user))
		return 1

/datum/emote/buzz
	name = "buzz"
	desc = "Makes the mob buzz"
	commands = list("buzz", "buzzes", "buzzs")
	text = "buzzes"
	selfText = "buzz"
	audible = 1
	sound = 'sound/machines/buzz-sigh.ogg'
	canTarget = 1
	targetMob = 1

/datum/emote/buzz/available(var/mob/user)
	if(user.is_mechanical())
		return 1

/datum/emote/buzz/buzz2
	name = "buzz 2"
	desc = "makes the mob buzz in an irritated way"
	commands = list("buzz2")
	text = "makes an irritated buzzing sound"
	selfText = "make an irritated buzzing sound"
	sound = "sound/machines/buzz-two.ogg"
	allowParent = 1

/datum/emote/chirp
	name = "chirp"
	desc = "Makes the mob chirp"
	commands = list("chirp", "chirps")
	text = "chirps"
	selfText = "chirp"
	audible = 1
	sound = 'sound/misc/nymphchirp.ogg'
	vol = 40
	cooldown = 50

/datum/emote/chirp/available(var/mob/user)
	if(istype(user, /mob/living/simple_animal/diona))
		return 1

/datum/emote/choke
	name = "choke"
	desc = "Makes the mob choke"
	commands = list("choke", "chokes")
	text = "chokes"
	selfText = "choke"
	audible = 1
	mimeText = "clutches"
	mimeSelf = "clutch"
	muzzleAffected = 1
	muzzledNoise = "strong"

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
	commands = list("chuckle", "chuckles")
	text = "chuckles"
	selfText = "chuckle"
	audible = 1
	mimeText = "appears to chuckle"
	mimeSelf = "appear to chuckle"
	muzzleAffected = 1

/datum/emote/chuckle/available(var/mob/user)
	if(ishuman(user))
		return 1

/datum/emote/clap
	name = "clap"
	desc = "clap"
	commands = list("clap", "claps")
	text = "claps"
	selfText = "clap"
	audible = 1
	mimeText = "claps silently"
	restrained = 1

/datum/emote/clap/available(var/mob/user)
	if(isrobot(user))
		return 1
	if(ishuman(user))
		return 1

/datum/emote/collapse
	name = "collapse"
	desc = "Makes the mob collapse"
	commands = list("collapse", "collapses")
	text = "collapses"
	selfText = "collapse"
	audible = 1
	mimeText = "collapses without a sound"

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
	commands = list("cough", "coughs")
	text = "coughs"
	selfText = "cough"
	audible = 1
	mimeText = "appears to cough"
	mimeSelf = "appear to cough"
	muzzleAffected = 1
	muzzledNoise = "strong"

/datum/emote/cough/available(var/mob/user)
	if(ishuman(user))
		return 1

/datum/emote/cry
	name = "cry"
	desc = "Makes the mob cry"
	commands = list("cry", "cries")
	text = "cries"
	selfText = "cry"
	audible = 1
	mimeText = "cries silently"
	muzzleAffected = 1
	muzzledNoise = "weak"

/datum/emote/cry/available(var/mob/user)
	if(ishuman(user))
		return 1

/datum/emote/dance
	name = "dance"
	desc = "makes the mob dance around happily"
	commands = list("dance", "dances")
	text = "dances around happily"
	selfText = "dance around happily"
	restrained = 1

/datum/emote/dance/available(var/mob/user)
	if(islarva(user))
		return 1

/datum/emote/dap
	name = "dap"
	desc = "Makes the mob give daps"
	commands = list("dap", "daps")
	text = "gives daps"
	selfText = "give daps"
	restrained = 1
	canTarget = 1
	targetMob = 1
	targetText = "to"

/datum/emote/dap/available(var/mob/user)
	if(ishuman(user))
		return 1

/datum/emote/dap/addTarget(var/mob/user, var/list/params, var/message = "")
	if(!params["target"] || params["target"] == user)
		message = "<span class='[userSpanClass]'>[user]</span> sadly can't find anybody to give daps to, and daps \himself. Shameful"
		return message
	return ..()

/datum/emote/deathgasp
	name = "deathgasp"
	desc = "Makes the mob let out it's final gasp"
	commands = list("deathgasp", "deathgasps")
	audible = 1

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
	var/message = "<span class='[userSpanClass]'>\The [user]</span> [U.species.death_message]"
	return message

/datum/emote/deathgasp/human/createSelfMessage(var/mob/user, var/list/params, var/message)
	return message

/datum/emote/deathgasp/human/replaceMobWithYou(var/mob/user, var/message)
	return message

/datum/emote/deathgasp/robot
	text = "shudders violently for a moment, then becomes motionless, its eyes slowly darkening"
	selfText = "shudder violently for a moment, then become motionless, your eyes slowly darkening"
	audible = 0

/datum/emote/deathgasp/robot/available(var/mob/user)
	if(isrobot(user))
		return 1

/datum/emote/drone
	name = "drone"
	desc = "Makes the mob drone and rumble"
	commands = list("drone", "drones", "rumble", "rumbles", "hum", "hums")
	text = "rumbles"
	selfText = "rumble"
	audible = 1
	sound = 'sound/voice/DraskTalk.ogg'
	canTarget = 1
	targetMob = 1

/datum/emote/drone/available(var/mob/user)
	if(user.get_species() == "Drask")
		return 1

/datum/emote/drone/addTarget(var/mob/user, var/list/params, var/message)
	if(!params["target"])
		return message
	message = replacetext(message, "rumbles", "drones")
	return ..()

/datum/emote/drone/createSelfMessage(var/mob/user, var/list/params, var/message)
	message = ..()
	message = replacetext(message, "drones", "drone")
	return message

/datum/emote/drool
	name = "drool"
	desc = "Makes the mob drool"
	commands = list("drool", "drools")
	text = "drools"
	selfText = "drool"

/datum/emote/drool/available(var/mob/user)
	if(isalienadult(user) || islarva(user))
		return 1
	if(ishuman(user))
		return 1

/datum/emote/eyebrow
	name = "eyebrow"
	desc = "Makes the mob raise an eyebrow"
	commands = list("eyebrow")
	text = "raises an eyebrow"
	selfText = "raise an eyebrow"

/datum/emote/eyebrow/available(var/mob/user)
	if(ishuman(user))
		return 1

/datum/emote/faint
	name = "faint"
	desc = "makes the mob faint"
	commands = list("faint", "faints")
	text = "faints"
	selfText = "faint"

/datum/emote/faint/available(var/mob/user)
	if(ishuman(user))
		return 1

/datum/emote/faint/doAction(var/mob/user, var/list/params)
	if(!user.sleeping)
		user.sleeping += 1

/datum/emote/fart
	name = "fart"
	desc = "makes the mob fart"
	commands = list("fart", "farts")
	text = "farts"
	selfText = "fart"
	cooldown = 50
	audible = 1

/datum/emote/fart/available(var/mob/user)
	if(ishuman(user))
		return 1

/datum/emote/fart/standardMessage(var/mob/user)
	var/message

	if(TOXIC_FARTS in user.mutations)
		message = "<span class='[emoteSpanClass]'><span class='[userSpanClass]'>\The [user]</span> unleashes a [pick("horrible","terrible","foul","disgusting","awful")] fart</span>"
		return message
	message = "<span class='[emoteSpanClass]'><span class='[userSpanClass]'>\The [user]</span> [pick("passes wind","farts")]</span>"
	return message

/datum/emote/fart/createSelfMessage(var/mob/user, var/list/params, var/message)
	message = ..()
	message = replacetext(message, "unleashes", "unleash")
	message = replacetext(message, "passes", "pass")
	return message

/datum/emote/fart/doAction(var/mob/user)
	if(TOXIC_FARTS in user.mutations)
		for(var/mob/M in range(get_turf(user),2))
			if(M.internal != null && M.wear_mask && (M.wear_mask.flags & AIRTIGHT))
				continue
			if(M == user)
				continue
			M.reagents.add_reagent("jenkem", 1)

	if(locate(/obj/item/weapon/storage/bible) in get_turf(user))
		to_chat(viewers(user), "<span class='warning'><b>[user] farted on the Bible!</b></span>")
		to_chat(viewers(user), "<span class='notice'><b>A mysterious force smites [user]!</b></span>")
		var/datum/effect/system/spark_spread/s = new /datum/effect/system/spark_spread
		s.set_up(3, 1, user)
		s.start()
		user.gib()

/datum/emote/flap
	name = "flap"
	desc = "Makes the mob flap their wings"
	commands = list("flap", "flaps")
	text = "flaps"
	selfText = "flap"
	restrained = 1
	audible = 1

/datum/emote/flap/available(var/mob/user)
	if(ishuman(user))
		return 1
	if(isrobot(user))
		return 1

/datum/emote/flap/standardMessage(var/mob/user, var/list/params)
	var/message = "<span class='[userSpanClass]'>\The [user]</span> [text] \his wings"
	return message

/datum/emote/flap/angry
	name = "angry flap"
	desc = "makes the mob flap their wings angrily"
	commands = list("a_flap", "a_flaps")
	allowParent = 1

/datum/emote/flap/angry/standardMessage(var/mob/user)
	var/message = ..()
	message += " angrily"
	return message

/datum/emote/flash
	name = "flash"
	desc = "Makes the lights on the mob flash quickly"
	commands = list("flash", "flashes")
	text = "flash quickly"
	selfText = "flash quickly"
	startText = "The lights on"

/datum/emote/flash/available(var/mob/user)
	if(isbrain(user))
		return 1

/datum/emote/flip
	name = "flip"
	desc = "Makes the mob flip, possibly in the direction of someone"
	commands = list("flip", "flips")
	text = "flips"
	selfText = "flip"
	canTarget = 1
	targetMob = 1
	targetText = "in"

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
		message = "<span class='[userSpanClass]'>\The [user]</span> flops and flails around on the floor"
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
		message = "<span class='[userSpanClass]'>\The [user]</span> [text] over [params["target"]]!"
		return message
	return ..()

/datum/emote/flip/flipOver/doAction(var/mob/user, var/params, var/message)
	var/obj/item/weapon/grab/G = user.get_active_hand()
	if(istype(G) && (G.affecting == params["target"]) && !G.affecting.buckled)
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
	commands = list("frown", "frowns")
	text = "frowns"
	selfText = "frown"

/datum/emote/frown/available(var/mob/user)
	if(ishuman(user))
		return 1

/datum/emote/gasp
	name = "gasp"
	desc = "Makes the mob gasp"
	commands = list("gasp", "gasps")
	text = "gasps"
	selfText = "gasp"
	audible = 1
	mimeText = "appears to be gasping"
	mimeSelf = "appear to be gasping"
	muzzleAffected = 1
	muzzledNoise = "weak"

/datum/emote/gasp/available(var/mob/user)
	if(isalienadult(user) || islarva(user))
		return 1
	if(ishuman(user))
		return 1

/datum/emote/giggle
	name = "giggle"
	desc = "Makes the mob giggle"
	commands = list("giggle", "giggles")
	text = "giggles"
	selfText = "giggle"
	audible = 1
	mimeText = "giggles silently"
	muzzleAffected = 1

/datum/emote/giggle/available(var/mob/user)
	if(ishuman(user))
		return 1

/datum/emote/glare
	name = "glare"
	desc = "Makes the mob glare"
	commands = list("glare", "glares")
	text = "glares"
	selfText = "glare"
	canTarget = 1
	targetMob = 1

/datum/emote/glare/available(var/mob/user)
	if(ishuman(user))
		return 1
	if(isrobot(user))
		return 1

/datum/emote/gnarl
	name = "gnarl"
	desc = "Makes the mob gnarl and show its teeth"
	commands = list("gnarl", "gnarls")
	text = "gnarls and shows its teeth"
	selfText = "gnarl and show your teeth"
	audible = 1
	muzzleAffected = 1

/datum/emote/gnarl/available(var/mob/user)
	if(islarva(user))
		return 1

/datum/emote/grin
	name = "grin"
	desc = "Makes the mob grin"
	commands = list("grin", "grins")
	text = "grins"
	selfText = "grin"

/datum/emote/grin/available(var/mob/user)
	if(ishuman(user))
		return 1

/datum/emote/groan
	name = "groan"
	desc = "Makes the mob groan"
	commands = list("groan", "groans")
	text = "groans"
	selfText = "groan"
	audible = 1
	mimeText = "appears to groan"
	mimeSelf = "appear to groan"
	muzzleAffected = 1

/datum/emote/available(var/mob/user)
	if(ishuman(user))
		return 1

/datum/emote/grumble
	name = "grumble"
	desc = "Makes the mob grumble"
	commands = list("grumble", "grumbles")
	text = "grumbles"
	selfText = "grumble"
	audible = 1
	mimeText = "grumbles"
	muzzleAffected = 1

/datum/emote/grumble/available(var/mob/user)
	if(ishuman(user))
		return 1

/datum/emote/halt
	name = "halt"
	desc = "Makes the mob sound a halt warning. Only available with a security module"
	commands = list("halt")
	text = "'s speakers skreech, \"Halt! Security!\""
	selfText = " speakers skreech, \"Halt! Security!\""
	audible = 1
	sound = 'sound/voice/halt.ogg'

/datum/emote/halt/available(var/mob/user)
	if(isrobot(user))
		return 1

/datum/emote/halt/prevented(var/mob/user)
	. = ..()
	if(.)
		return
	var/mob/living/silicon/robot/U = user
	if(!(istype(U.module, /obj/item/weapon/robot_module/security)))
		return "you are not security"

/datum/emote/handshake
	name = "handshake"
	desc = "Makes the mob shake hands with a target"
	commands = list("handshake")
	text = "shakes hands"
	selfText = "shake hands"
	canTarget = 1
	targetMob = 1
	mustTarget = 1
	targetText = "with"
	restrained = 1

/datum/emote/handshake/available(var/mob/user)
	if(ishuman(user))
		return 1

/datum/emote/handshake/prevented(var/mob/user)
	. = ..()
	if(!. && user.r_hand)
		return "you need your right hand free"

/datum/emote/handshake/addTarget(var/mob/user, var/list/params, var/message)
	var/mob/target = params["target"]
	if(target.r_hand)
		message = "<span class='[userSpanClass]'>\The [user] holds out his hand to [params["target"]]"
		return message
	return ..()

/datum/emote/hiss
	name = "hiss"
	desc = "Makes the mob hiss"
	commands = list("hiss", "hisses")
	text = "hisses"
	selfText = "hiss"
	audible = 1

/datum/emote/hiss/available(var/mob/user)
	if(isalienadult(user) || islarva(user))
		return 1

/datum/emote/hug
	name = "hug"
	desc = "Makes the mob hug a target or themselves"
	commands = list("hug", "hugs")
	text = "hugs"
	selfText = "hug"
	canTarget = 1
	targetMob = 1
	targetText = ""

/datum/emote/hug/available(var/mob/user)
	if(ishuman(user))
		return 1

/datum/emote/hug/getTarget(var/mob/user)
	var/mob/target = ..()
	if(target)
		return target
	return user

/datum/emote/jiggle
	name = "jiggle"
	desc = "Makes the mob jiggle"
	commands = list("jiggle", "jiggles")
	text = "jiggles"
	selfText = "jiggle"

/datum/emote/jiggle/available(var/mob/user)
	if(isslime(user))
		return 1

/datum/emote/johnny
	name = "johnny"
	desc = "Yeah, just try it"
	commands = list("johnny")
	text = "takes a drag from a cigarette and blows their name out in smoke"
	selfText = "take a drag from a cigarette and blow their name out in smoke"
	audible = 1
	mimeText = "takes a drag from a cigarette and blows"
	mimeSelf = "take a drag from a cigarette and blow"
	canTarget = 1
	targetMob = 1
	mustTarget = 1
	targetText = ""

/datum/emote/johnny/available(var/mob/user)
	if(ishuman(user))
		return 1

/datum/emote/johnny/getTarget(var/mob/user)
	var/mob/target = ..()
	if(target != user)
		return target
	to_chat(user, "You need a target that isn't yourself")
	return INVALID

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

/datum/emote/johnny/createBlindMessage(var/mob/user, var/list/params, var/message)
	message = "You hear someone say \"[params["target"]], please, They had a family\""
	return message

/datum/emote/jump
	name = "jump"
	desc = "Makes the mob jump"
	commands = list("jump", "jumps")
	text = "jumps"
	selfText = "jump"

/datum/emote/jump/available(var/mob/user)
	if(islarva(user) || isalienadult(user))
		return 1
	if(issmall(user))
		return 1

/datum/emote/laugh
	name = "laugh"
	desc = "Makes the mob laugh"
	commands = list("laugh", "laughs")
	text = "laughs"
	selfText = "laugh"
	audible = 1
	mimeText = "acts out a laugh"
	mimeSelf = "act out a laugh"
	muzzleAffected = 1

/datum/emote/laugh/available(var/mob/user)
	if(ishuman(user))
		return 1

/datum/emote/law
	name = "law"
	desc = "Makes the mob prove it is the law"
	commands = list("law")
	text = "shows its legal authorization barcode"
	selfText = "show your legal authorization barcode"
	audible = 1
	sound = 'sound/voice/biamthelaw.ogg'

/datum/emote/law/available(var/mob/user)
	if(isrobot(user))
		return 1

/datum/emote/law/prevented(var/mob/user)
	. = ..()
	if(.)
		return
	var/mob/living/silicon/robot/U = user
	if(!(istype(U.module, /obj/item/weapon/robot_module/security)))
		return "You are not THE LAW, pal"

/datum/emote/light
	name = "light"
	desc = "makes the mob light up"
	commands = list("light", "lights")
	text = "lights up for a bit, then stops"
	selfText = "light up for a bit, then stop"

/datum/emote/light/available(var/mob/user)
	if(isslime(user))
		return 1

/datum/emote/look
	name = "look"
	desc = "Makes the mob look"
	commands = list("look", "looks")
	text = "looks"
	selfText = "look"
	canTarget = 1
	targetMob = 1

/datum/emote/look/available(var/mob/user)
	if(ishuman(user))
		return 1
	if(isrobot(user))
		return 1

/datum/emote/look/addTarget(var/mob/user, var/list/params, var/message)
	if(!params["target"])
		message += " around"
		return message
	return ..()

/datum/emote/moan
	name = "moan"
	desc = "Makes the mob moan"
	commands = list("moan", "moans")
	text = "moans"
	selfText = "moan"
	audible = 1

/datum/emote/moan/available(var/mob/user)
	if(isslime(user))
		return 1
	if(islarva(user))
		return 1

/datum/emote/mumble
	name = "mumble"
	desc = "Makes the mob mumble"
	commands = list("mumble", "mumbles")
	text = "mumbles"
	selfText = "mumble"
	audible = 1
	mimeText = "mumbles"

/datum/emote/mumble/available(var/mob/user)
	if(ishuman(user))
		return 1

/datum/emote/no
	name = "no"
	desc = "Makes the mob let out a negative blip"
	commands = list("no")
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
	commands = list("nod", "nods")
	text = "nods"
	selfText = "nod"

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
	commands = list("notice")
	text = "plays a loud tone"
	selfText = "play a loud tone"
	audible = 1

/datum/emote/notice/available(var/mob/user)
	if(isbrain(user))
		return 1

/datum/emote/pale
	name = "pale"
	desc = "Makes the mob go pale"
	commands = list("pale", "pales")
	text = "goes pale for a second"
	selfText = "go pale for a second"

/datum/emote/pale/available(var/mob/user)
	if(ishuman(user))
		return 1

/datum/emote/ping
	name = "ping"
	desc = "Makes the mob ping"
	commands = list("ping", "pings")
	text = "pings"
	selfText = "ping"
	audible = 1
	sound = 'sound/machines/ping.ogg'
	canTarget = 1
	targetMob = 1

/datum/emote/ping/available(var/mob/user)
	if(user.is_mechanical())
		return 1

/datum/emote/point
	name = "point"
	desc = "Makes the mob point"
	commands = list("point", "points")
	text = "points"
	selfText = "point"
	canTarget = 1

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
	commands = list("quiver", "quivers")
	text = "quivers"
	selfText = "quiver"

/datum/emote/quiver/available(var/mob/user)
	if(ishuman(user))
		return 1

/datum/emote/raise
	name = "raise"
	desc = "Makes the mob raise a hand"
	commands = list("raise", "raises")
	text = "raises a hand"
	selfText = "raise a hand"
	restrained = 1

/datum/emote/raise/available(var/mob/user)
	if(ishuman(user))
		return 1

/datum/emote/roar
	name = "roar"
	desc = "Makes the mob roar"
	commands = list("roar", "roars")
	text = "roars"
	selfText = "roar"
	audible = 1
	muzzleAffected = 1
	muzzledNoise = "loud"

/datum/emote/roar/available(var/mob/user)
	if(isalienadult(user))
		return 1

/datum/emote/roll
	name = "roll"
	desc = "Makes the mob roll"
	commands = list("roll", "rolls")
	text = "rolls"
	selfText = "roll"

/datum/emote/roll/available(var/mob/user)
	if(islarva(user))
		return 1
	if(issmall(user))
		return 1

/datum/emote/salute
	name = "salute"
	desc = "Makes the mob salute"
	commands = list("salute", "salutes")
	text = "salutes"
	selfText = "salute"
	canTarget = 1
	targetMob = 1
	targetText = "to"

/datum/emote/salute/available(var/mob/user)
	if(ishuman(user))
		return 1
	if(isrobot(user))
		return 1

/datum/emote/salute/prevented(var/mob/user)
	. = ..()
	if(!. && user.buckled)
		return "you are buckled to something"

/datum/emote/salute/getMobTarget(var/mob/user, var/list/targets)
	var/mob/target = ..()
	if(target != user)
		return target

/datum/emote/scratch
	name = "scratch"
	desc = "Makes the mob scratch"
	commands = list("scratch", "scratches")
	text = "scratches"
	selfText = "scratch"
	restrained = 1

/datum/emote/scratch/available(var/mob/user)
	if(islarva(user) || isalienadult(user))
		return 1
	if(issmall(user))
		return 1

/datum/emote/scream
	name = "scream"
	desc = "makes the mob scream"
	commands = list("scream", "screams")
	text = "screams!"
	selfText = "scream!"
	audible = 1
	mimeText = "acts out a scream"
	muzzledNoise = "very loud"
	cooldown = 50
	vol = 80

/datum/emote/scream/createMessage(var/mob/user, var/list/params)
	var/mob/living/carbon/human/H = user

	if(istype(H))
		return "<span class='[userSpanClass]'>\The [user]</span> [H.species.scream_verb]!"
	else
		return ..()

/datum/emote/scream/replaceMobWithYou(var/mob/M, var/message = "", var/mob/user)
	var/mob/living/carbon/human/H = user

	if(istype(H) && (H.species.scream_verb != "screams"))
		return message
	return ..()

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
	commands = list("scretch", "scretches")
	text = "scretches"
	selfText = "scretch"
	audible = 1
	muzzleAffected = 1

/datum/emote/scretch/available(var/mob/user)
	if(isalienadult(user) || islarva(user))
		return 1

/datum/emote/shake
	name = "shake"
	desc = "Makes the mob shake its head"
	commands = list("shake", "shakes")
	text = "shakes"
	selfText = "shake"

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
	commands = list("shiver", "shivers")
	text = "shivers"
	selfText = "shiver"
	audible = 1
	mimeText = "shivers"

/datum/emote/shiver/available(var/mob/user)
	if(isalienadult(user) || islarva(user))
		return 1
	if(isslime(user))
		return 1
	if(ishuman(user))
		return 1

/datum/emote/shiver/createBlindMessage(var/mob/user, var/list/params, var/message)
	message = "you hear someone's teeth chattering together"

/datum/emote/shrug
	name = "shrug"
	desc = "Makes the mob shrug"
	commands = list("shrug", "shrugs")
	text = "shrugs"
	selfText = "shrug"

/datum/emote/shrug/available(var/mob/user)
	if(ishuman(user))
		return 1

/datum/emote/sigh
	name = "sigh"
	desc = "Makes the mob sigh"
	commands = list("sigh", "sighs")
	text = "sighs"
	selfText = "sigh"
	audible = 1
	mimeText = "sighs"
	muzzleAffected = 1
	muzzledNoise = "weak"

/datum/emote/sigh/available(var/mob/user)
	if(ishuman(user))
		return 1

/datum/emote/sign
	name = "sign"
	desc = "Makes the mob sign a number"
	commands = list("sign", "signs")
	text = "signs"
	selfText = "sign"
	restrained = 1
	takesNumber = 1

/datum/emote/sign/available(var/mob/user)
	if(isalienadult(user) || islarva(user))
		return 1

/datum/emote/sign/getNumber(var/mob/user)
	var/number = ..()
	if(number == null)
		to_chat(user, "You need a number to sign")
		return INVALID
	return number

/datum/emote/sign/paramMessage(var/mob/user, var/list/params)
	var/message = "<span class='[userSpanClass]'>\The [user]</span> [text] [params["num"]]"
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
	if(number == INVALID)
		return INVALID
	var/fingersAvailable = 0
	if(!user.r_hand)
		fingersAvailable += 5
	if(!user.l_hand)
		fingersAvailable += 5
	if(fingersAvailable < number)
		to_chat(user, "You don't have enough fingers free")
		return INVALID
	return number

/datum/emote/sign/fingers/paramMessage(var/mob/user, var/list/params)
	var/message = "<span class='[userSpanClass]'>\The [user]</span> [text] [params["num"]] finger\s"	// no, we can't just add " finger\s" to the parent version because the text macro won't work then :( VB
	return message

/datum/emote/slap
	name = "slap"
	desc = "makes the mob slap someone"
	commands = list("slap", "slaps")
	text = "slaps"
	selfText = "slap"
	audible = 1
	sound = 'sound/effects/snap.ogg'
	canTarget = 1
	targetMob = 1
	targetText = ""

/datum/emote/slap/New()
	..()
	cooldown = 0

/datum/emote/slap/available(var/mob/user)
	if(ishuman(user))
		return 1

/datum/emote/slap/getMobTarget(var/mob/user, var/list/targets)
	for(var/mob/M in view(getLoc(user), 1))
		targets += M
	var/mob/target = input("Select target", "Target Mob") as null|anything in targets
	if(target == "None")
		target = user
	return target

/datum/emote/slap/createBlindMessage(var/mob/user, var/list/params, var/message)
	message = ..()
	message = replacetext(message, "someone", "a")
	return message

/datum/emote/slap/doAction(var/mob/user, var/list/params)
	if(user == params["target"])
		var/mob/living/U = user
		U.adjustFireLoss(4)

/datum/emote/smile
	name = "smile"
	desc = "Makes the mob smile"
	commands = list("smile", "smiles")
	text = "smiles"
	selfText = "smile"

/datum/emote/smile/available(var/mob/user)
	if(ishuman(user))
		return 1

/datum/emote/snap
	name = "snap"
	desc = "Makes the mob snap it's fingers"
	commands = list("snap", "snaps")
	text = "snaps"
	selfText = "snap"
	audible = 1
	sound = 'sound/effects/fingersnap.ogg'

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

	if(!left_hand_good && !right_hand_good)
		return "You need at least one hand in good working order to snap your fingers"

/datum/emote/snap/standardMessage(var/mob/user, var/list/params)
	var/message = ..()
	message += " [getHis(user)] fingers"
	params["prob"] = prob(5)
	if(!params["prob"])
		return message
	message += " right off!"
	return message

/datum/emote/snap/playSound(var/mob/user, var/list/params)
	if(params["prob"])
		playsound(user.loc, 'sound/effects/snap.ogg', 50, 1)
		return 1
	return ..()

/datum/emote/snap/createBlindMessage(var/mob/user, var/list/params, var/message)
	message = ..()
	message += " their fingers"
	return message

/datum/emote/snap/createDeafMessage(var/mob/user, var/list/params, var/message)
	return message

/datum/emote/sneeze
	name = "sneeze"
	desc = "Makes the mob sneeze"
	commands = list("sneeze", "sneezes")
	text = "sneezes"
	selfText = "sneeze"
	audible = 1
	mimeText = "sneeze"
	muzzleAffected = 1
	muzzledNoise = "strange"

/datum/emote/sneeze/available(var/mob/user)
	if(ishuman(user))
		return 1

/datum/emote/sniff
	name = "sniff"
	desc = "Makes the mob sniff"
	commands = list("sniff", "sniffs")
	text = "sniffs"
	selfText = "sniff"
	audible = 1
	mimeText = "sniffs"

/datum/emote/sniff/available(var/mob/user)
	if(ishuman(user))
		return 1

/datum/emote/snore
	name = "snore"
	desc = "Makes the mob snore"
	commands = list("snore", "snores")
	text = "snores"
	selfText = "snore"
	audible = 1
	mimeText = "sleeps soundly"
	mimeSelf = "sleep soundly"
	muzzleAffected = 1

/datum/emote/snore/available(var/mob/user)
	if(ishuman(user))
		return 1

/datum/emote/squish
	name = "squish"
	desc = "Makes the mob squish"
	commands = list("squish", "squishes")
	text = "squishes"
	selfText = "squish"
	audible = 1
	sound = 'sound/effects/slime_squish.ogg'
	canTarget = 1
	targetMob = 1

/datum/emote/squish/available(var/mob/user)
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
	commands = list("stare", "stares")
	text = "stares"
	selfText = "stare"
	canTarget = 1
	targetMob = 1

/datum/emote/stare/available(var/mob/user)
	if(ishuman(user))
		return 1
	if(isrobot(user))
		return 1

/datum/emote/sulk
	name = "sulk"
	desc = "Makes the mob sulk"
	commands = list("sulk", "sulks")
	text = "sulks down sadly"
	selfText = "sulk down sadly"

/datum/emote/sulk/available(var/mob/user)
	if(islarva(user))
		return 1

/datum/emote/sway
	name = "sway"
	desc = "Makes the mob sway"
	commands = list("sway", "sways")
	text = "sways around dizzily"
	selfText = "sway around dizzily"

/datum/emote/sway/available(var/mob/user)
	if(islarva(user))
		return 1
	if(isslime(user))
		return 1

/datum/emote/tail
	name = "tail"
	desc = "Makes the mob wave it's tail"
	commands = list("tail")
	text = "waves it's tail"
	selfText = "wave your tail"

/datum/emote/tail/available(var/mob/user)
	if(islarva(user) || isalienadult(user))
		return 1
	if(issmall(user))
		return 1

/datum/emote/tail/wag
	name = "wag"
	desc = "Makes the mob start wagging its tail"
	commands = list("wag", "wags")
	text = "starts"
	selfText = "start"

/datum/emote/tail/wag/available(var/mob/user)
	if(issmall(user))
		return
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
	commands = list("swag", "swags")
	text = "stops"
	selfText = "stop"
	allowParent = 1

// seemingly no way to tell if a mob is wagging it's tail! VB
/datum/emote/tail/wag/stop/prevented(var/mob/user)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/human/H = user
	if(!(H.species.bodyflags & TAIL_WAGGING) && !H.body_accessory)
		return "you can't stop wagging a tail you don't have!"

/datum/emote/tail/wag/stop/doAction(var/mob/user, var/list/params)
	var/mob/living/carbon/human/H = user
	H.stop_tail_wagging(1)

/datum/emote/tremble
	name = "tremble"
	desc = "Makes the mob tremble"
	commands = list("tremble", "trembles")
	text = "trembles"
	selfText = "tremble"

/datum/emote/tremble/available(var/mob/user)
	if(ishuman(user))
		return 1

/datum/emote/twitch_s
	name = "twitch_s"
	desc = "Makes the mob twitch"
	commands = list("twitch_s", "twitches_s")
	text = "twitches"
	selfText = "twitch"

/datum/emote/twitch_s/available(var/mob/user)
	if(ishuman(user))
		return 1
	if(isrobot(user))
		return 1

/datum/emote/twitch_s/twitch
	name = "twitch"
	desc = "Makes the mob twitch violently"
	commands = list("twitch", "twitches")
	allowParent = 1

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
	commands = list("vibrate", "vibrates")
	text = "vibrates"
	selfText = "vibrate"

/datum/emote/vibrate/available(var/mob/user)
	if(isslime(user))
		return 1

/datum/emote/wave
	name = "wave"
	desc = "Makes the mob wave"
	commands = list ("wave", "waves")
	text = "waves"
	selfText = "wave"

/datum/emote/wave/available(var/mob/user)
	if(ishuman(user))
		return 1

/datum/emote/whimper
	name = "whimper"
	desc = "Makes the mob whimper"
	commands = list("whimper", "whimpers")
	text = "whimpers"
	selfText = "whimper"
	audible = 1
	mimeText = "appears hurt"
	mimeSelf = "appear hurt"
	muzzleAffected = 1

/datum/emote/whimper/available(var/mob/user)
	if(islarva(user) || isalienadult(user))
		return 1
	if(ishuman(user))
		return 1

/datum/emote/whistle
	name = "whistle"
	desc = "Makes the mob whistle"
	commands = list("whistle", "whistles")
	text = "whistles"
	selfText = "whistle"
	audible = 1

/datum/emote/whistle/available(var/mob/user)
	if(isbrain(user))
		return 1

/datum/emote/wink
	name = "wink"
	desc = "Makes the mob wink"
	commands = list("wink", "winks")
	text = "winks"
	selfText = "wink"

/datum/emote/wink/available(var/mob/user)
	if(ishuman(user))
		return 1

/datum/emote/yawn
	name = "yawn"
	desc = "makes the mob yawn"
	commands = list("yawn", "yawns")
	text = "yawns"
	selfText = "yawn"
	audible = 1
	mimeText = "yawns"
	muzzleAffected = 1

/datum/emote/yawn/available(var/mob/user)
	if(ishuman(user))
		return 1

/datum/emote/yes
	name = "yes"
	desc = "Makes the mob let out an affirmative beep"
	commands = list("yes")
	text = "lets out an affirmative beep"
	selfText = "let out an affirmative beep"
	audible = 1
	sound = 'sound/machines/synth_yes.ogg'
	canTarget = 1
	targetMob = 1

/datum/emote/yes/available(var/mob/user)
	if(user.is_mechanical())
		return 1