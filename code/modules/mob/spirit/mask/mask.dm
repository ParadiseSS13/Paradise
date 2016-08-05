/mob/spirit/mask
	icon = 'icons/mob/spirits/mask.dmi'
	icon_state = "depressurized"

/mob/spirit/mask/New()
	..()
	AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/conjure/create_talisman(null))
	AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/blood_speech(null))
	AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/shatter_lights(null))


/mob/spirit/mask/verb/go_to_follower()
	set category = "Mask"
	set name = "Go to follower"
	set desc = "Select who you would like to go too."

	var/obj/cult_viewpoint/cultist = pick_cultist()
	if(cultist)
		follow_cultist(cultist.owner)
		cult_log("[key_name_admin(src)] started following [key_name_admin(cultist)].")
		to_chat(src, "You start following [cultist.get_display_name()].")


/mob/spirit/mask/verb/urge_cultist()
	set category = "Mask"
	set name = "Urge cultist"
	set desc = "Push your cultists to do something."

	var/obj/cult_viewpoint/cultist = pick_cultist()
	if(cultist)
		if(cultist.owner)
			var/newUrge = stripped_input(usr, "", "Set Urge", "")
			cultist.set_urge(newUrge)
			to_chat(src, "You urge [cultist.owner.name] to [newUrge].")
			cult_log("controlled by [key_name_admin(src)] has urged [key_name_admin(cultist.owner)] to [newUrge].")

/mob/spirit/mask/verb/set_cult_name()
	set category = "Mask"
	set name = "Set Cult Name"
	set desc = "Grant a cultist a name."

	var/obj/cult_viewpoint/cultist = pick_cultist()
	if(cultist)
		var/newName = stripped_input(usr, "", "Set Cult Name", "")
		if(!newName)
			return
		cultist.set_cult_name(newName)
		to_chat(src, "You grant [cultist.owner.name] the secret name of [newName].")
		if(cultist.owner)
			cult_log("[key_name_admin(src)] has set [key_name_admin(cultist.owner)] to \'[newName]\'")


/mob/spirit/mask/verb/urge_cult()
	set category = "Mask"
	set name = "Urge Cult"
	set desc = "Set urge on the entire cult."

	var/newUrge = stripped_input(usr, "Please choose an urge.", "Set Urge", "")
	for(var/obj/cult_viewpoint/viewpoint in cult_viewpoints)
		viewpoint.set_urge(newUrge)
	to_chat(src, "You urge the entire cult to [newUrge].")
	cult_log("[key_name_admin(src)] has urged the entire cult to [newUrge]")


/mob/spirit/mask/verb/set_favor_for_cultist()
	set category = "Mask"
	set name = "Show your favor"
	set desc = "Set the favor for a cultist"

	var/obj/cult_viewpoint/cultist = pick_cultist()
	if(cultist)
		if(cultist.owner)
			var/list/favor = list("Pleased", "Displeased", "Indifference")
			var/emotion = input("Pick your emotion", "Mask", null, null) in favor
			switch(emotion)
				if("Pleased")
					cultist.set_favor(1)
					cult_log("[key_name_admin(src)] is pleased with [key_name_admin(cultist.owner)]")
				if("Displeased")
					cultist.set_favor(-1)
					cult_log("[key_name_admin(src)] is displeased with [key_name_admin(cultist.owner)]")
				if("Indifference")
					cultist.set_favor(0)
					cult_log("[key_name_admin(src)] is indifferent too [key_name_admin(cultist.owner)]")


/mob/spirit/mask/proc/set_name()
	spawn(0)
		var/newName = stripped_input(src, "Please pick a name.", "Pick Name for Mask", "")
		name = newName ? newName : "Mask of Nar'sie"
		to_chat(src, "You have set your name to [name].")


/mob/spirit/mask/proc/pick_cultist()
	var/list/cultists = list()
	for(var/obj/cult_viewpoint/viewpoint in cult_viewpoints)
		cultists[viewpoint.get_display_name()]=viewpoint
	var/input = input("Please, select a cultist!", "Cult", null, null) as null|anything in cultists
	var/obj/cult_viewpoint/result = cultists[input]
	return result


