

/mob/living/carbon/human/virtual_reality
	var/mob/living/carbon/human/real_me
	var/datum/vr_room/myroom
	var/datum/action/quit_vr/quit_action
	var/datum/action/back_to_lobby/back_to_lobby
	var/datum/action/detach_from_avatar/detach_from_avatar
	var/obj/item/clothing/ears/vr_headset/controller

/mob/living/carbon/human/virtual_reality/New()
	quit_action = new()
	quit_action.Grant(src)
	back_to_lobby = new()
	back_to_lobby.Grant(src)
	detach_from_avatar = new()
	detach_from_avatar.Grant(src)
	..()

/mob/living/carbon/human/virtual_reality/death()
	if(!can_die())
		return FALSE
	handle_despawn()
	return ..(gibbed = 1)

/mob/living/carbon/human/virtual_reality/proc/handle_despawn()
	myroom.players.Remove(src)
	vr_all_players.Remove(src)
	if((myroom.players.len == 0) && (myroom.expires == VR_ROOM_USER))
		if(myroom.delete_timer)
			deltimer(myroom.delete_timer)
		myroom.delete_timer = addtimer(CALLBACK(myroom, /datum/vr_room/proc/cleanup), 3 MINUTES, TIMER_STOPPABLE)
	else if((myroom.players.len == 1) && (myroom.expires == VR_ROOM_PVP))
		if(myroom.round_timer)
			deltimer(myroom.round_timer)
		myroom.round_timer = addtimer(CALLBACK(myroom, /datum/vr_room/proc/vr_round), 10 SECONDS, TIMER_STOPPABLE)
		var/mob/living/carbon/human/virtual_reality/winner = myroom.players[1]
		myroom.round_end = world.time + 1 MINUTES
		for(var/mob/living/carbon/human/virtual_reality/P in vr_all_players)
			if(P.ckey)
				to_chat(P, "SYSTEM MESSAGE: [winner] has won the PVP match in The [myroom]. New match in one minute, please be in the lobby.")
			else if(P.real_me.can_hear() && P.real_me.ckey && P in myroom.waitlist)
				to_chat(P.real_me, "\[VR HEADSET\]: [winner] has won the PVP match in The [myroom]. New match in one minute, please be in the lobby.")

	if(ckey)
		return_to_lobby()
	else if(controller.vr_human == src)
		controller.vr_human = null
	if(!surgeries.len)
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
		notransform = 1
		canmove = 0
		icon = null
		invisibility = 101
		QDEL_IN(src, 15)


/mob/living/carbon/human/virtual_reality/Destroy()
	return ..()

/mob/living/carbon/human/virtual_reality/ghost()
	alert(src, "You can not ghost while in VR. Please exit first.","Are you sure you want to ghost?")
	return

/mob/living/carbon/human/virtual_reality/proc/revert_to_reality(var/remove)
	if(real_me && ckey)
		real_me.ckey = ckey
		real_me.vr_avatar = null
		real_me.EyeBlind(2)
		real_me.Confused(2)
		if(controller.contained() && vr_server_status == VR_SERVER_EMAG)
			real_me.adjustBrainLoss(60)
			real_me.vomit(20)
		processing_objects.Remove(controller)
		if(remove)
			controller.vr_human = null
		if(remove)
			handle_despawn()
		else
			return src

/mob/living/carbon/human/virtual_reality/proc/return_to_lobby()
	if(real_me && mind)
		var/datum/vr_room/lobby = vr_rooms_official["Lobby"]
		spawn_vr_avatar(src, lobby)

/datum/action/quit_vr
	name = "Quit Virtual Reality"
	button_icon_state = "shutdown"

/datum/action/quit_vr/Trigger()
	if(..())
		if(istype(owner, /mob/living/carbon/human/virtual_reality))
			var/mob/living/carbon/human/virtual_reality/vr = owner
			if(!vr.controller.contained())
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
			if(!vr.controller.contained())
				vr.revert_to_reality(0)
			else
				to_chat(owner, "You are currently imprisoned in Virtual Reality and are unable to disconnect.")
		else
			Remove(owner)
