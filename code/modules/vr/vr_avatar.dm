

/mob/living/carbon/human/virtual_reality
	var/mob/living/carbon/human/real_me
	var/datum/vr_room/myroom
	var/datum/action/quit_vr/quit_action
	var/datum/action/back_to_lobby/back_to_lobby
	var/datum/action/detach_from_avatar/detach_from_avatar

/mob/living/carbon/human/virtual_reality/New()
	quit_action = new()
	quit_action.Grant(src)
	back_to_lobby = new()
	back_to_lobby.Grant(src)
	detach_from_avatar = new()
	detach_from_avatar.Grant(src)
	..()

/mob/living/carbon/human/virtual_reality/death()
	myroom.players.Remove(src)
	vr_all_players.Remove(src)
	if((myroom.players.len == 0) && (myroom.expires == 1))
		myroom.delete_timer = addtimer(myroom, "cleanup", 3 MINUTES)
	else if((myroom.players.len == 1) && (myroom.expires == 2))
		myroom.round_timer = addtimer(myroom, "vr_round", 10 SECONDS)
		var/mob/living/carbon/human/virtual_reality/winner = myroom.players[1]
		myroom.round_end = world.time + 1 MINUTES
		for(var/mob/living/carbon/human/virtual_reality/P in vr_all_players)
			if(P.ckey)
				to_chat(P, "SYSTEM MESSAGE: [winner.name] has won the PVP match in The [myroom.name]. New match in one minute, please be in the lobby.")
			else if(P.real_me.can_hear() && P.real_me.ckey && P in myroom.waitlist)
				to_chat(P.real_me, "\[VR HEADSET\]: [winner.name] has won the PVP match in The [myroom.name]. New match in one minute, please be in the lobby.")

	if(src.ckey)
		return_to_lobby()
	var/mob/living/carbon/human/virtual_reality/vr = src
	var/list/corpse_equipment = vr.get_all_slots()
	corpse_equipment += vr.get_equipped_items()
	for(var/obj/O in corpse_equipment)
		if(myroom.template.death_type == VR_DROP_ALL)
			vr.unEquip(O)
		else if(myroom.template.death_type == VR_DROP_BLACKLIST && !(O.type in myroom.template.drop_blacklist))
			vr.unEquip(O)
		else if(myroom.template.death_type == VR_DROP_WHITELIST && (O.type in myroom.template.drop_whitelist))
			vr.unEquip(O)
		else
			qdel(O)
	qdel(src)
	return ..()

/mob/living/carbon/human/virtual_reality/Destroy()
	return ..()

/mob/living/carbon/human/virtual_reality/ghost()
	set category = "OOC"
	set name = "Ghost"
	set desc = "Relinquish your life and enter the land of the dead."
	var/mob/living/carbon/human/H = real_me
	revert_to_reality(FALSE)
	if(H)
		H.ghost()
	death()

/mob/living/carbon/human/virtual_reality/say(var/message)
	real_me.say(message)
	..(message)

/mob/living/carbon/human/virtual_reality/proc/revert_to_reality(var/remove)
	if(real_me && ckey)
		real_me.ckey = ckey
		real_me.EyeBlind(2)
		real_me.Confused(2)
		var/mob/living/carbon/human/virtual_reality/vr = src
		var/obj/item/clothing/ears/vr_headset/goggles
		for(var/obj/item/clothing/ears/vr_headset/g in vr.real_me.contents)
			goggles = g
		if(goggles.contained() && vr_server_status == VR_SERVER_EMAG)
			real_me.adjustBrainLoss(60)
			real_me.vomit(20)
		for(var/obj/item/clothing/ears/vr_headset/g in vr.real_me.contents)
			processing_objects.Remove(g)
		if(remove)
			death()
		else
			return src

/mob/living/carbon/human/virtual_reality/proc/return_to_lobby()
	if(real_me && mind)
		var/mob/living/carbon/human/virtual_reality/new_vr
		var/datum/vr_room/lobby = vr_rooms_official["Lobby"]
		new_vr = spawn_vr_avatar(src, lobby)
		for(var/obj/item/clothing/ears/vr_headset/g in new_vr.real_me.contents)
			g.vr_human = new_vr


/datum/action/quit_vr
	name = "Quit Virtual Reality"
	button_icon_state = "shutdown"

/datum/action/quit_vr/Trigger()
	if(..())
		if(istype(owner, /mob/living/carbon/human/virtual_reality))
			var/mob/living/carbon/human/virtual_reality/vr = owner
			var/obj/item/clothing/ears/vr_headset/goggles
			for(var/obj/item/clothing/ears/vr_headset/g in vr.real_me.contents)
				goggles = g
			if(!goggles.contained())
				vr.revert_to_reality(1)
			else
				to_chat(owner, "You are currently imprisoned in Virtual Reality and are unable to disconnect.")
		else
			Remove(owner)

/datum/action/back_to_lobby
	name = "Return To Lobby"
	button_icon_state = "lobby"

/datum/action/back_to_lobby/Trigger()
	if(..())
		if(istype(owner, /mob/living/carbon/human/virtual_reality))
			var/mob/living/carbon/human/virtual_reality/vr = owner
			vr.death()
		else
			Remove(owner)

/datum/action/detach_from_avatar
	name = "Detach From Avatar"
	button_icon_state = "logout"

/datum/action/detach_from_avatar/Trigger()
	if(..())
		if(istype(owner, /mob/living/carbon/human/virtual_reality))
			var/mob/living/carbon/human/virtual_reality/vr = owner
			var/obj/item/clothing/ears/vr_headset/goggles
			for(var/obj/item/clothing/ears/vr_headset/g in vr.real_me.contents)
				goggles = g
			if(!goggles.contained())
				vr.revert_to_reality(0)
			else
				to_chat(owner, "You are currently imprisoned in Virtual Reality and are unable to disconnect.")
		else
			Remove(owner)