// this proc makes the mask visible very briefly
/mob/spirit/mask/proc/flicker()
	spawn(0)
		alpha = 127
		invisibility=0
		sleep(5)
		invisibility=initial(invisibility)
		alpha = 255

/proc/flicker_mask(mob/spirit/mask/target)
	if(istype(target))
		target.flicker()

// SPELLS
/obj/effect/proc_holder/spell/aoe_turf/blood_speech
	name = "Speak to your Acolytes"
	desc = "This spell allows you to speak to your flock."
	school = "unknown evil"
	charge_type = "recharge"
	charge_max = 2000
	clothes_req = 0
	invocation = "none"
	invocation_type = "none"
	range = 0

/obj/effect/proc_holder/spell/aoe_turf/blood_speech/cast(list/targets)
	var/input = stripped_input(usr, "Please choose a message to tell your acolytes.", "Voice of Blood", "")
	if(!input)
		revert_cast(usr)
	cult_log("[key_name_admin(usr)]says : [input]")
	flicker_mask(usr)
	for(var/datum/mind/H in ticker.mode.cult)
		if(H.current)
			to_chat(H.current, "<span class='cultspeech'><font size=3><span class='name'>[usr.name]: </span><span class='message'>[input]</span></font></span>")
	for(var/mob/spirit/spirit in spirits)
		to_chat(spirit, "<span class='cultspeech'><font size=3><span class='name'>[usr.name]: </span><span class='message'>[input]</span></font></span>")


/obj/effect/proc_holder/spell/aoe_turf/shatter_lights
	name = "Spread Shadows"
	desc = "This spell breaks lights near the mask."
	school = "unknown evil"
	charge_type = "recharge"
	charge_max = 1000
	clothes_req = 0
	invocation = "none"
	invocation_type = "none"
	range = 0

/obj/effect/proc_holder/spell/aoe_turf/shatter_lights/cast(list/targets)
	cult_log("[key_name_admin(usr)] used Spread Shadows.")
	flicker_mask(usr)
	spawn(0)
		for(var/area/A in range(3,get_turf(usr)))
			for(var/obj/machinery/light/L in A)
				L.on = 1
				L.broken()
				sleep(1)
			for(var/obj/item/device/flashlight/F in A)
				F.on = 0


/obj/effect/proc_holder/spell/aoe_turf/conjure/create_talisman
	name = "Create Talisman"
	desc = "This spell conjures a talisman"

	school = "conjuration"
	charge_type = "recharge"
	charge_max = 3000
	clothes_req = 0
	invocation = "none"
	invocation_type = "none"
	range = 0
	summon_type = list(/obj/item/weapon/paper/talisman)

	var/list/talismans = list(	"Armor"="armor",
								"Blind"="blind",
								"Conceal"="conceal",
								"Communicate"="communicate",
								"Deafen"="deafen",
								"EMP"="emp",
								"Teleport"="teleport",
								"Tome"="newtome",
								"Reveal Runes",
								"Stun"="runestun",
								"Soul Stone"="soulstone",
								"Construct"="construct")


/obj/effect/proc_holder/spell/aoe_turf/conjure/create_talisman/cast(list/targets)

	var/talisman = input("Pick a talisman type", "Talisman", null, null) as null|anything in talismans
	var/imbue_value = talismans[talisman]
	if(!talisman)
		to_chat(usr, "You choose not to create a talisman.")
		revert_cast(usr)
		return

	cult_log("[key_name_admin(usr,0)] created a talisman of type [talisman].")
	flicker_mask(usr)

	switch(talisman)

		if("Teleport")
			var/target_rune = input("Pick a teleport target", "Teleport Rune", null, null) as null|anything in engwords
			if(!target_rune)
				to_chat(usr, "You choose not to create a talisman.")
				revert_cast(usr)
				return
			summon_type = list(/obj/item/weapon/paper/talisman)
			newVars = list("imbue" = "[target_rune]", "info" = "[target_rune]")

		if("Soul Stone")
			summon_type = list(/obj/item/device/soulstone)
			newVars = list()

		if("Construct")
			summon_type = list(/obj/structure/constructshell)
			newVars = list()

		else
			summon_type = list(/obj/item/weapon/paper/talisman)
			newVars = list("imbue" = "[imbue_value]")

	..()